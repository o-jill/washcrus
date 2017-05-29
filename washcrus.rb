#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

#!C:\Ruby-2.4-x64\bin\ruby.exe
#!/usr/bin/ruby

require 'cgi'
require 'cgi/session'

require './userinfo.rb'

# ウインドウタイトル
$pagetitle = %Q{Wash Crus}

# ページタイトル
$titlename = %{洗足池}

#
# CGI本体
#
class WashCrus
  def initialize(cgi)
    @cgi = cgi
    @params = cgi.params
#    if @params.length>0
#      @params.each_value{|val|
#        val.gsub!(',','&#44;');
#      p val
#    }
#    end
    @action = cgi.query_string

    begin
      @session = CGI::Session.new(cgi, {
                    'new_session' => false,
                    'session_key' => '_washcrus_session',
                    'tmpdir' => './tmp/'
                })
      # @session.delete
    rescue ArgumentError
      # @session = nil
    end

    @userinfo = UserInfo.new
    if @session.nil?
      @userinfo.visitcount = '1'

      # @session = CGI::Session.new(cgi, {
      #               "new_session" => true,
      #               "session_key" => "_washcrus_session",
      #               "tmpdir" => "./tmp/",
      #               'session_expires' => Time.now + 3600
      #           })
    else
      @userinfo.readsession(@session)
      # 古いセッション情報の破棄
      @session.delete
    end
    # セッション情報の生成
    @session = CGI::Session.new(cgi, {
                 'new_session' => true,
                 'session_key' => '_washcrus_session',
                 'tmpdir' => './tmp/',
                 'session_expires' => Time.now + 2_592_000 # 30 days
              })

    @userinfo.hashsession.each { |k, v| @session[k] = v }

    # @session.close

    @header = cgi.header( { 'charset' => 'UTF-8' } )
    @header = @header.gsub("\r\n", "\n")
  end

  # class methods

  #
  # cgi実行本体。
  # QUERY_STRINGによる分岐
  #
  def perform
    if @action.nil? || @action == ''
      require './entrance.rb'
      entrance_screen(@header, $pagetitle, $titlename, @userinfo)
    elsif @action == 'newgame'
      require './newgame.rb'
      newgame_screen(@header, $pagetitle, $titlename, @userinfo)
    elsif @action == 'gennewgame'
      require './gennewgame.rb'
      generatenewgame_screen(@header, $pagetitle, $titlename, @userinfo, @params)
    elsif @action == 'signup'
      require './signup.rb'
      signup_screen(@header, $pagetitle, $titlename, @userinfo)
    elsif @action == 'login'
      require './login.rb'
      login_screen(@header, $pagetitle, $titlename, @params)
    elsif @action == 'logincheck'
      require './logincheck.rb'
      logincheck_screen(@header, @session, $pagetitle, $titlename, @params)
    elsif @action == 'logout'
      require './logout.rb'
      logout_screen(@session, $pagetitle, $titlename)
    elsif @action == 'register'
      require './register.rb'
      register_screen(@header, $pagetitle, $titlename, @params)
    elsif @action == 'matchlist'
      require './matchlist.rb'
      matchlist_screen(@header, $pagetitle, $titlename, @params)
    elsif @action == 'userlist'
      require './userlist.rb'
      userlist_screen(@header, $pagetitle, $titlename, @params)
    else
      require './error_action.rb'
      error_action_screen(@header, $pagetitle, $titlename, @userinfo, @params, @action)
    end
  end

  # class methods
end

# -----------------------------------
#   main
#

cgi = CGI.new

warcrus = WashCrus.new(cgi)
warcrus.perform

# -----------------------------------
#   testing
#
