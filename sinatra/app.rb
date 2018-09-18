require 'sinatra'
require 'awesome_print'
require 'haml'

get "/" do
  "Hello World"
end

get "/tsm/query/:object" do
  haml :tsm
end

get "/:customer/data" do |o|
  "Hello, #{o}! How are you today?"
end

get "/:username" do
  ap params
  return "#{params}"
end

get "/user/:username" do
  haml :index
end

post "/user/:username" do
  payload = JSON.parse(request.body.read)
  return "We got your data #{payload["name"]}"
end

