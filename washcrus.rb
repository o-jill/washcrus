#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'cgi'
require 'cgi/session'

require './game/userinfo.rb'
require './util/settings.rb'
require './views/adminnews.rb'
require './views/adminnewsupdate.rb'
require './views/adminsavesettings.rb'
require './views/adminsettings.rb'
require './views/adminsignature.rb'
require './views/adminsignatureupdate.rb'
require './views/entrance.rb'
require './views/error_action.rb'
require './views/gennewgame.rb'
require './views/gennewgame2.rb'
require './views/login.rb'
require './views/logincheck.rb'
require './views/logout.rb'
require './views/matchlist.rb'
require './views/mypage.rb'
require './views/news.rb'
require './views/newgame.rb'
require './views/register.rb'
require './views/searchform.rb'
require './views/searchresult.rb'
require './views/signup.rb'
require './views/userlist.rb'
require './views/versions.rb'

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
    # if @params.length>0
    #   @params.each_value{|val|
    #     val.gsub!(',','&#44;');
    #   p val
    # }
    # end
    @action = cgi.query_string

    # expire = nil
    begin
      @session = CGI::Session.new(cgi,
                                  'new_session' => false,
                                  'session_key' => '_washcrus_session',
                                  'tmpdir' => './tmp',
                                  'session_expires' => Time.now + 2_592_000)
    rescue ArgumentError
      # p "@session = nil"
    end

    @userinfo = UserInfo.new
    if @session.nil?
      @userinfo.visitcount = '1'

      # @session = CGI::Session.new(cgi,
      #                             'new_session' => true,
      #                             'session_key' => '_washcrus_session',
      #                             'tmpdir' => './tmp',
      #                             'session_expires' => Time.now + 2_592_000)
    else
      @userinfo.readsession(@session)
      @userinfo.hashsession.each { |k, v| @session[k] = v }
      # expire = @session['session_expires']
    end

    # @session.close

    # if expire
    #   @header = cgi.header('charset' => 'UTF-8', 'expires' => expire)
    # else
    #   @header = cgi.header('charset' => 'UTF-8')
    # end
    @header = cgi.header('charset' => 'UTF-8',
                         'Pragma' => 'no-cache',
                         'Cache-Control' => 'no-cache')

    @header = @header.gsub("\r\n", "\n")
  end

  # class methods

  #
  # cgi実行本体。
  # QUERY_STRINGによる分岐
  #
  def perform
    case @action
    when nil, '' then
      EntranceScreen.new(@header).show(@userinfo)
    when 'newgame' then
      NewGameScreen.new(@header).show(@userinfo)
    when 'gennewgame' then
      GenNewGameScreen.new(@header).show(@userinfo, @params)
    when 'gennewgame2' then
      GenNewGame2Screen.new(@header).show(@userinfo, @params)
    when 'signup' then
      SignupScreen.new(@header).show
    when 'login' then
      LoginScreen.new(@header).show(@userinfo)
    when 'logincheck' then
      LoginCheckScreen.new.show(@session, @cgi)
    when 'logout' then
      LogoutScreen.new.show(@session)
    when 'register' then
      RegisterScreen.new(@header).show(@params)
    when 'matchlist' then
      MatchListScreen.new(@header).show(@userinfo)
    when 'mypage' then
      MyPageScreen.new(@header).show(@userinfo)
    when 'news' then
      NewsScreen.new(@header).show(@userinfo)
    when 'adminnews' then
      AdminNewsScreen.new(@header).show(@userinfo)
    when 'adminnewsupdate' then
      AdminNewsUpdateScreen.new(@header).show(@userinfo, @params)
    when 'adminsettings' then
      AdminSettingsScreen.new(@header).show(@userinfo)
    when 'adminsavesettings' then
      AdminSaveSettingsScreen.new(@header).show(@userinfo, @params)
    when 'adminsignature' then
      AdminSignatureScreen.new(@header).show(@userinfo)
    when 'adminsignatureupdate' then
      AdminSignatureUpdateScreen.new(@header).show(@userinfo, @params)
    when 'search' then
      SearchResultScreen.new(@header).show(@userinfo, @params)
    when 'searchform' then
      SearchformScreen.new(@header).show(@userinfo)
    when 'userlist' then
      userlist_screen(@header, @userinfo)
    when 'adminmenu' then # when 'versions' then
      VersionsScreen.new(@header).show(@userinfo)
    when %r{game\/(\h+)}
      require './game/game.rb'
      gm = Game.new(@cgi, $1)
      gm.setparam(@userinfo, @header)
      gm.perform
    when %r{dlkifu\/(\h+)}
      require './game/dlkifu.rb'
      dk = DownloadKifu.new($1, @userinfo)
      dk.perform
    when 'checknewgame'
      require './game/checknewgame.rb'
      CheckNewGame.new(@cgi).perform
    else
      error_action_screen(@userinfo, @params, @action)
    end
  end

  # class methods
end

# -----------------------------------
#   main
#

cgi = CGI.new
washcrus = WashCrus.new(cgi)
washcrus.perform

# -----------------------------------
#   testing
#
