require 'awesome_print'

CHARS = %w[ / + ( ) ]
reg = CHARS.join
replace = Regexp.new("[#{reg}]")

value = "this is / a test of + some things"
after = value.gsub(replace) do |match|
  case match
  when "/"
    "<slash>"
  when "+"
    "<plus>"
  else
    "other"
  end
end

ap value
ap after

