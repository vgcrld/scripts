#!/usr/bin/env ruby

# 
#  Process the TSM gz files by extracting a single file and compile a csv.
#
require 'awesome_print'
require 'zlib'
require 'rubygems/package'
require 'optimist'
require 'logger'
require 'csv'

log = Logger.new(STDOUT)

opts = Optimist::options do 
  opt :matcher, "File Matcher", type: :string, require: true
  opt :skip, "Skip the first"
end

flist = {}
fname = {}

ARGV.each do |file|
  next unless file.match(/\.gz$/)
  log.info("Parsing file '#{file}'.")
  tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(file))
  tar_extract.rewind # The extract has to be rewinded after every iteration
  tar_extract.each do |entry|
    name = entry.full_name
    if name.match(/#{opts[:matcher]}/)
      if flist[name].nil?
        log.info "entry: #{name}"
        flist[name] = entry.read.lines.map(&:chomp)
        fname[name] = file
      else
        log.warn "Entry '#{name}' already exists, skipping."
      end
    end
  end
end

# Check the file selection
uniq_files = flist.keys.map{ |o| o.split('.')[0..-2] }.flatten.uniq
if uniq_files.length > 1 
  log.error "The files process are not all the same type. Ensure the matcher specified will only select a single type."
  log.error uniq_files.join(', ')
  exit 1
end


     rows = []
      rec = {}
  headers = Set.new
 head_set = false

names = flist.keys.sort
skipped = names.shift if opts[:skip]
log.warn "Skipping first file: '#{skipped}'" if opts[:skip]

names.each do |filename|
  flist[filename].each do |line|
    if line.empty?
      unless rec["ANR2034E SELECT"] or rec.empty?
        head = rec.keys
        row = CSV::Row.new(head,rec.values)
        rows << row
        headers << head
        head_set = true
      end
      rec = {}
    else
      col,val = line.split(': ',2)
      col.strip!
      rec[col] = val
    end
  end
end

if headers.empty?
  log.error "There does not appear to be any data in the set."
  exit 1
elsif headers.length != 1 
  require 'debug'
  log.error "Headers where inconsistent acroess all the records."
  ap headers
  exit 1
end

table = CSV::Table.new(rows)

filename = "output-#{opts[:matcher].gsub(/[^0-9a-z ]/i, '')}.csv"
output = File.new(filename,'w+')
output.write(table.to_csv)
output.close
