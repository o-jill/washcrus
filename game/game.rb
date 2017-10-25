# -*- encoding: utf-8 -*-

require 'rubygems'

require 'cgi'
require 'logger'

require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'
require './util/settings.rb'
require './views/gamehtml.rb'
require './views/login.rb'

#
# 対局画面管理
#
class Game
  def initialize(cgi, gid)
    @log = Logger.new('./log/gamelog.txt')
    # @log.level = Logger::INFO
    @log.info('Game.new()')

    @params = cgi.params

    @gameid = gid
    @log.info("gameid:#{@gameid}")
  end

  attr_reader :log

  def setparam(userinfo, header)
    @userinfo = userinfo
    @header = header
  end

  # class methods

  def put_illegal_access
    print "Content-Type: text/plain; charset=UTF-8\n\nillegal access."
  end

  # gameid が無いよ
  # userinfoが変だよ
  # 存在しないはずのIDだよ
  def check_params
    # gameid が無いよ
    return put_illegal_access if @gameid.nil? || @gameid.empty?

    # @log.debug('Game.check userinfo')
    # userinfoが変だよ
    return LoginScreen.new(@header).show(@userinfo) \
        unless @userinfo.nil? || @userinfo.exist_indb

    # @log.debug('Game.check gameid with TaikyokuFile')
    tdb = TaikyokuFile.new
    tdb.read
    # 存在しないはずのIDだよ
    return put_illegal_access unless tdb.exist_id(@gameid)

    self
  end

  #
  # 実行本体。
  #
  def perform
    # @log.debug('Game.check gameid')
    return if check_params.nil?

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
  rescue => e
    @log.warn("class=[#{e.class}] message=[#{e.message}] in game")
  end

  # class methods
end
