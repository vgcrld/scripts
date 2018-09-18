require 'sinatra'

get "/" do
  "Hello World"
end

get "/tsm/query/:object" do
  obj = params[:object]
  "q #{obj} f=d"
end

get "/:customer/data" do |o|
  "Hello, #{o}! How are you today?"
end
