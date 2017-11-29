

require 'English'
require 'awesome_print'
require 'ostruct'

class Array
  def to_data(string="", type: :ostruct)
    begin
      reg = Regexp.new(self.join)
      match = string.match(reg)
      case type
      when :ostruct
        return match_to_ostruct(match)
      when :hash
        return match_to_hash(match)
      else
        return nil
      end
    rescue RegexpError => e
      return { _regex_error: e.message }
    rescue NoMethodError => e
      return { _error: e.message }
    end
  end

  def match_to_hash(match)
    ret = Hash.new(nil)
    names = match.names
    vals  = match.captures
    names.each{ |name| ret[name.to_sym] = vals[names.index(name)] }
    return ret
  end

  def match_to_ostruct(match)
    ret = Hash.new
    names = match.names
    vals  = match.captures
    names.each{ |name| ret[name.to_sym] = vals[names.index(name)] }
    return OpenStruct.new(ret)
  end


end

data = %w[ (?<all> (?<some> (?<name>.*), (?<age>\d*),) (?<grade>.*)) ]
  .to_data("rich,45,grad")

ap data.name

# This is a cool feature of ruby.  Read below __END__ as input data. 
#ap DATA.readlines.map{ |line| line.chomp }

__END__
here is some data
that can be include
into the same file
exit
