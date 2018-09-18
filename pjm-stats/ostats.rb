require 'awesome_print'

orcdb = nil
type = nil
db = {}

rep = File.new('stats.txt').readlines.map(&:chomp).map do |line|
  case line
  when /FILE: /
    orcdb = line.split(%r([./]))[6]
  when /^\w+ /
    type = line.split(" ").first
  when /^ +([\d.\d+]+ +)+/
    stats = line.split(" ").map{ |x| x.to_f }
    oa =  stats.last  # Overall
    if oa > 15 
      db[orcdb] ||= {}
      db[orcdb][type] ||= {}
      db[orcdb][type] = line.split(" ")
    end
  end
end

ap db.values.map(&:keys).flatten.sort.uniq



