#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

#!C:\Ruby-2.4-x64\bin\ruby.exe
#!/usr/bin/ruby

require 'cgi'
require 'cgi/session'

require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'
require './views/gamehtml.rb'

#
# CGI本体
#
class Game
  def initialize(cgi)
    # ウインドウタイトル
    @pagetitle = 'Wash Crus'

    # ページタイトル
    @titlename = '洗足池'

    @cgi = cgi
    @params = cgi.params

    @gameid = cgi.query_string
  end

  def readuserparam
    begin
      @session = CGI::Session.new(@cgi,
                                  {
                                    'new_session' => false,
                                    'session_key' => '_washcrus_session',
                                    'tmpdir' => './tmp'
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
      # @session.delete # <-- これはやめたい
    end
    # セッション情報の生成
    # @session = CGI::Session.new(@cgi,
    #                         {
    #                           new_session: true,
    #                           session_key: '_washcrus_session',
    #                           tmpdir: './tmp/',
    #                           session_expires: Time.now + 2_592_000 # 30 days
    #                         })

    # @userinfo.hashsession.each { |k, v| @session[k] = v }

    # @session.close

    @header = @cgi.header('charset' => 'UTF-8')
    @header = @header.gsub("\r\n", "\n")
  end

  # class methods

  #
  # 実行本体。
  #
  def perform
    if @gameid.nil? || @gameid == ''
      # gameid が無いよ
      return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access."
    end

    unless @userinfo.nil? || @userinfo.exist_indb
      # userinfoが変だよ
      print "Content-Type: text/plain; charset=UTF-8\n\nplease log in."
      # @userinfo.dump
      return
    end

    tdb = TaikyokuFile.new
    tdb.read
    unless tdb.exist_id(@gameid)
      # 存在しないはずのIDだよ
      return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access."
    end

    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    # データを読み込んで
    # @mi = MatchInfoFile.new(@gameid)
    # @mi.read(tkd.matchinfopath)
    # @jkf = JsonKifu.new(@gameid)
    # @jkf.read(tkd.kifupath)
    # @chat = ChatFile.new(@gameid)
    # @chat.read()

    # 表示する
    gh = GameHtml.new(@gameid, tkd.mi, tkd.jkf, @userinfo)
    gh.put(@header)
  end

  # class methods
end

# -----------------------------------
#   main
#

cgi = CGI.new

game = Game.new(cgi)
game.readuserparam
game.perform

# -----------------------------------
#   testing
#
