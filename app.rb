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
  default = "default_user.png"
  db.exec("INSERT INTO users(name, email, password,profile_image) VALUES($1,$2,$3,$4)",[name,email,password,default])
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
    id = session[:user_id]
    redirect 'index'
  end
end



####home(index画面)###
#/index にアクセスすると、みんなの掲示板の内容一覧と投稿画面が表示される
get '/index' do
  if session[:user_id].nil? == true #セッションが空ならsigninを読み込む
    redirect 'signin'
  else #セッションがあればindexを読み込む
    @active_user = session[:user_id]
    users_name = db.exec("SELECT name FROM users WHERE id = $1",[session[:user_id]]).first
    @name = users_name['name']
    # @posts = db.exec("SELECT posts.*,users.profile_image FROM posts JOIN users ON posts.user_id = users.id ORDER BY id DESC")
    @posts = db.exec("SELECT posts.*,users.profile_image,likes.liked_by FROM posts JOIN users ON posts.user_id = users.id LEFT JOIN likes ON posts.id = likes.post_id ORDER BY id DESC")

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

#####いいね機能
get '/like/:id' do
  default = "default"
  db.exec("INSERT INTO likes(post_id,liked_by) VALUES($1,$2)",[params[:id],session[:user_id]])
  redirect '/index'
end

get '/dislike/:id' do
  db.exec("DELETE FROM likes WHERE post_id = $1 AND liked_by = $2",[params[:id],session[:user_id]])
  # db.exec("UPDATE posts SET liked_by = null WHERE liked_by = $1 AND id = $2",[session[:user_id],params[:id]])
  redirect '/index'
end

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


get '/profile' do
  users_name = db.exec("SELECT name FROM users WHERE id = $1",[session[:user_id]]).first
  @name = users_name['name']
  @profile_posts = db.exec("SELECT image FROM posts WHERE user_id =$1",[session[:user_id]])
  pf_img = db.exec("SELECT profile_image FROM users WHERE id =$1",[session[:user_id]]).first
  @profile_image = pf_img['profile_image']
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
  redirect 'profile'
end

#######まこ#######
#さっきみてもらったとこ、えらーはなくなったんですが、
#どうやら、if likesの処理しかされないようです。。。
#テーブルに何も入ってなくても、if likesの処理がなされます。
#そうです！
#106行目に
#searchbox.jsにちょっとやったんですけど、
#クリックイベントで、表示は変えられたんですけど、
#途中までクリックイベントで切り替えしてたんですけど、
#ちょっとよくわからなくなってきました！！！！！！！！！


#######やぶ########
# リセット
# なにがどーなってるかもう一回知りたいです
# どこみたらいい？
# これって「いいね！したら表示が変わる」をしたい感じですか？
# なるほど
# データベースの処理はサーバ側でやって、非同期通信でいいねした場所の
# htmlだけ変更するようにLIKEはしたいかなーと思うんです。
# なので、html側ではいいねしている表示としてない表示を用意して（クラスがあったりなかったりでいいね表示をする）
# 待ってよ、整理するね
# 表示ができてるのはok
# 流れ確認したいから、想定と違ってたらつっ込んでね笑

# サーバ側（app.rb）ですること：　
# 投稿ごとにライクがあるか確認する。これは、LIKEテーブルと投稿テーブルの結合でいけると思う。
#erbに書いてたのは、”投稿ごとに”ってのがどう書けばいいかわからなくて！
# こっちか笑
# テーブル結合でこの投稿にはログインしているユーザのライクがある判定はできそうな
# 感じがするので、app.rbで結合してから、index.erbでループさせるといい感じになりそうです！
# ちょっともっかいやってみます泣！
# ぼくも説明下手なので、わからなくなったらLagoon来てもらえると嬉しいです笑
# ちなみに、今隣にいるむぎさんがライクの実装経験あるので、聞きまくってました笑
#一旦実装出来たと思ったものが、ログインしなおすと消えてたり、他の人がいいねすると消えてたり。。。
#火曜日また聞きます。ああああああああああああああ

# いいね、結構難しいです、、、

# 表示側（.erb）：
# ライクが存在していたら、投稿にライク有りの表示をする。なければ、ライク無しの表示をする。
# ライクボタンが押された時の処理（.erb）：
# 押されたら、likeの追加、もしくは消した処理に飛ばしたいので、ポストする。（ルーティングはお任せ）
# ライクをどうにかしたいサーバ側（app.rb）：
# ライクがなければ追加、あれば削除の処理をして、index.erbに返す。
# ここまでしたら、一応ページ繊維しちゃうけど、LIKEは実装できそう。
# そんで、たぶん、ページ遷移したくないから、erbファイルに書き込んでたと思うけど、どうですか？
# ページ遷移したくない場合は、非同期通信でpostして、帰ってくるまでを遷移させずにすることができます。
# 非同期通信って、ajaxですか！
# そうです！
# そこから先はぼくも詳しくは知らないので、一旦そこまでの実装を目指した方がいいです！
#了解しました！