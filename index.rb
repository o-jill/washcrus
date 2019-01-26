#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'bundler/setup'

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

  def signup
    require './views/signup.rb'
    SignupScreen.new(@header).show
  end

  def register
    require './views/register.rb'
    RegisterScreen.new(@header).show(@params)
  end

  def resetpw
    require './views/resetpw.rb'
    ResetPasswordScreen.new(@header).show(@params)
  end

  def update_password
    require './views/update_password.rb'
    UpdatePasswordScreen.new(@header).show(@userinfo, @params)
  end

  def update_email
    require './views/update_email.rb'
    UpdateEmailScreen.new(@header).show(@cgi, @session, @userinfo, @params)
  end

  def login
    require './views/login.rb'
    LoginScreen.new(@header).show(@userinfo)
  end

  def logincheck
    require './views/logincheck.rb'
    LoginCheckScreen.new.show(@session, @cgi)
  end

  def logout
    require './views/logout.rb'
    LogoutScreen.new.show(@session)
  end

  def adminnews
    require './views/adminnews.rb'
    AdminNewsScreen.new(@header).show(@userinfo)
  end

  def adminsettings
    require './views/adminsettings.rb'
    AdminSettingsScreen.new(@header).show(@userinfo)
  end

  def adminsignature
    require './views/adminsignature.rb'
    AdminSignatureScreen.new(@header).show(@userinfo)
  end

  def adminmenu
    # when 'versions' then
    require './views/versions.rb'
    VersionsScreen.new(@header).show(@userinfo)
  end

  def userlist
    userlist_screen(@header, @userinfo)
  end

  def adminnewsupdate
    require './views/adminnewsupdate.rb'
    AdminNewsUpdateScreen.new(@header).show(@userinfo, @params)
  end

  def adminsavesettings
    require './views/adminsavesettings.rb'
    AdminSaveSettingsScreen.new(@header).show(@userinfo, @params)
  end

  def adminsignatureupdate
    require './views/adminsignatureupdate.rb'
    AdminSignatureUpdateScreen.new(@header).show(@userinfo, @params)
  end

  # ゲーム系の画面
  def file2lounge
    require './game/file2lounge.rb'
    File2Lounge.new.perform(@userinfo, @params)
  end

  def lounge
    require './views/lounge.rb'
    LoungeScreen.new(@header).show(@userinfo)
  end

  def matchlist
    require './views/matchlist.rb'
    MatchListScreen.new(@header).show(@userinfo)
  end

  def mypage
    require './views/mypage.rb'
    MyPageScreen.new(@header).show(@userinfo)
  end

  def newgame
    require './views/newgame.rb'
    NewGameScreen.new(@header).show(@userinfo)
  end

  # ゲーム系の画面
  def checknewgame
    require './game/checknewgame.rb'
    CheckNewGame.new(@cgi).perform
  end

  def gennewgame
    require './views/gennewgame.rb'
    GenNewGameScreen.new(@header).show(@userinfo, @params)
  end

  def gennewgame2
    require './views/gennewgame2.rb'
    GenNewGame2Screen.new(@header).show(@userinfo, @params)
  end

  def gennewgame3
    require './views/gennewgame3.rb'
    GenNewGame3Screen.new(@header).show(@userinfo, @params)
  end

  def news
    require './views/news.rb'
    NewsScreen.new(@header).show(@userinfo)
  end

  def search
    require './views/searchresult.rb'
    SearchResultScreen.new(@header).show(@userinfo, @params)
  end

  def searchform
    require './views/searchform.rb'
    SearchformScreen.new(@header).show(@userinfo)
  end

  def cmdtofunc(cmd)
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
    else cmdtofunc(@action)
    end
  end

  # class methods
end

# -----------------------------------
#   main
#

begin
  cgi = CGI.new
  washcrus = WashCrus.new(cgi)
  washcrus.perform
rescue StandardError => err
  puts <<-ERRMSG.unindent
    Content-Type: text/html; charset=UTF-8

    <html>
    <title>ERROR Washcrus</title>
    <body>
    <pre>
    ERROR:#{err}
    STACK:#{err.backtrace.join("\n")}
    </pre>
    </body></html>
  ERRMSG
end
# -----------------------------------
#   testing
#
