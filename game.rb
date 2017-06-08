#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

#!C:\Ruby-2.4-x64\bin\ruby.exe
#!/usr/bin/ruby

require 'cgi'
require 'cgi/session'

require './gamehtml.rb'
require './jsonkifu.rb'
require './matchinfofile.rb'
require './userinfo.rb'
require './taikyokufile.rb'

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
      @userinfo.dump
      return
    end

    tkd = TaikyokuData.new
    tkd.setid(@gameid)

    tdb = TaikyokuFile.new
    tdb.read
    unless tdb.exist_id(@gameid)
      # 存在しないはずのIDだよ
      return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access."
    end

    # データを読み込んで
    @mi = MatchInfoFile.new(@gameid)
    @mi.read(tkd.matchinfopath)
    @jkf = JsonKifu.new(@gameid)
    @jkf.read(tkd.kifupath)
    # @chat = ChatFile.new(@gameid)
    # @chat.read()

    # 表示する
    gh = GameHtml.new(@gameid, @mi, @jkf, @userinfo)
    gh.put(@header)
  end

  def put
    print <<-SCREEN_ELEM
    <html>
    <head>
        <title> washcrus player1 vs player2 </title>
        <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >
        <link rel='shortcut icon' href='./favicon.ico' />
        <link rel='stylesheet' type='text/css' href='./css/washcrus.css'>
        <!-- script type="text/javascript" defer src=""></script -->
    </head>
    <body>
    <center>洗足池</center>
    <HR>
    <div class=gamearea>
     <div class=block>
      <div class=block_elem_ban>
       将棋盤えりあ
       <canvas width='480' height='320' />
      </div>
      <div class=block_elem_kifu>
       <div id='kifulog' class='kifu'>棋譜えりあ</div>
      </div>
     </div>
     <div id='chatlog' class='chat'>チャットえりあ<BR>
    幅はどうやれば変わるの？<BR>
    -&gt;CSSでした。<BR>
    divじゃないとタグが効かないことが判明。</div>
     <form>
      <input id='chatname' type='text' readonly value='namae' size='10' class='chatnm' />:<input id='chatmsg' type='text' size='60' class='chatmsg' /><input type='submit' onClick='void();' />
     </form>
     <input type='hidden' id='gameid' value='testmatch' />
     <script type='text/javascript' src='./js/chat.js' defer></script>
    </div>
    <HR>
    <div style='text-align:right;'>ぢるっち(c)2017</div>
    </body>
    </html>
    SCREEN_ELEM
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
