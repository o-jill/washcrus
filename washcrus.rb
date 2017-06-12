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
require './views/newgame.rb'
require './views/register.rb'
require './views/signup.rb'
require './views/userlist.rb'

#
# CGI本体
#
class WashCrus
  def initialize(cgi)
    # ウインドウタイトル
    @pagetitle = 'Wash Crus'

    # ページタイトル
    @titlename = '洗足池'

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
    if @action.nil? || @action == ''
      entrance_screen(@header, @pagetitle, @titlename, @userinfo)
    elsif @action == 'newgame'
      newgame_screen(@header, @pagetitle, @titlename, @userinfo)
    elsif @action == 'gennewgame'
      generatenewgame_screen(@header, @pagetitle, @titlename,
                             @userinfo, @params)
    elsif @action == 'signup'
      signup_screen(@header, @pagetitle, @titlename, @userinfo)
    elsif @action == 'login'
      login_screen(@header, @pagetitle, @titlename, @params)
    elsif @action == 'logincheck'
      logincheck_screen(@header, @session, @pagetitle, @titlename, @cgi)
    elsif @action == 'logout'
      logout_screen(@session, @pagetitle, @titlename)
    elsif @action == 'register'
      register_screen(@header, @pagetitle, @titlename, @params)
    elsif @action == 'matchlist'
      matchlist_screen(@header, @pagetitle, @titlename, @params)
    elsif @action == 'userlist'
      userlist_screen(@header, @pagetitle, @titlename, @params)
    else
      error_action_screen(@header, @pagetitle, @titlename,
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
