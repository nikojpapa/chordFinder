require 'sinatra'
require 'haml'
require 'net/http'
require 'json'

# set :bind, '0.0.0.0'
set :port, 8080
set :static, true

get '/' do
    haml :index
end































