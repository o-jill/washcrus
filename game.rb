#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'logger'

require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'
require './util/settings.rb'
require './views/gamehtml.rb'
require './views/login.rb'

#
# CGI本体
#
class Game
  def initialize(cgi, gid = nil)
    @log = Logger.new('./tmp/gamelog.txt')
    # @log.level = Logger::INFO
    @log.info('Game.new()')

    # ウインドウタイトル
    @pagetitle = 'Wash Crus'

    # ページタイトル
    @titlename = '洗足池'

    @cgi = cgi
    @params = cgi.params

    @gameid = gid.nil? ? cgi.query_string : gid
    @log.info("gameid:#{@gameid}")
  end

  attr_reader :log

  def setparam(session, userinfo, header)
    @session = session
    @userinfo = userinfo
    @header = header
  end

  def readuserparam
    begin
      @session = CGI::Session.new(@cgi,
                                  'new_session' => false,
                                  'session_key' => '_washcrus_session',
                                  'tmpdir' => './tmp',
                                  'session_expires' => Time.now + 2_592_000)
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

    # @header = @cgi.header('charset' => 'UTF-8')
    @header = @cgi.header('charset' => 'UTF-8',
                          'Pragma' => 'no-cache',
                          'Cache-Control' => 'no-cache')
    @header = @header.gsub("\r\n", "\n")
  end

  # class methods

  #
  # 実行本体。
  #
  def perform
    # @log.debug('Game.check gameid')
    # gameid が無いよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access." \
        if @gameid.nil? || @gameid.empty?

    # @log.debug('Game.check userinfo')
    # userinfoが変だよ
    return login_screen(@header, @pagetitle, @titlename, nil) \
        unless @userinfo.nil? || @userinfo.exist_indb

    # @log.debug('Game.check gameid with TaikyokuFile')
    tdb = TaikyokuFile.new
    tdb.read
    # 存在しないはずのIDだよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access." \
        unless tdb.exist_id(@gameid)

    # @log.debug('Game.read TaikyokuData')
    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    # @log.debug('Game. html rendering')
    # 表示する
    gh = GameHtml.new(@gameid, tkd.mi, tkd.jkf, @userinfo)
    gh.log = @log
    # @log.debug('Game.put')
    gh.put(@header)
    # @log.debug('Game.performed')
  end

  # class methods
end

# -----------------------------------
#   main
#
if $PROGRAM_NAME == __FILE__
  cgi = CGI.new
  $stg = Settings.new
  begin
    game = Game.new(cgi)
    game.readuserparam
    game.perform
  rescue ScriptError => e
    game.log.warn("class=[#{e.class}] message=[#{e.message}] in game")
  rescue SecurityError => e
    game.log.warn("class=[#{e.class}] message=[#{e.message}] in game")
  rescue => e
    game.log.warn("class=[#{e.class}] message=[#{e.message}] in game")
  end
end
# -----------------------------------
#   testing
#
