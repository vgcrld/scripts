require 'sinatra'
require 'awesome_print'
require 'haml'

get "/" do
  "Hello World"
end

# Call a HAML template
get "/tsm/query/:object" do
  haml :tsm
end

# Here is an example of a request sending back json. 
get "/:customer/data" do 
  content_type :json
  { name: "rich", age: 48, data: [1,2,3] }.to_json
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

