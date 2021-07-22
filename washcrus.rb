#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'bundler/setup' if $PROGRAM_NAME == __FILE__

require 'cgi'
require 'cgi/session'

require './game/userinfo.rb'
require './util/settings.rb'
require './views/error_action.rb'
require './views/userlist.rb'

#
# CGI本体
#
class WashCrus
  # 初期化
  #
  # @param cgi CGIオブジェクト
  def initialize(cgi)
    @cgi = cgi
    @params = cgi.params

    @action = cgi.query_string
    begin
      @session = CGI::Session.new(cgi,
                                  'new_session' => false,
                                  'session_key' => '_washcrus_session',
                                  'tmpdir' => './tmp',
                                  'session_expires' => Time.now + 2_592_000)
    rescue ArgumentError
      @session = nil
    end
    @userinfo = UserInfo.new
    if @session
      @userinfo.readsession(@session)
      @userinfo.hashsession.each { |ky, vl| @session[ky] = vl }
    else
      @userinfo.visitcount = '1'
    end

    @header = cgi.header('charset' => 'UTF-8',
                         'Pragma' => 'no-cache',
                         'Cache-Control' => 'no-cache')

    @header = @header.gsub("\r\n", "\n")
  end

  # class methods

  WORDS_MISC = [nil, '', 'news', 'search', 'searchform'].freeze

  # 登録画面
  def signup
    session.close

    require './views/signup.rb'
    SignupScreen.new(@header).show
  end

  # 登録処理画面
  def register
    session.close

    require './views/register.rb'
    RegisterScreen.new(@header).show(@params)
  end

  # パスワードリセット
  def resetpw
    require './views/resetpw.rb'
    ResetPasswordScreen.new(@header).show(@params)
  end

  # パスワード更新
  def update_password
    session.close

    require './views/update_password.rb'
    UpdatePasswordScreen.new(@header).show(@userinfo, @params)
  end

  # メールアドレス更新
  def update_email
    require './views/update_email.rb'
    UpdateEmailScreen.new(@header).show(@cgi, @session, @userinfo, @params)
  end

  # ログイン画面
  def login
    session.close

    require './views/login.rb'
    LoginScreen.new(@header).show(@userinfo, '')
  end

  # ログイン処理
  def logincheck
    require './views/logincheck.rb'
    LoginCheckScreen.new.show(@session, @cgi)
  end

  # ログアウト
  def logout
    require './views/logout.rb'
    LogoutScreen.new.show(@session)
  end

  # news編集画面
  def adminnews
    session.close

    require './views/adminnews.rb'
    AdminNewsScreen.new(@header).show(@userinfo)
  end

  # 設定編集画面
  def adminsettings
    session.close

    require './views/adminsettings.rb'
    AdminSettingsScreen.new(@header).show(@userinfo)
  end

  # メール署名編集画面
  def adminsignature
    session.close

    require './views/adminsignature.rb'
    AdminSignatureScreen.new(@header).show(@userinfo)
  end

  # 管理者画面
  def adminmenu
    session.close

    # when 'versions' then
    require './views/versions.rb'
    VersionsScreen.new(@header).show(@userinfo)
  end

  # ユーザーリスト
  def userlist
    session.close

    userlist_screen(@header, @userinfo)
  end

  # news更新処理
  def adminnewsupdate
    session.close

    require './views/adminnewsupdate.rb'
    AdminNewsUpdateScreen.new(@header).show(@userinfo, @params)
  end

  # 設定更新処理
  def adminsavesettings
    session.close

    require './views/adminsavesettings.rb'
    AdminSaveSettingsScreen.new(@header).show(@userinfo, @params)
  end

  # メール署名更新処理
  def adminsignatureupdate
    session.close

    require './views/adminsignatureupdate.rb'
    AdminSignatureUpdateScreen.new(@header).show(@userinfo, @params)
  end

  # ユーザー情報更新処理
  def adminuserstgupdate
    session.close

    require './views/adminuserstgupdate.rb'
    AdminUserStgUpdateScreen.new(@header).show(@userinfo, @params)
  end

  # 対局管理画面
  def admingamemanage
    session.close

    require './views/admingamemanage.rb'
    AdminGameManageScreen.new(@header).show(@userinfo)
  end

  # 対局状況更新処理
  def admingamemanageupdate
    session.close

    require './views/admingamemanageupdate.rb'
    AdminGameManageUpdateScreen.new(@header).show(@userinfo, @params)
  end

  # ゲーム系の画面

  # 対局待ち処理
  def file2lounge
    session.close

    require './game/file2lounge.rb'
    File2Lounge.new.perform(@userinfo, @params)
  end

  # ラウンジ画面
  def lounge
    session.close

    require './views/lounge.rb'
    LoungeScreen.new(@header).show(@userinfo)
  end

  # 対局リスト
  def matchlist
    session.close

    require './views/matchlist.rb'
    MatchListScreen.new(@header).show(@userinfo)
  end

  # マイページ
  def mypage
    session.close

    require './views/mypage.rb'
    MyPageScreen.new(@header).show(@userinfo)
  end

  # 新規対局作成画面
  def newgame
    session.close

    require './views/newgame.rb'
    NewGameScreen.new(@header).show(@userinfo)
  end

  # ゲーム系の画面
  def checknewgame
    session.close

    require './game/checknewgame.rb'
    CheckNewGame.new(@cgi).perform
  end

  # 対局の生成
  def gennewgame
    session.close

    require './views/gennewgame.rb'
    GenNewGameScreen.new(@header).show(@userinfo, @params)
  end

  # 対局の生成
  def gennewgame2
    session.close

    require './views/gennewgame2.rb'
    GenNewGame2Screen.new(@header).show(@userinfo, @params)
  end

  # 対局の生成
  def gennewgame3
    session.close

    require './views/gennewgame3.rb'
    GenNewGame3Screen.new(@header).show(@userinfo, @params)
  end

  # news画面
  def news
    session.close

    require './views/news.rb'
    NewsScreen.new(@header).show(@userinfo)
  end

  # 検索結果画面
  def search
    session.close

    require './views/searchresult.rb'
    SearchResultScreen.new(@header).show(@userinfo, @params)
  end

  # 検索画面
  def searchform
    session.close

    require './views/searchform.rb'
    SearchformScreen.new(@header).show(@userinfo)
  end

  # コマンドから実行する関数を呼ぶ
  # 無いときは入口画面
  #
  # @param cmd コマンド文字列
  def cmdtofunc(cmd)
    cmd ||= 'entrance'
    if methods(true).include?(cmd.to_sym)
      func = method(cmd.to_sym)
      func.call
    else
      session.close

      require './views/entrance.rb'
      EntranceScreen.new(@header).show(@userinfo)
    end
  end

  #
  # cgi実行本体。
  # QUERY_STRINGによる分岐
  #
  def perform
    case @action
    when %r{game\/(\h+)}
      session.close

      require './game/game.rb'
      gm = Game.new(@cgi, $1)
      gm.setparam(@userinfo, @header)
      gm.perform
    when %r{dlkifu\/(\h+)}
      session.close

      require './game/dlkifu.rb'
      DownloadKifu.new($1, @userinfo).perform
    when %r{adminuserstg\/?(\h*)}
      if @action == 'adminuserstgupdate'
        adminuserstgupdate
      else
        session.close

        require './views/adminuserstg.rb'
        AdminUserStgScreen.new(@header).show($1, @userinfo)
      end
    else cmdtofunc(@action)
    end
  end

  # class methods
end

# -----------------------------------
#   main
#
if $PROGRAM_NAME == __FILE__
  begin
    cgi = CGI.new
    washcrus = WashCrus.new(cgi)
    washcrus.perform
  rescue StandardError => err
    puts "Content-Type: text/html; charset=UTF-8\n\n"
    puts <<-ERRMSG.unindent
      <html><title>ERROR Washcrus</title><body><pre>
      ERROR:#{err}
      STACK:#{err.backtrace.join("\n")}
      </pre></body></html>
    ERRMSG
  end
end
# -----------------------------------
#   testing
#
