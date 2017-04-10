#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

#!C:\Ruby-2.4-x64\bin\ruby.exe
#!/usr/bin/ruby

require "cgi"
require "cgi/session"

require "./entrance.rb"
require "./userinfo.rb"

# ウインドウタイトル
$pagetitle = %Q{Wash Crus}

# ページタイトル
$titlename = %{洗足池}

#
# CGI本体
#
class WashCrus
  def initialize(cgi)
    @cgi = cgi;
    @params = cgi.params;
#    if @params.length>0
#      @params.each_value{|val|
#        val.gsub!(',','&#44;');
#      p val
#    }
#    end
    @action = cgi.query_string

    begin
      session = CGI::Session.new(cgi, {
                    "new_session" => false,
                    "session_key" => "_washcrus_session",
                    "tmpdir" => "./tmp/"
                })
      # session.delete
    rescue ArgumentError
      #session = nil
    end

    if session == nil
      @userinfo = UserInfo.new()
      @userinfo.visitcount = "1";

      # session = CGI::Session.new(cgi, {
      #               "new_session" => true,
      #               "session_key" => "_washcrus_session",
      #               "tmpdir" => "./tmp/",
      #               'session_expires' => Time.now + 3600
      #           })
    else
      @userinfo = UserInfo.new()
      @userinfo.readsession(session)
      # 古いセッション情報の破棄
      session.delete
    end
    # セッション情報の生成
    session = CGI::Session.new(cgi, {
                  "new_session" => true,
                  "session_key" => "_washcrus_session",
                  "tmpdir" => "./tmp/",
                  'session_expires' => Time.now + 2592000  # 30 days
              })

    session['count'] = @userinfo.visitcount

    # session.close

#    @header = cgi.header()
    @header = cgi.header({"charset" => "UTF-8"})
    @header = @header.gsub("\r\n", "\n")
  end

  # class methods

  #
  # cgi実行本体。
  # QUERY_STRINGによる分岐
  #
  def perform
    entrance_screen(@header, $pagetitle, $titlename, @userinfo)
  end

  # class methods

end

# -----------------------------------
#   main
#

cgi = CGI.new;

warcrus = WashCrus.new(cgi);
warcrus.perform();

# -----------------------------------
#   testing
#
