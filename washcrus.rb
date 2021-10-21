#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

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
      @session = CGI::Session.new(
        cgi,
        'new_session' => false,
        'session_key' => '_washcrus_session',
        'tmpdir' => './tmp',
        'session_expires' => Time.now + 2_592_000
      )
    rescue ArgumentError
      @session = nil
    end

    prepare_userinfo

    @header = cgi.header('charset' => 'UTF-8',
                         'Pragma' => 'no-cache',
                         'Cache-Control' => 'no-cache')

    @header = @header.gsub("\r\n", "\n")
  end

  # class methods

  # ユーザー情報の準備
  def prepare_userinfo
    @userinfo = UserInfo.new
    if @session
      @userinfo.readsession(@session)
      @userinfo.hashsession.each { |ky, vl| @session[ky] = vl }
      @session.close
    else
      @userinfo.visitcount = '1'
    end
  end

  WORDS_MISC = [nil, '', 'news', 'search', 'searchform'].freeze

  # 登録画面
  def signup
    require './views/signup.rb'
    SignupScreen.new(@header).show
  end

  # 登録処理画面
  def register
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
    require './views/update_password.rb'
    UpdatePasswordScreen.new(@header).show(@userinfo, @params)
  end

  # メールアドレス更新
  def update_email
    require './views/update_email.rb'
    UpdateEmailScreen.new(@header).show(@cgi, @userinfo, @params)
  end

  # 退会
  def unsubscribe
    require './views/unsubscribe.rb'
    UnsubscribeScreen.new(@header).show(@userinfo, @params)
  end

  # ログイン画面
  def login
    require './views/login.rb'
    LoginScreen.new(@header).show(@userinfo, '')
  end

  # ログイン処理
  def logincheck
    require './views/logincheck.rb'
    LoginCheckScreen.new.show(@userinfo, @cgi)
  end

  # ログアウト
  def logout
    require './views/logout.rb'
    LogoutScreen.new.show(@session)
  end

  # news編集画面
  def adminnews
    require './views/adminnews.rb'
    AdminNewsScreen.new(@header).show(@userinfo)
  end

  # marqueenews編集画面
  def adminmqnews
    require './views/adminmqnews.rb'
    AdminMarqueeNewsScreen.new(@header).show(@userinfo)
  end

  # 設定編集画面
  def adminsettings
    require './views/adminsettings.rb'
    AdminSettingsScreen.new(@header).show(@userinfo)
  end

  # メール署名編集画面
  def adminsignature
    require './views/adminsignature.rb'
    AdminSignatureScreen.new(@header).show(@userinfo)
  end

  # 管理者画面
  def adminmenu
    # when 'versions' then
    require './views/versions.rb'
    VersionsScreen.new(@header).show(@userinfo)
  end

  # ユーザーリスト
  def userlist
    userlist_screen(@header, @userinfo)
  end

  # news更新処理
  def adminnewsupdate
    require './views/adminnewsupdate.rb'
    AdminNewsUpdateScreen.new(@header).show(@userinfo, @params)
  end

  # marqueenews更新処理
  def adminmqnewsupdate
    require './views/adminmqnewsupdate.rb'
    AdminMarqueeNewsUpdateScreen.new(@header).show(@userinfo, @params)
  end

  # 設定更新処理
  def adminsavesettings
    require './views/adminsavesettings.rb'
    AdminSaveSettingsScreen.new(@header).show(@userinfo, @params)
  end

  # メール署名更新処理
  def adminsignatureupdate
    require './views/adminsignatureupdate.rb'
    AdminSignatureUpdateScreen.new(@header).show(@userinfo, @params)
  end

  # ユーザー情報更新処理
  def adminuserstgupdate
    require './views/adminuserstgupdate.rb'
    AdminUserStgUpdateScreen.new(@header).show(@userinfo, @params)
  end

  # 対局管理画面
  def admingamemanage
    require './views/admingamemanage.rb'
    AdminGameManageScreen.new(@header).show(@userinfo)
  end

  # 対局状況更新処理
  def admingamemanageupdate
    require './views/admingamemanageupdate.rb'
    AdminGameManageUpdateScreen.new(@header).show(@userinfo, @params)
  end

  # ゲーム系の画面

  # 対局待ち処理
  def file2lounge
    require './game/file2lounge.rb'
    File2Lounge.new.perform(@userinfo, @params)
  end

  # ラウンジ画面
  def lounge
    require './views/lounge.rb'
    LoungeScreen.new(@header).show(@userinfo)
  end

  # 対局リスト
  def matchlist
    require './views/matchlist.rb'
    MatchListScreen.new(@header).show(@userinfo)
  end

  # マイページ
  def mypage
    require './views/mypage.rb'
    MyPageScreen.new(@header).show(@userinfo)
  end

  # 新規対局作成画面
  def newgame
    require './views/newgame.rb'
    NewGameScreen.new(@header).show(@userinfo)
  end

  # ゲーム系の画面
  def checknewgame
    require './game/checknewgame.rb'
    CheckNewGame.new(@cgi).perform
  end

  # 対局の生成
  def gennewgame
    require './views/gennewgame.rb'
    GenNewGameScreen.new(@header).show(@userinfo, @params)
  end

  # 対局の生成
  def gennewgame2
    require './views/gennewgame2.rb'
    GenNewGame2Screen.new(@header).show(@userinfo, @params)
  end

  # 対局の生成
  def gennewgame3
    require './views/gennewgame3.rb'
    GenNewGame3Screen.new(@header).show(@userinfo, @params)
  end

  # news画面
  def news
    require './views/news.rb'
    NewsScreen.new(@header).show(@userinfo)
  end

  # 検索結果画面
  def search
    require './views/searchresult.rb'
    SearchResultScreen.new(@header).show(@userinfo, @params)
  end

  # 検索画面
  def searchform
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
      require './game/game.rb'
      gm = Game.new(@cgi, $1)
      gm.setparam(@userinfo, @header)
      gm.perform
    when %r{dlkifu\/(\h+)}
      require './game/dlkifu.rb'
      DownloadKifu.new($1, @userinfo).perform
    when %r{adminuserstg\/?(\h*)}
      if @action == 'adminuserstgupdate'
        adminuserstgupdate
      else
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
  rescue StandardError => e
    puts "Content-Type: text/html; charset=UTF-8\n\n"
    puts <<-ERRMSG.unindent
      <html><title>ERROR Washcrus</title><body><pre>
      ERROR:#{e}
      STACK:#{e.backtrace.join("\n")}
      </pre></body></html>
    ERRMSG
  end
end
# -----------------------------------
#   testing
#
