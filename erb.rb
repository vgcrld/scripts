require 'awesome_print'
require 'erb'

ap ERB.new("Hello, today is <%=Time.now.strftime('%A')%>.").result
