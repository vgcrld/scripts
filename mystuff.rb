module MyStuff

  def self.stuff(say_hello: "you")
    puts "Hello, " + say_hello
  end

  class Worker
    attr_reader :name, :age
    def initialize(name: :unavail, age: nil)
      @name = name
      @age = age
    end
    def work
      (number = rand(10)).times do |i|
        puts @name
      end
      puts "Is #{@age} years old."
      return number
    end
  end

end
