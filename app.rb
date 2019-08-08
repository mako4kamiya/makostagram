#####
#ライブラリの読み込み
#####
require 'sinatra' #sinatraの読み込み
require 'sinatra/reloader' #リローダーの読み込み
require 'fileutils' #静的
require 'sinatra/cookies' #クッキーを使います。
require 'pg' #PostgreSQLを使えるようにします。


#####
#sinatraの設定
####
set :public_folder, 'Public'
enable :sessions #セッションを使います

#####
#DB接続
####
def db
  host = 'localhost'
  user = 'kamiyamasako' #自分のユーザー名を入れる
  password = ''
  dbname = 'makostagram'
  
  # PostgreSQL クライアントのインスタンスを生成
  PG::connect(
  :host => host,
  :user => user,
  :password => password,
  :dbname => dbname)
end

#####
#ルーティン
####
get '/' do
  if session[:user_id].nil? == true #セッションが空ならsigninを読み込む
      erb :signin
  else #セッションがあったらindexを読み込む
      redirect 'index'
  end

get '/signup'
end
post '/signup'
end


get '/signin'
end
post '/signin'
end


get '/post'
end
post '/post'
end


post '/like'
end
post '/dislike'
end


get '/following'
end
get '/followed'
end
get '/follow'
end
post '/follow'
end
get '/unfollow'
end
post '/unfollow'
end


get '/profile'
end
post '/upload'
end
