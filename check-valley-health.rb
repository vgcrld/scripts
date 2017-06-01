require 'ap'

UUIDS = [
  'valley_health:205a0126-5e05-4337-b0ac-096b358e3277',
  'valley_health_meditech:c5abe757-9697-4d6a-a36b-f78f72efb5bb',
  'valley_health_meditech:3eb4f461-30fc-49c6-9b66-bee6836b11af',
]

output = {}

UUIDS.map do |info|
  site, uuid = info.split(":",2)
  output[site] ||= {}
  folder = "/share/prd01/process/*/archive/by_uuid/#{uuid}/*.gpe.gz"
  output[site][uuid] = Dir.glob(folder).map{ |file| Time.now.to_i - File.ctime(file).to_i }.sort.first / 60
end

too_old = output.values.map{ |v| v.values }.flatten.select{ |x| x > 30}

if too_old.empty?
  puts "There is nothing too old."
else
  ap output
end

