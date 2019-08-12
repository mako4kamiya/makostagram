#####
#ライブラリの読み込み
#####
require 'sinatra' #sinatraの読み込み
require 'sinatra/reloader' #リローダーの読み込み
require 'fileutils' #ファイル操作のモジュール
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

#セッションがあるかどうかの確認
get '/' do
  if session[:user_id].nil? == true #セッションが空ならsigninを読み込む
      redirect 'signin'
  else #セッションがあったらindexを読み込む
      redirect 'index'
  end
end

###サインアップ（新規登録）画面###
#/signupにアクセスすると、サインアップ（新規登録）画面が表示される。
get '/signup' do
  erb :signup, :layout => :signup #signupのレイアウトを使う
end
post '/signup' do
  name = params[:name]
  email = params[:email]
  password = params[:password]
  db.exec("INSERT INTO users(name, email, password) VALUES($1,$2,$3)",[name,email,password])
  redirect '/signin'
end

###サインイン画面###
#/signinにアクセスすると、サインイン画面が表示される。
get '/signin' do
  erb :signin, :layout => :signin #signinのレイアウトを使う
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

####home(index画面)###
#/index にアクセスすると、みんなの掲示板の内容一覧と投稿画面が表示される
get '/index' do
  if session[:user_id].nil? == true #セッションが空ならsigninを読み込む
    redirect 'signin'
  else #セッションがあればindexを読み込む
    active_user = session[:user_id]
    users_name = db.exec("SELECT name FROM users WHERE id = $1",[active_user]).first
    @name = users_name['name']
    @posts = db.exec("SELECT * FROM posts")

    pf_img = db.exec("SELECT profile_image FROM profile_images WHERE user_id =$1 ORDER BY id DESC",[active_user]).first
    if pf_img.nil? == true
      user_png = "user.png"
      db.exec("INSERT INTO profile_images(profile_image,user_id) VALUES($1,$2)",[user_png,active_user])
      redirect 'index'
    end
    @profile_image = pf_img['profile_image']
    erb :index
  end
end

post '/index' do
  ##画像とcomment投稿##
  active_user = session[:user_id]
  users_name = db.exec("SELECT name FROM users WHERE id = $1",[active_user]).first
  name = users_name['name']
  file_name = params[:img][:filename]
  content = params[:content]
  db.exec("INSERT INTO posts(user_name,image,content,user_id) VALUES($1,$2,$3,$4)",[name,file_name,content,active_user])
  ##投稿画像をimagesフォルダへ保存する。##
  FileUtils.mv(params[:img][:tempfile], "./public/images/#{file_name}")
  
  redirect '/index'
end

get '/profile' do
    active_user = session[:user_id]
    users_name = db.exec("SELECT name FROM users WHERE id = $1",[active_user]).first
    @name = users_name['name']
    @profile_posts = db.exec("SELECT image FROM posts WHERE user_id =$1",[active_user])
    pf_img = db.exec("SELECT profile_image FROM profile_images WHERE user_id =$1 ORDER BY id DESC",[active_user]).first
    @profile_image = pf_img['profile_image']
    erb :profile
end
##profile画像を設定する。##
post '/profile' do
  active_user = session[:user_id]
  profile_file_name = params[:profile_img][:filename]
  db.exec("INSERT INTO profile_images (profile_image,user_id) VALUES($1,$2)",[profile_file_name,active_user])
  ##profile画像をprofile_imagesフォルダへ保存する。##
  FileUtils.mv(params[:profile_img][:tempfile], "./public/profile_images/#{profile_file_name}")
  redirect 'profile'
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


