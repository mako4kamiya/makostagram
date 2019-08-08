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

###サインアップ（新規登録）画面###
#/signupにアクセスすると、サインアップ（新規登録）画面が表示される。
get '/signup' do
  erb :signup
end
post '/signup' do
  name = params[:name]
  email = params[:email]
  password = params[:password]
  db.exec("INSERT INTO users(name, email, password) VALUES($1,$2,$3)",[name,email,password])
end

###サインイン画面###
#/signinにアクセスすると、サインイン画面が表示される。
get '/signin' do
  erb :signin
end
#signupで記入した内容がusersテーブルに保存される。
post '/signin' do
  name = params[:name]
  password = params[:password]
  users_id = db.exec("SELECT id FROM users WHERE name = $1 AND password = $2",[name,password]).first
  if users_id.nil? == true #signinで入力したnameとpasswordがusersテーブルに無ければ、signupを読み込む
    redirect 'signup'
  else #signinで入力したnameとpasswordがusersテーブルにあれば、その列のidをsessionに入れて、indexを読み込む。
    session[:user_id] = users_id['id'] #ハッシュ（id）を指定して、値(1とか)を持ってきてる。
    redirect 'index'
  end
end

#セッションがあるかどうかの確認
get '/' do
  if session[:user_id].nil? == true #セッションが空ならsigninを読み込む
      erb :signin
  else #セッションがあったらindexを読み込む
      redirect 'index'
  end
end

####home(index画面)###
#/index にアクセスすると、みんなの掲示板の内容一覧と投稿画面が表示される
get '/index' do
  if session[:user_id].nil? == true #セッションが空ならsigninを読み込む
    redirect 'signin'
  else #セッションがあればindexを読み込む
    active_user = session[:user_id]
    @posts = db.exec_params("SELECT * FROM posts")
    @active_user = db.exec("SELECT name FROM users WHERE id = $1",[active_user]).first
    erb :index
  end
end
##画像とcomment投稿##
post '/index' do
  active_user = session[:user_id]
  content = params[:content]
  users_name = db.exec("SELECT name FROM users WHERE id = $1",[active_user]).first
  @user_name = users_name['name']
  db.exec("INSERT INTO posts(user_id,content,user_name) VALUES($1,$2,$3)",[active_user,content,user_name])

  @file_name = params[:img][:filename]
  FileUtils.mv(params[:img][:tempfile], "./public/images/#{@file_name}")

  redirect '/index'
end


post '/like' do
  
end
post '/dislike' do
  
end


get '/following' do
  
end
get '/followed' do
  
end
get '/follow' do
  
end
post '/follow' do
  
end
get '/unfollow' do
  
end
post '/unfollow' do
  
end


get '/profile' do
  
end
post '/upload' do
  
end
