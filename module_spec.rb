require 'rubygems'
require 'bundler'
require 'yaml'
require 'erb'
require 'ap'
require 'active_support/ordered_hash'


class String
  def is_number?
    true if Float(self) rescue false
  end
end


module Galileo; class ModuleSpecifier


  GALLERY = {
    'line' => 1,
    'area' => 3
  }

  def initialize(file, default_item_type = nil, update=false, postfix="")
    raise "ERROR: #{file} does not exist" unless File.exists? file
    @spec = create_ordered_hash(YAML.load_file( file ))
    raise "ERROR: #{file} is an invalid or empty YAML file" if @spec.nil?

    @default_item_type = default_item_type
    @postfix           = postfix
    @ignore_types      = @spec["existing_types"] || []
    @ignore_metrcs     = @spec["existing_metrics"] || []
    @ignore_tags       = @spec["existing_tags"]    || []
    @ignore_groups     = @spec["existing_groups"]  || []

    @update            = update

    extract_metrics
    extract_groups
    extract_charts
    extract_relationships
    extract_chart_update
    extract_group_update
  end

  def data_columns
    data_columns  = Hash.new
    @spec["objects"].keys.map{|type| data_columns[type] = Array.new}
    @metrics.each do |id, metric|
      name = metric[:name] || id
      if name == metric[:formula]
        data_columns[metric[:item_type]] ||= Array.new
        data_columns[metric[:item_type]] << "`#{name}` #{metric[:type]} DEFAULT NULL"
      end
    end

    return data_columns
  end

  def print_all_migrations(output=STDOUT)
    output ||= STDOUT
    print_template_migration    ( output )
    print_metrics_migration     ( output )
    print_groups_migration      ( output )
    print_charts_migration      ( output )
    print_chart_update_migration ( output )
    print_group_update_migration ( output )
  end

  def print_template_migration(output=STDOUT)
    output ||= STDOUT
    output.puts proc_template("template_migration.erb")
  end

  def print_metrics_migration(output=STDOUT)
    output ||= STDOUT
    output.puts proc_template("metrics_migration.erb")
  end

  def print_charts_migration(output=STDOUT)
    output ||= STDOUT
    output.puts proc_template("charts_migration.erb")
  end

  def print_chart_update_migration(output=STDOUT)
    output ||= STDOUT
    output.puts proc_template("chart_update_migration.erb")
  end

  def print_group_update_migration(output=STDOUT)
    output ||= STDOUT
    output.puts proc_template("group_update_migration.erb")
  end

  def print_groups_migration(output=STDOUT)
    output ||= STDOUT
    tags  = @groups.values.map{|g| g[:tags]}.flatten.uniq
    @tags = Hash.new
    tags.each do |tag|
      @tags[tag] = {
        :parts => tag.split("@").flatten,
        :tname => tag.split("@").flatten.join("_").downcase+"_tag",
        :vname => tag.split("@").flatten.join("_").downcase+"_tag_obj",
      }
    end
    output.puts proc_template("groups_migration.erb")
  end

