#
# oracle.rb -- primary require 'galileo/oracle' and core class extensions
#

# Shared gem
require 'galileo/base'
require 'csv'
require 'galileo/oracle_config'

# Galileo ETL for Oracle
module Galileo; module ORACLE

  class Process < Galileo::Base::Process

    #-------------------------------------------------------------------------------
    # Filename extentions handled by oracle
    #-------------------------------------------------------------------------------
    handle_extensions %w{ oracle oracle.zip oracle.gz }

    #-------------------------------------------------------------------------------
    # Overwride opts to read CSV as Array and not by CSV::Table
    #-------------------------------------------------------------------------------
    def self.read_csv( path, contents: nil, headers: false, skip_blanks: true, filter_by_pattern_method: :grep, include_pattern: nil, exclude_pattern: nil)
      super(path, contents: contents, headers: headers, skip_blanks: skip_blanks, filter_by_pattern_method: filter_by_pattern_method, include_pattern: include_pattern, exclude_pattern: exclude_pattern)
    end

    #-------------------------------------------------------------------------------
    # Add to read to only process into @raw files found in CONFIG
    #-------------------------------------------------------------------------------
    def read(path)
      include_files = Galileo::ORACLE::CONFIG.each.map{ |k,v| v[:file] }
      if File.ftype( path ) == "directory"
        super(path)
      else
        filename = File.basename(path)
        if include_files.include?(filename)
          super(path)
        else
          Galileo.log.debug "Raw file #{filename} is not included in config.  Raw processing is being skipped."
        end
      end
    end

    # Override extract so we can capture unable to extract and move them asside as to not
    # stop processing, expecially on appliances.
    def extract(filename, destination)
      begin
        super(filename, destination)
      rescue StandardError => e
        case e.message
        when /unable to extract/i
          raise Galileo::Base::Process::IgnoreFileException.new("Unable to extract #{filename} - ignoring file.")
        else
          raise e
        end
      end
    end

    private

    def parse

      # Get the start time in ms
      start_time = Time.now.to_f

      # Get configuration: from oracle_config.rb
      configs = Galileo::ORACLE::CONFIG

      # Process raw data into configs
      data = process_raw(@raw,configs)

      # Turn into base data
      convert_to_base_data(data, @data, type_suffix="_raw")

      # Get GPE Agent Versions
      gpe_oracle_version, gpe_comm_version = get_gpe_versions
      @data.add_types :global
      @data.add_objects :global, [ :oracle ]
      @data.add_attributes :global, [ :gpe_oracle_version, :gpe_comm_version ]
      @data.add_trend :global, :gpe_oracle_version, 0, [ gpe_oracle_version ]
      @data.add_trend :global, :gpe_comm_version, 0, [ gpe_comm_version ]

      Galileo.log.debug "Base Data initialization / parse complete #{"%8dms" % ((Time.now.to_f - start_time) * 1000)}."

    end

    def get_gpe_versions
      oracle_version = @raw["RPM.gpe-agent-oracle.txt"]
        .lines.select{ |line| line.match(/Release|Version/) }
        .map{ |line| line.split(" : ")[1].chomp.split(" ").first }
        .join("-")
      comm_version   = @raw["RPM.gpe-agent-comm.txt"  ]
        .lines.select{ |line| line.match(/Release|Version/) }
        .map{ |line| line.split(" : ")[1].chomp.split(" ").first }
        .join("-")
      return [ oracle_version, comm_version ]
    end

    def process_raw(raw,configs)
      ret = {}
      configs.each do |type,config|
        start = Time.now.to_f
        file = config[:file]
        data = raw[config[:file]]
        if data.nil?
          Galileo.log.warn "Type #{type} is missing from input expecting #{file} in input file. Will #{config[:if_missing]}."
          case config[:if_missing]
          when :continue
            next
          when :stop_and_ignore
            raise Galileo::Base::Process::IgnoreFileException.new("#{config[:filename]} missing from input.")
          end
        end
        case config[:filetype]
        when :csv
          ret[type] = process_csv(config,data)
        when :text_to_csv
          data = CSV.parse( data, :headers => false, :skip_blanks => true )
          ret[type] = process_csv(config,data)
        when :rpm
          Galileo.log.debug "Including RPM data into @raw: #{config[:file]}"
        else
          raise "Unable to process filetype: #{config[:filetype]}"
        end
        Galileo.log.debug "#{"%6d" % ((Time.now.to_f-start)*1000)}ms Processing for #{type} from filename #{config[:file]} is complete."
      end
      return ret
    end

    def process_csv(config,raw)
      ret          = Hash.new
      skipped_rec  = 0
      header       = raw.first
      time_idx     = config[:time_columns].map{ |o| header.index(o) }
      object_idx   = config[:object_columns].map{ |o| header.index(o) }
      attrib_idx   = config[:attribute_columns].map{ |o| header.index(o) }
      crosstab_idx = config[:crosstab_columns].map{ |o| header.index(o) }
      if config[:include_columns].nil?
        include_idx = []
      elsif config[:include_columns].empty?
        remain = header - config[:attribute_columns] - config[:crosstab_columns]
        include_idx = remain.map{ |o| header.index(o) }
      else
        include_idx = config[:include_columns].map{ |o| header.index(o) }
      end
      raw[1..-1].each do |row|
        next if row == :skip_row
        transform = config[:transform_cols]
        row = transform.call(header,row) unless transform.nil?
        next if header == row
        begin
          ts = row.values_at(*time_idx).join(" ")
          epoch = DateTime.parse(ts).to_time.to_i
          obj = row.values_at(*object_idx).join("-")
        rescue
          skipped_rec += 1
          next
        end
        crosstab_idx.each do |c|
          a1 = row.values_at(*attrib_idx).join("-")
          a2  = header[c]
          attrib = "#{a1} #{a2}".strip.downcase
          val = row[c]
          ret[obj] ||= {}
          ret[obj][attrib] ||= {}
          if ret[obj][attrib][epoch]
            Galileo.log.debug "#{obj}/#{attrib}/#{epoch} already exists for type #{config[:file]}!"
          else
            ret[obj][attrib][epoch] = val
          end
        end
        include_idx.each do |c|
          attrib = header[c].downcase
          val = row[c]
          ret[obj] ||= {}
          ret[obj][attrib] ||= {}
          ret[obj][attrib][epoch] = val
        end
        ret[obj]["_GPE_timestamp"] ||= Hash.new
        ret[obj]["_GPE_timestamp"][epoch] ||= Hash.new
        ret[obj]["_GPE_timestamp"][epoch] = epoch
      end
      Galileo.log.warn "Error parsing config file #{config[:file]} row and #{skipped_rec} record(s) skipped." if skipped_rec > 0
      return ret
    end

    def convert_to_base_data(parse_data, base_data, type_suffix="")
      parse_data.each do |pretype, objects|
        next if objects.empty?
        type = "#{pretype}#{type_suffix}"
        base_data.add_types type unless base_data.type_exist?(type)
        names = objects.keys.sort
        attributes = gather_attributes(objects)
        merged = merge_objects(objects, names, attributes)
        base_data.add_attributes type, attributes
        base_data.add_objects type, names
        merged.keys.each do |attr|
          merged[attr].keys.each do |time|
            base_data.add_trend(type, attr, time, merged[attr][time])
          end
        end
      end
      return base_data
    end

    def merge_objects(objects, names, attributes)
      ret = Hash.new
      attributes.each do |attr|
        ret[attr] ||= Hash.new
        names.each_index do |index|
          name  = names[index]
          next if objects[name][attr].nil?
          objects[name][attr].keys.each do |time|
            ret[attr][time] ||= Array.new(names.length, nil)
            ret[attr][time][index] = objects[name][attr][time]
          end
        end
      end
      return ret
    end

    def gather_attributes(objects)
      attributes  = Set.new
      objects.each_value do |data|
        attributes.merge(data.keys)
      end
      return attributes.to_a
    end

  end

end; end
