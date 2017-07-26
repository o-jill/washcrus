#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

#!C:\Ruby-2.4-x64\bin\ruby.exe
#!/usr/bin/ruby

require 'cgi'
require 'cgi/session'

require './game/userinfo.rb'
require './views/entrance.rb'
require './views/error_action.rb'
require './views/gennewgame.rb'
require './views/login.rb'
require './views/logincheck.rb'
require './views/logout.rb'
require './views/matchlist.rb'
require './views/mypage.rb'
require './views/newgame.rb'
require './views/register.rb'
require './views/signup.rb'
require './views/userlist.rb'

#
# CGI本体
#
class WashCrus
  # ウインドウタイトル
  Pagetitle = 'Wash Crus'.freeze

  # ページタイトル
  Titlename = '洗足池'.freeze

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

    begin
      @session = CGI::Session.new(cgi,
                                  {
                                    'new_session' => false,
                                    'session_key' => '_washcrus_session',
                                    'tmpdir' => './tmp'
                                  })
    rescue ArgumentError
      # p "@session = nil"
    end

    @userinfo = UserInfo.new
    if @session.nil?
      @userinfo.visitcount = '1'

      @session = CGI::Session.new(cgi,
                                  {
                                    'new_session' => true,
                                    'session_key' => '_washcrus_session',
                                    'tmpdir' => './tmp',
                                    'session_expires' => Time.now + 3600
                                  })
    else
      @userinfo.readsession(@session)
    end

    @userinfo.hashsession.each { |k, v| @session[k] = v }

    # @session.close

    @header = cgi.header('charset' => 'UTF-8')
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
      entrance_screen(@header, Pagetitle, Titlename, @userinfo)
    when 'newgame' then
      newgame_screen(@header, Pagetitle, Titlename, @userinfo)
    when 'gennewgame' then
      generatenewgame_screen(@header, Pagetitle, Titlename, @userinfo, @params)
    when 'signup' then
      signup_screen(@header, Pagetitle, Titlename, @userinfo)
    when 'login' then
      login_screen(@header, Pagetitle, Titlename, @params)
    when 'logincheck' then
      logincheck_screen(@header, @session, Pagetitle, Titlename, @cgi)
    when 'logout' then
      logout_screen(@session, Pagetitle, Titlename)
    when 'register' then
      register_screen(@header, Pagetitle, Titlename, @params)
    when 'matchlist' then
      matchlist_screen(@header, Pagetitle, Titlename, @params)
    when 'mypage' then
      mypage_screen(@header, Pagetitle, Titlename, @userinfo)
    when 'userlist' then
      userlist_screen(@header, Pagetitle, Titlename, @params)
    else
      error_action_screen(@header, Pagetitle, Titlename,
                          @userinfo, @params, @action)
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
