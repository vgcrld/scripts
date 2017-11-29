require 'benchmark'

def fib(n)
    raise ArgumentError, "needs to be positive! n: #{n}" if n < 0
    Array.new(n, 1).tap do |seq|
      (2..seq.length-1).each do |idx|
      seq[idx] = seq[idx-1] + seq[idx-2]
      end if n > 2
    end
end


(0..10).each do |i|
    puts fib(i).inspect
end

begin
    fib(-1)
rescue => e
    puts e.inspect
end

puts fib(100000).inject(&:+)
puts Benchmark.realtime{ fib(200000).inject(&:+) }
