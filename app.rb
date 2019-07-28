require 'sinatra'
require 'sinatra/reloader'
require 'fileutils'

set :public_folder, 'Public'

get '/' do
    erb :index
end

get '/login' do
    erb :login
end

post '/index' do
    # postのリクエストボディから値を取得
    @name = params[:name]
    @email = params[:email]
  erb :index
  end