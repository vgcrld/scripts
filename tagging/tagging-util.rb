#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'trollop'
require 'csv'
require 'json'
require 'uri'
require 'net/http'
require 'openssl'
require 'ap'

def download_options
  opts = Trollop::options do
    opt :token,    "Galileo user token",        type: :string,   required: true
    opt :site,     "Site to apply tagging to",  type: :string,   required: true
    opt :url,      "The base URL to galileo",   type: :string,   required: true
    opt :file,     "Filename to create",        type: :string,   required: false,   default: "tagging-export-#{Time.now.to_i}.csv"
  end
  return opts
end

def online_options
  opts = Trollop::options do
    opt :token,               "Galileo user token",                                                         type: :string,   required: true
    opt :site,                "Site to apply tagging to",                                                   type: :string,   required: true
    opt :url,                 "The base URL to galileo",                                                    type: :string,   required: true
    opt :execute,             "Execute the prepared plan",                                                  type: :boolean,  required: false
  end
  return opts
end

def compare_options
  opts = Trollop::options do
    opt :token,               "Galileo user token",                                                         type: :string,   required: false
    opt :site,                "Site to apply tagging to",                                                   type: :string,   required: false
    opt :url,                 "The base URL to galileo",                                                    type: :string,   required: false
    opt :file,                "File to be compared",                                                        type: :string,   required: true
    opt :old,                 "Old File to be compared",                                                    type: :string,   required: true
  end
end

def upload_options
  opts = Trollop::options do
    opt :token,               "Galileo user token",                                                         type: :string,   required: true
    opt :site,                "Site to apply tagging to",                                                   type: :string,   required: true
    opt :url,                 "The base URL to galileo",                                                    type: :string,   required: true
    opt :file,                "Filename to create",                                                         type: :string,   required: true
    opt :item_id_column,      "Column to use to identify an item",                                          type: :string,   required: false,  short: 'i', default: 'ID'
    opt :item_id_property,    "Property to use to identify an item",                                        type: :string,   required: false,  short: 'I', default: 'item_id'
    opt :parent_id_column,    "Column to use to identify the parent of an item",                            type: :string,   required: false,  short: 'p'
    opt :parent_id_property,  "Column to use to identify the parent of an item",                            type: :string,   required: false,  short: 'P'
    opt :ignore_columns,      "Column to ignore",                                                           type: :string,   required: false,  multi: true
    opt :execute,             "Execute the prepared plan",                                                  type: :boolean,  required: false
    opt :force,               "Force Upload even if tags were not already created",                         type: :boolean,  required: false
    opt :details,             "Show upload details",                                                        type: :boolean,  required: false
    opt :filter,              "Show this match (regexp) only (if details)",                                 type: :string,   required: false
  end

  opts[:ignore_columns] = ['vCenter','Datacenter','Cluster','Host','Name','Dups','Type','Last Reported','Status','Tag Count'] if opts[:ignore_columns].empty?

  Trollop::die :file, "must exist" unless File.exist?(opts[:file]) if opts[:file]

  if (opts[:parent_id_column].nil? and !opts[:parent_id_property].nil?) or (!opts[:parent_id_column].nil? and opts[:parent_id_property].nil?)
    Trollop::die "--parent_id_column and --parent_id_property must either be both provided or both ignored"
  end
  return opts
end

def read_csv(file)
  begin
    csv_data  = CSV.read(file, {:headers => true})
  rescue Exception => e
    puts "Unable to process CSV file: #{e}"
    exit 1
  end
  return csv_data
end

