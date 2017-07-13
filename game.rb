#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

#!C:\Ruby-2.4-x64\bin\ruby.exe
#!/usr/bin/ruby

require 'cgi'
require 'cgi/session'
require 'logger'

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
    @log = Logger.new('./tmp/gamelog.txt')
    # @log.level = Logger::INFO
    @log.info('Game.new()')

    # ウインドウタイトル
    @pagetitle = 'Wash Crus'

    # ページタイトル
    @titlename = '洗足池'

    @cgi = cgi
    @params = cgi.params

    @gameid = cgi.query_string
    @log.info("gameid:#{@gameid}")
  end

  def readuserparam
    begin
      @session = CGI::Session.new(@cgi,
                                  {
                                    'new_session' => false,
                                    'session_key' => '_washcrus_session',
                                    'tmpdir' => './tmp'
                                  })
    rescue ArgumentError
      # @session = nil
      @log.info('failed to find session')
    end

    @userinfo = UserInfo.new
    if @session.nil?
      @userinfo.visitcount = '1'
    else
      @userinfo.readsession(@session)
    end

    @header = @cgi.header('charset' => 'UTF-8')
    @header = @header.gsub("\r\n", "\n")
  end

  # class methods

  #
  # 実行本体。
  #
  def perform
    @log.debug('Game.check gameid')
    # gameid が無いよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access." \
        if @gameid.nil? || @gameid.length.zero?

    @log.debug('Game.check userinfo')
    # userinfoが変だよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nplease log in." \
        unless @userinfo.nil? || @userinfo.exist_indb

    @log.debug('Game.check gameid with TaikyokuFile')
    tdb = TaikyokuFile.new
    tdb.read
    # 存在しないはずのIDだよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access." \
        unless tdb.exist_id(@gameid)

    @log.debug('Game.read TaikyokuData')
    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    @log.debug('Game. html rendering')
    # 表示する
    gh = GameHtml.new(@gameid, tkd.mi, tkd.jkf, @userinfo)
    gh.log = @log
    @log.debug('Game.put')
    gh.put(@header)
    @log.debug('Game.performed')
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
