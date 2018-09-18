

require 'awesome_print'

class Mailer

  def self.deliver(&block)
    mail = MailBuilder.new(&block).mail
    mail.send_mail
  end

  Mail = Struct.new(:from, :to, :subject, :body) do
    def send_mail
      fib(30)
      puts "Email from: #{from}"
      puts "Email to  : #{to}"
      puts "Subject   : #{subject}"
      puts "Body      : #{body}"
    end

    def fib(n)
      n < 2 ? n : fib(n-1) + fib(n-2)
    end
  end

  class MailBuilder

    def initialize(&block)
      @mail = Mail.new
      instance_eval(&block)
    end

    attr_reader :mail

    %w(from to subject body).each do |m|
      define_method(m) do |val|
        @mail.send("#{m}=", val)
      end
    end
  end

end

def sue(a)
  yield
end

sue(15) do |x|
  puts "'ok this is good #{x.class}'"
end

exit

x = Mailer.deliver do
  from    "vgcrld@gmail.com"
  to      "vgcrld@gmail.com"
  subject "Threading and Forking"
  body    "Some content"
end