private

  def proc_template(filename)
    template =  Dir.glob(File.dirname(__FILE__) + "/templates/#{filename}").first
    raise "ERROR: Failed to find <#{filename}> template file" if template.nil?
    return ERB.new(File.read(template), nil, "-").result(binding)
  end

  def extract_relationships
    @relationships = Hash.new
    if @spec["objects"].nil?
      @relationships = {@default_item_type => nil}
    else
      @spec["objects"].each do |name, vals|
        @relationships[name] = vals["parents"]
      end
      # @relationships  = @spec["parents"]
    end
  end

  def extract_chart_update
    @chart_update = Hash.new
    unless @spec["chart_update"].nil?
      @chart_update = @spec["chart_update"]
    end
  end

  def extract_group_update
    @group_update = Hash.new
    unless @spec["group_update"].nil?
      @group_update = @spec["group_update"]
    end
  end

  def create_chart(chart_name, chart_id, group_name, chart, chart_defaults, group_defaults, chart_order=100, chart_overwrites={}, desc_prefix="")
    chart_defaults ||= Hash.new
    group_defaults ||= Hash.new
    stored_chart  = {
      :id         => chart_id,
      :name       => "#{chart_name}",
      :desc       => "#{desc_prefix}#{chart_overwrites["desc"]      || chart["desc"]      || chart_defaults["desc"]      || chart_name}",
      :group      => group_name,
      :order      => chart_overwrites["order"]        || chart["order"]        || chart_defaults["order"]        || group_defaults["order"]     || chart_order,
      :status     => chart_overwrites["chart_status"] || chart["chart_status"] || chart_defaults["chart_status"] || 1,
      :item_type  => chart_overwrites["item_type"]    || chart["item_type"]    || chart_defaults["item_type"]    || group_defaults["item_type"] || @default_item_type,
      :tags       => chart_overwrites["tags"]         || chart["tags"]         || chart_defaults["tags"]         || group_defaults["tags"]      || @default_tags       || [],
      :rules      => chart_overwrites["rules"]        || chart["rules"]        || chart_defaults["rules"]        || group_defaults["rules"]     || [],
      :properties => [],
      :series => []
    }

    chart_defaults.keys.select{|k| k =~ /^\$/}.each do |prop|
      stored_chart[:properties] << {
        :name => prop[1..-1],
        :value => chart_defaults[prop]
      }
    end

    addprops = {}
    chart_overrides = []
    chart.keys.select{|k| k =~ /^\$/}.each do |prop|
      prop_name = prop[1..-1]
      chart_overrides << prop_name
      if prop == "$_Repeat" and chart[prop].is_a? String
        ap @charts.keys if @charts[chart[prop]].nil?
        ap @groups.keys if @charts[chart[prop]].nil?
        raise "Chart not defined before _Repeat property: #{chart[prop]}" if @charts[chart[prop]].nil?
        stored_chart[:properties] << {
          :name => prop_name,
          :value => @charts[chart[prop]][:id]
        }
      else
        addprops.store(prop_name,chart[prop])
        addprops.delete(prop_name) if chart[prop].nil?
      end
    end

    # Remove any defaults that we overrode in the chart
    #cleaned = []
    #stored_chart[:properties].each{ |h| cleaned << h unless chart_overrides.include?(h[:name]) }
    #stored_chart[:properties] = cleaned += addprops.map{ |k,v| { name: k, value: v } }

    chart_overwrites.keys.select{|k| k =~ /^\$/}.each do |prop|
      stored_chart[:properties] << {
        :name => prop[1..-1],
        :value => chart_overwrites[prop]
      }
    end

    series_defaults = chart["series"]["_defaults"] || Hash.new

    order = 1
    order_hc  = chart["series"].keys.reject{|k| k =~ /^_/}.length

    chart["series"].each do |series_name, series|
      next if series_name =~ /^_/
      galery  = chart_overwrites["display"] || series["display"] || series_defaults["display"] || chart_defaults["display"] || "line"
      stacked = if chart_overwrites.key?    "stacked"
                  chart_overwrites[         "stacked"]
                elsif series.key?           "stacked"
                  series[                   "stacked"]
                elsif series_defaults.key?  "stacked"
                  series_defaults[          "stacked"]
                elsif chart_defaults.key?   "stacked"
                  chart_defaults[           "stacked"]
                else
                  false
                end

      raise "Metric not defined: #{series_name}" if @metrics[series_name].nil?
      stored_chart[:series] << {
        :order                  => order,
        :order_hc               => order_hc,
        :metric                 => @metrics[series_name][:name],
        :gallery_type           => GALLERY[galery],
        :stack_type             => stacked ? 1 : 0,
        :axis_y                 => series["axis_y"]              || series_defaults["axis_y"]              || chart_defaults["axis_y"]              || group_defaults["axis_y"]              || 1,
        :aggregate_function     => series["aggregate_function"]  || series_defaults["aggregate_function"]  || chart_defaults["aggregate_function"]  || group_defaults["aggregate_function"]  || nil,
        :aggregate_item_type    => series["aggregate_item_type"] || series_defaults["aggregate_item_type"] || chart_defaults["aggregate_item_type"] || group_defaults["aggregate_item_type"] || nil,
        :aggregate_filter       => series["aggregate_filter"]    || series_defaults["aggregate_filter"]    || chart_defaults["aggregate_filter"]    || group_defaults["aggregate_filter"]    || nil,
        :color                  => series["color"]               || series_defaults["color"]               || chart_defaults["color"]               || group_defaults["coloer"]              || nil
      }
      order    += 1
      order_hc -= 1
    end

    conditions = chart["conditions"] || chart_defaults["conditions"] || Hash.new
    stored_chart[:conditions] = conditions.values.map do |condition|
      {
        :con          => condition["con"],
        :message      => condition["message"],
        :message_code => condition["message_code"],
        :act          => condition["act"]
      }
    end

    return stored_chart
  end

  def extract_charts
    @charts  = Hash.new
    chart_id = 0
    unless @spec["chart_options"].nil?
      chart_id = @spec["chart_options"]["start_id"].to_i
    end
    return if @spec["groups"].nil?
    group_defaults  = @spec["groups"]["_defaults"]
    @spec["groups"].each do |group_name, group|
      next if group.nil? or group_name =~ /^_/
      chart_defaults  = group["_defaults"] || Hash.new
      chart_order     = 100
      group.each do |chart_name, chart|
          next if chart_name =~ /^_/
          prefix          = ""
          series_defaults = chart["_series_defaults"] || {}
          chart_name      = "#{group_name}_#{chart_name}"
          unless group["_prefix"].nil?
            prefix      = "#{group["_prefix"]} " unless group["_prefix"].nil?
          end
          chart["series"] ||= Hash.new
          @charts[chart_name] = create_chart(chart_name, chart_id, group_name, chart, chart_defaults, group_defaults, chart_order, series_defaults, prefix)
          chart_order =  @charts[chart_name][:order] + 10
          chart_id  += 1
      end
    end
  end


  def extract_groups
    @groups = Hash.new
    return if @spec["groups"].nil?

    groups     = @spec["groups"]
    defaults   = groups["_defaults"] || Hash.new
    order      = 20
    incr_order = 10

    groups.each do |group_name, group|
      next if group_name =~ /^_/
      next if @ignore_groups.include? group_name
      group = Hash.new if group.nil?
      @groups[group_name] = {
        :name       => group_name,
        :desc       => group["_desc"] || defaults["desc"] || group_name,
        :order      => group["_order"] || defaults["order"] || order,
        :status     => 1,
        :tags       => group["_tags"] || defaults["tags"] || @default_tags || []
      }
      order += incr_order
    end
  end

  def extract_metrics
    @metrics       = Hash.new
    unless @spec["metrics"].nil?
      defaults  = @spec["metrics"]["_defaults"] || Hash.new
      @spec["metrics"].each do |metric_name, metric|
        next if metric_name =~ /^_/
        name = metric["name"] || defaults["name"] || metric_name
        @metrics[metric_name] = {
          :name       => name,
          :desc       => metric["desc"] || defaults["desc"] || metric_name,
          :units      => metric["units"] || defaults["units"] || nil,
          :status     => '1',
          :formula    => metric["formula"] || defaults["formula"] || name,
          :type       => metric["type"] || defaults["type"] || "DECIMAL(18,5)",
          :item_type  => metric["item_type"] || defaults["item_type"] || @default_item_type
        }
      end
    end

    unless @spec["groups"].nil?
      @spec["groups"].each do |group_name, group|
        next if group.nil? or group_name =~ /^_/
        group.each do |chart_name, chart|
          next if chart_name =~ /^_/
          next if chart.nil? or chart["series"].nil?
          defaults  = chart["series"]["_defaults"] || Hash.new
          chart["series"].each do |series, params|
            next if series =~ /^_/
            next unless @metrics[series].nil?
            next if @ignore_metrcs.include? series
            met_name  = params["name"] || series
            next if metric_already_declared(met_name, @metrics)
            @metrics[series] = {
              :name       => params["name"] || series,
              :desc       => params["desc"] || defaults["desc"] || series,
              :units      => params["units"] || defaults["units"] || nil,
              :status     => '1',
              :formula    => params["formula"] || defaults["formula"] || series,
              :item_type  => params["item_type"] || defaults["item_type"] || @default_item_type
            }
          end
        end
      end
    end

    @metrics.values.each do |metric|
      expand_metric(metric, @metrics)
    end

  end

  def metric_already_declared(name, metrics)
    return (metrics.values.select{|m| m[:name] == name}.length > 0)
  end

  IGNORE_METRIC_NAMES = %w{IF CAST AS DEC AND OR NOT IFNULL UNSIGNED CASE WHEN THEN END COALESCE}

  def expand_metric(metric, metrics)
    return metric if metric[:expanded] or metric[:name] == metric[:formula]
    raise "Cyclical reference by metric <#{metric[:name]}>" if metric[:expanding]

    vars  = metric[:formula].scan(/([\w_0-9]+)/).flatten.uniq
    metric[:expanding]  = true
    vars.each do |var|
      next if var.is_number?
      next if IGNORE_METRIC_NAMES.include? var.upcase
      next if var.upcase == 'NULL'
      raise "Failed to find metric <#{var}>, referenced by <#{metric[:name]}>" if metrics[var].nil?
      sub = var
      sub = expand_metric(metrics[var], metrics) unless metrics[var].nil?
      metric[:formula].gsub!(var, "CAST(#{sub[:formula]} AS #{metric[:type] || "DEC(18,5)"})") unless sub[:name] == sub[:formula] and sub[:name] == var
    end
    metric[:expanding] = false
    metric[:expanded]  = true
    return metric
  end

  def create_ordered_hash(data)
    if data.is_a? Hash
      ret = Hash.new
      data.keys.each do |key|
        ret[key] = create_ordered_hash(data[key])
      end
      return ret
    # elsif data.is_a? YAML::PrivateType
    #   ret = Hash.new
    #   data.value.each do |v|
    #     if v.is_a? Hash
    #       ordered_hash = create_ordered_hash(v.values.first)
    #       if v.keys.first.is_a? YAML::Syck::MergeKey
    #         ret =  ordered_hash
    #       else
    #         if ret[v.keys.first].nil?
    #           ret[v.keys.first] = create_ordered_hash(v.values.first)
    #         else
    #           ret[v.keys.first].merge!(ordered_hash)
    #         end
    #       end
    #     elsif v.is_a? Array
    #       ret = create_ordered_hash(v[1])
    #     end
    #   end
    #   return ret
    else
      return data
    end
  end
end;end
