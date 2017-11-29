

def foo
  puts "Caller length: #{caller.length}"
  bar
end

def bar
  baz
end

def baz
  foo
end

begin
  foo
rescue
  puts "here i am"
  puts $!
  puts caller[0..100]
end