def process_tag_file(file,opts)

  unless File.exist?(file)
    puts "#{file} does not exist!"
    return
  end

  csv_data = read_csv(file)

  groups  = csv_data.headers
  groups -= opts[:ignore_columns]
  groups -= [opts[:item_id_column]]
  groups -= [opts[:parent_id_column]]
  groups -= [ "ID" ]
  groups -= [ "Name" ]

  item_identity = { opts[:item_id_property] => opts[:item_id_column] }

  item_identity[opts[:parent_id_property]] = opts[:parent_id_property] unless opts[:parent_id_column].nil?

  tags  = Hash.new

  total = csv_data.length
  count = 0
  csv_data.each do |row|
    item  = {}
    item_identity.each do |key, col|
      item[key] = row[col]
    end

    groups.each do |group|
      tag_strings = row[group]

      # Change value of '-' to nil; same as empty from table export
      tag_strings = tag_strings == "-" ? nil : tag_strings

      next if tag_strings.nil?

      tag_strings = tag_strings.split('||')

      tag_strings.each do |tag|

        # Remove unprintable chars
        if tag.match( /[^[:print:]]/)
          puts "WARNING: Replacing unprintable characters in '#{tag}' with spaces."
          tag.gsub!(/[^[:print:]]/," ")
        end

        # Remove extra spaces and trailing spaces
        tag = tag.strip.squeeze(" ")

        # Remove any quotes characters
        tag.gsub!(/"/,"")

        # If the group is Not Categorized then set it to "" to upload without a category
        if group == "Not Categorized"
          group = ""
          tag_id  = "#{tag}"
        else
          tag_id  = "#{group}:#{tag}"
        end

        tags[tag_id] ||= {:tag => tag, :group => group, :items => []}
        tags[tag_id][:items] << item

      end
    end

    count += 1
  end

  tags = filter_tags(tags,opts[:filter]) if opts[:filter]

  return tags

end

def show_tag_plan(tags,opts)
  if opts[:details] then
    detail = tag_items_by_tagname(tags,opts)
    detail.each do |t,i|
      puts "Tag Name: " + t
      i.each{ |item| puts "\t" + item }
      puts ""
    end
  else
    puts(sprintf("%6s   %s\n","Items", "Category:Tag Name"))
    tags.keys.sort.each do |tag|
      puts(sprintf("%6d - %s\n",tags[tag][:items].length, tag))
    end
  end
  return tags.keys
end

def filter_tags(tags,filter=nil)
  return tags.select{ |t,i| t.match /#{filter}/i }
end

def tag_items_by_tagname(tags,opts)
  ret = {}
  tags.keys.map do |t|
    ret[t] = tags[t][:items].map{ |x| x[opts[:item_id_property]] }
  end
  return ret.sort
end

def delete_tags(opts,tags)

  unless opts[:execute]
    list = tags.keys
    list.each{ |x| puts "Delete Tag: " + x }
    puts "Nothing Deleted!  Must Execute (-e)."
    return tags.keys
  end

  api_pre = "api/v1"
  http = get_http(opts[:url])
  tag_list = tags.keys
  if tag_list.empty?
    puts "No tags defined to delete"
    return
  end
  delete_urls = tag_list.map do |label|
    url = URI.escape("/#{opts[:site]}/api/v1/tags/#{label}?mode=site&t=#{opts[:token]}")
    res = http.delete(url)
    if res.code == "200"
      puts "Deleted Tag: #{label}"
    else
      puts "Failed to delete tag: #{label}"
    end
  end
  return tags.keys
end

def execute_upload(opts,tags,command)

  tag_list = show_tag_plan(tags,opts)

  unless opts[:execute]
    puts "Nothing Uploaded!  Must Execute (-e)."
    return tag_list
  end

  api_pre = "api/v1"

  url = URI.escape("/#{opts[:site]}/#{api_pre}/actions/tags/tag_objects?t=#{opts[:token]}&create_tags=try&reset=true")

  count = 0
  total = tags.length

  http = get_http(opts[:url])

  tags.values.each do |defn|

    # Build a list of objects
    tag_objects = []
    defn[:items].each_index do |i|
      defn[:items][i].each do |key, value|
        tag_objects << { "#{opts[:item_id_property]}" => value }
      end
    end

    label = replace_invalid_chars_with_space(defn[:tag])
    group = replace_invalid_chars_with_space(defn[:group])

    # Create the request
    request_json = {
      "tags" => [
        {
          "label"      => label,
          "group"      => group,
          "selectable" => true,
          "vframe"     => true
        }
      ],
      "objects"        => tag_objects
    }.to_json

    res = http.post(url, request_json, { 'Content-Type' => 'application/json' } )

    if res.code.to_i != 200
      STDERR.puts "ERROR processing: #{defn[:group]}:#{defn[:tag]} - returned #{res.code.to_i}"
    else
      STDOUT.puts "Success! #{group}:#{label}"
    end

    count += 1

    print "#{' '*100}\r"
    print "---POSTED: #{count} out of #{total}\r"
  end
  puts "\n"
  puts "DONE"

  return tags.keys
end

def replace_invalid_chars_with_space(value)
  replace_chars = %w[ / ].join
  regexp = Regexp.new("[#{replace_chars}]")
  replacement = value.gsub(regexp) do |match|
    STDERR.puts "Invalid Character!  Replacing '#{match}' in '#{value}' with ' '."
    " "
  end
  return replacement
end

def get_http(url, attempt=10)

  raise "Too Many Redirect Attempts" if attempt == 0

  uri = URI(url)
  addr = uri.host
  port = uri.port
  http = Net::HTTP.new(addr,port)

  if uri.scheme.eql? "https" then
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.read_timeout=300
    # http.ssl_version = :SSLv3
    # http.ciphers = ['DES-CBC3-SHA']
  else
    http.use_ssl = false
  end

  res  = http.get("/login", @headers)
  if res.code.to_i == 200
    return http
  elsif res.code.to_i == 302
    return get_http(res['location'], attempt-1)
  else
    raise "Got an unhandled error when trying to access page: #{res.code}"
  end
end

# Pull data from: https://xxxx.galileosuite.com/CUSTOMER/table/nil/TaggingExportAssetsTable.datatable?timezone=EST5EDT&dao=TaggingExportAssetsTableDAO
def get_tagging_file(opts)
  outfile = opts[:file]
  begin
    File.delete(outfile) if File.exist?(outfile)
    http = get_http(opts[:url])
    res  = http.get("/#{opts[:site]}/table/nil/TaggingExportAssetsTable.csv?dao=TaggingExportAssetsTableDAO&t=#{opts[:token]}")
    if res.code == "200"
      File.open(outfile, 'w') { |file| file.write(res.body) }
      puts "Created: #{outfile}"
    else
      raise "Unable to get file from server: #{res}"
    end
  rescue Exception => e
    puts "Error: #{e.message}"
    return false
  end
  return outfile
end

def get_available_groups(opts)
  http = get_http(opts[:url])
  uri = URI.escape("/#{opts[:site]}/api/v1/tag_groups?t=#{opts[:token]}")
  res = http.get(uri)
  return JSON.parse(res.body)["data"].select{ |group| group["mode"] == 'site' }.map{ |group| group['id'] }
end

def get_available_tags(opts)
  http = get_http(opts[:url])
  uri = URI.escape("/#{opts[:site]}/api/v1/tags?t=#{opts[:token]}")
  res = http.get(uri)
  return JSON.parse(res.body)["data"].select{ |group| group["mode"] == 'site' }.map{ |group| group['id'] }
end

def delete_objects(opts,objects,type)
  http = get_http(opts[:url])
  objects.each do |obj|

    case type
    when :group
      uri = URI.escape("/#{opts[:site]}/api/v1/tag_groups/#{obj}?t=#{opts[:token]}")
    when :tag
      uri = URI.escape("/#{opts[:site]}/api/v1/tags/#{obj}?t=#{opts[:token]}")
    else
      raise "invalid call to delete objects"
    end

    if opts[:execute]
      res = http.delete(uri)
      puts "Deleted: #{obj}"
    else
      puts "Not Deleted: #{obj}"
    end
  end
    puts "Use execute (-e) to delete." unless opts[:execute]
  return
end

def get_data(tag_data,tag,get="ID")
  return tag_data[tag].each_with_index.map{ |x,i| tag_data[i][get] }
end

def tags_not_found_online?(tags,available,opts)
  ret = true
  data = { true => [], false => [] }
  tags.keys.each do |tag|
    data[available.include?(tag)] << tag
  end
  if data[false].empty?
    ret = false
    puts "OK! All tags in file are already created at #{opts[:url]}."
  else
    puts "\nThese tags must be created online before you can proceed or use --force option.\n\n"
    data[false].sort.each{ |t| puts "\t'#{t}'" }
  puts "\n"
  end
  return ret
end

# Remove compare_files as an option until it can be completed
#SUB_COMMANDS = %w[download upload delete_file_tags delete_online_groups delete_online_tags compare_files]
SUB_COMMANDS = %w[download upload delete_file_tags delete_online_groups delete_online_tags]

global_opts = Trollop::options do
    banner "Galileo Tag Utility"
    stop_on SUB_COMMANDS
end

command = ARGV.shift

unless SUB_COMMANDS.include?(command)
  puts "Invalid Command! Use: #{SUB_COMMANDS.join(' | ')}"
  exit 1
end

case command
when 'delete_online_groups'
  opts = online_options
  groups = get_available_groups(opts)
  done = delete_objects(opts,groups,:group)
when 'delete_online_tags'
  opts = online_options
  tags = get_available_tags(opts)
  done = delete_objects(opts,tags,:tag)
when 'download'
  opts = download_options
  file = get_tagging_file(opts)
when 'upload'
  opts = upload_options
  existing = get_available_tags(opts)
  tags = process_tag_file(opts[:file],opts)
  if tags_not_found_online?(tags,existing,opts)
    if opts[:force]
      puts "--force provided!  Will create tags not already found on #{opts[:url]}"
    else
      raise "Stopping. Destintation tags were not found online." unless opts[:force]
    end
  end
  list = execute_upload(opts,tags,command)
when 'delete_file_tags'
  opts = upload_options
  tags = process_tag_file(opts[:file],opts)
  list = delete_tags(opts,tags)
when 'compare_files'
  opts = compare_options
  tags0 = read_csv(opts[:old])
  tags1 = read_csv(opts[:file])
else
  Trollop::die "Command '#{command}' is invalid!  Use #{SUB_COMMANDS.join(", ")}" unless SUB_COMMANDS.include?(command)
end

