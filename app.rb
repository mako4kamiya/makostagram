require 'sinatra'
require 'sinatra/reloader'

set :public_folder, 'Public'

get '/' do
    "<h1>hello world!</h1>"
end