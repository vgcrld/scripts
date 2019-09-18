require 'sinatra'

set :port, 10888
set :bind, 0

get '/frank' do
  'Boi'
end
