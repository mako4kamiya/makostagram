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
#####セッションがあるかどうかの確認####
get '/' do
  if session[:user_id].nil? == true #セッションが空ならsigninを読み込む
      redirect 'signin'
  else #セッションがあったらindexを読み込む
      redirect 'index'
  end
end

#####サインアップ（新規登録）画面#####
#/signupにアクセスすると、サインアップ（新規登録）画面が表示される。
get '/signup' do
  erb :signup, :layout => :signup #signupのレイアウトを使う
end
post '/signup' do
  name = params[:name]
  email = params[:email]
  password = params[:password]
  default = "default_user.png"
  db.exec("INSERT INTO users(name, email, password,profile_image) VALUES($1,$2,$3,$4)",[name,email,password,default])
  redirect '/signin'
end


#####サインイン画面#####
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
    id = session[:user_id]
    redirect 'index'
  end
end


#####サインアウト#####
get '/signout' do
  session[:user_id] == nil
  redirect '/signin'
end


#####home(index画面)#####
#/index にアクセスすると、みんなの掲示板の内容一覧と投稿画面が表示される
get '/index' do
  if session[:user_id].nil? == true #セッションが空ならsigninを読み込む
    redirect 'signin'
  else #セッションがあればindexを読み込む
    @active_user = session[:user_id]
    users_name = db.exec("SELECT name FROM users WHERE id = $1",[@active_user]).first
    @name = users_name['name']
    # @posts = db.exec("SELECT posts.*,users.profile_image,likes.liked_by FROM posts JOIN users ON posts.user_id = users.id LEFT JOIN likes ON posts.id = likes.post_id ORDER BY id DESC")
    @posts = db.exec("
    SELECT posts.id,posts.user_id,posts.user_name,posts.image,posts.content,users.profile_image,like_me.liked_by
    From posts
    LEFT JOIN users ON posts.user_id = users.id
    LEFT JOIN (
      SELECT * 
      FROM likes 
      WHERE liked_by = $1)
      as like_me
    ON posts.id = like_me.post_id 
    ORDER BY id DESC",[@active_user])


      
    #プロフィール画像が設定されてるかどうか
    pf_img = db.exec("SELECT profile_image FROM users WHERE id =$1",[session[:user_id]]).first
    if pf_img.nil? == true
      default = "default_user.png"
      db.exec("INSERT INTO users(profile_image) VALUES($1)",[default])
      redirect 'index'
    else
      @profile_image = pf_img['profile_image']
      erb :index
    end
  end
end


#####投稿#####
post '/index' do
  ##画像とcomment投稿##
  users_name = db.exec("SELECT name FROM users WHERE id = $1",[session[:user_id]]).first
  name = users_name['name']
  file_name = params[:img][:filename]
  content = params[:content]
  db.exec("INSERT INTO posts(user_name,image,content,user_id) VALUES($1,$2,$3,$4)",[name,file_name,content,session[:user_id]])
  ##投稿画像をimagesフォルダへ保存する。##
  FileUtils.mv(params[:img][:tempfile], "./public/images/post_images/#{file_name}")
  puts "投稿しました"
  redirect '/index'
end
#####投稿消去#####
get '/delete/:id' do
  db.exec("DELETE FROM posts WHERE id = $1 AND user_id = $2",[params[:id],session[:user_id]])
  redirect '/index'
end


#####いいね機能#####
get '/like/:id' do
  db.exec("INSERT INTO likes(post_id,liked_by) VALUES($1,$2)",[params[:id],session[:user_id]])
  redirect '/index'
end
get '/dislike/:id' do
  db.exec("DELETE FROM likes WHERE post_id = $1 AND liked_by = $2",[params[:id],session[:user_id]])
  # db.exec("UPDATE posts SET liked_by = null WHERE liked_by = $1 AND id = $2",[session[:user_id],params[:id]])
  redirect '/index'
end
#####いいねー一覧#####
get '/liking' do
  @liking = db.exec("SELECT *FROM posts LEFT JOIN (SELECT likes.*,users.name,users.profile_image FROM likes LEFT JOIN users ON likes.liked_by = users.id) as wlyp ON wlyp.post_id = posts.id WHERE posts.user_id = $1 ORDER BY wlyp.id ASC",[session[:user_id]])
  erb :liking
end


#####フォロー機能#####
get '/follow/:id' do
  id = params[:id]
  db.exec("INSERT INTO follows (user_id,followed_by) VALUES($1,$2)",[params[:id],session[:user_id]])
  redirect '/index'
end
get '/unfollow/:id' do
  @id = params[:id]
  db.exec("DELETE FROM follows WHERE user_id = $1 AND followed_by= $2",[params[:id],session[:user_id]])
  redirect '/index'
end
#####フォロー一覧#####
get '/following' do
  
  @following = db.exec("SELECT users.id,users.name,users.profile_image,follows.followed_by from users LEFT JOIN follows ON users.id = follows.user_id WHERE followed_by = $1",[session[:user_id]])
  # @following = db.exec("SELECT users.id,users.name,users.profile_image,follows.followed_by  FROM users LEFT JOIN (SELECT * FROM follows WHERE followed_by = $1) as follows ON users.id = follows.user_id",[session[:user_id]])
  erb :following
end


#####プロフィール画面#####
get '/profile/:id' do
  @active_user = session[:user_id]
  @user_info = db.exec("
  SELECT
  DISTINCT ON (users.id)
  users.id,users.name,users.profile_image,posts.image,who_i_followed.followed_by
  FROM users
  LEFT JOIN posts ON users.id = posts.user_id
  LEFT JOIN (
    SELECT *
    FROM follows
    WHERE followed_by = $1)
    as who_i_followed 
  ON users.id = who_i_followed.user_id
  WHERE users.id = $2",[session[:user_id],params[:id]])
  @profile_posts = db.exec("SELECT image FROM posts WHERE user_id =$1 ORDER BY $1 DESC",[params[:id]])
  @following = db.exec("SELECT * FROM follows WHERE user_id = $1 AND followed_by = $2",[params[:id],session[:user_id]])
  erb :profile
end
##profile画像を設定する。##
post '/profile' do
  pf_img = db.exec("SELECT profile_image FROM users WHERE id =$1",[session[:user_id]]).first
  old_pf_img = pf_img['profile_image']#session[:user_id]のDB上のプロフィール名を取ってきて。old_pf_imgていう名前をつける
  puts old_pf_img
  new_pf_img = params[:profile_img][:filename]
  if old_pf_img.eql?('default_user.png') #old_pf_imgがdefault画像だったら、新しい画像を保存する。'== true'なくてもよさそう！
    FileUtils.mv(params[:profile_img][:tempfile], "./public/images/profile_images/#{new_pf_img}")
    puts "hi"
  else #old_pf_imgがdefaultじゃなかったら、新しい画像に書き換える。
    FileUtils.mv(params[:profile_img][:tempfile], "./public/images/profile_images/#{new_pf_img}")
    FileUtils.rm("./public/images/profile_images/#{old_pf_img}")
    puts "why"
  end
  db.exec("UPDATE users SET profile_image = $1 WHERE id = $2 AND profile_image = $3",[new_pf_img, session[:user_id], old_pf_img])
  puts "hogehoge"
  redirect 'index'
end
