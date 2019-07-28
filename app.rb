require 'sinatra'
require 'sinatra/reloader'
require 'fileutils'

set :public_folder, 'Public'

get '/' do
    erb :index
end