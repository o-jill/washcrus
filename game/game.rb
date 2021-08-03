# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'

require 'cgi'
require 'logger'

require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './file/pathlist.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './util/settings.rb'
require './views/gamehtml.rb'
require './views/login.rb'

#
# 対局画面管理
#
class Game
  # 初期化
  #
  # @param cgi CGIオブジェクト
  # @param gid game-id
  def initialize(cgi, gid)
    @log = Logger.new(PathList::GAMELOG)
    # @log.level = Logger::INFO
    @log.info('Game.new()')

    @params = cgi.params

    @gameid = gid
    @log.info("gameid:#{@gameid}")
  end

  # logging
  attr_reader :log

  # userinfoとheaderのセット
  #
  # @param userinfo ユーザー情報
  # @param header htmlヘッダ
  def setparam(userinfo, header)
    @userinfo = userinfo
    @header = header
  end

  # class methods

  # gameid が無いよ
  # userinfoが変だよ
  # 存在しないはずのIDだよ
  def check_params
    # @log.debug('Game.check gameid')
    # gameid が無いよ
    return MyHtml.puts_textplain_illegalaccess unless @gameid

    # @log.debug('Game.check userinfo')
    # userinfoが変だよ
    return LoginScreen.new(@header).show(@userinfo, @gameid) \
      unless @userinfo.exist_indb

    # @log.debug('Game.check gameid with TaikyokuFile')
    tdb = TaikyokuFile.new
    tdb.read
    # 存在しないはずのIDだよ
    return MyHtml.puts_textplain_illegalaccess unless tdb.exist_id(@gameid)

    self
  end

  # 対局データの読み込み
  def prepare_tkd
    tkd = TaikyokuData.new
    tkd.log = @log
    tkd.setid(@gameid)
    tkd.lock do
      tkd.read
    end
    tkd
  end

  #
  # 実行本体。
  #
  def perform
    return unless check_params

    # @log.debug('Game.read TaikyokuData')
    tkd = prepare_tkd

    # @log.debug('Game. html rendering')
    # 表示する
    gh = GameHtml.new(@gameid, tkd.mif, tkd.jkf, @userinfo)
    gh.log = @log
    # @log.debug('Game.put')
    gh.put(@header)
    # @log.debug('Game.performed')
    @log.debug("sesionfiles:#{Dir['./tmp/*']}")
  rescue StandardError => err
    @log.warn(err.to_s)
    @log.warn(err.backtrace.join("\n").to_s)
  end

  # class methods
end
