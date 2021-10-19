#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'bundler/setup'

require 'cgi'
require 'cgi/session'
require 'logger'

require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'

#
# CGI本体
#
class GetSfen
  # 初期化
  #
  # @param cgi CGIオブジェクト
  def initialize(cgi, logger)
    @log = logger # @log = Logger.new('./log/getsfen.txt')
    @log.debug('initialize(cgi)')
    @cgi = cgi
    @log.debug('@cgi = cgi')
    @params = cgi.params
    @log.debug("@params = cgi.params#{@params}")
    @gameid = cgi.query_string
    @log.debug("@gameid = cgi.query_string#{@gameid}")
  end

  # @!attribute [rw] log
  #   @return logging
  attr_accessor :log
  # attr_reader :log

  # sessionの取得と情報の読み取り
  def readuserparam
    @log.debug('readuserparam')
    begin
      @session = CGI::Session.new(@cgi,
                                  'new_session' => false,
                                  'session_key' => '_washcrus_session',
                                  'tmpdir' => './tmp')
    rescue ArgumentError
      @session = nil
    end

    @userinfo = UserInfo.new
    @userinfo.readsession(@session) if @session
  end

  # 情報のチェック
  def check_param
    @log.debug('check_param')
    # gameid が無いよ
    return MyHtml.puts_textplain_illegalaccess \
        unless @gameid && !@gameid.empty?

    @log.debug('check_param userinfo')

    # userinfoが変だよ
    return MyHtml.puts_textplain_pleaselogin unless @userinfo.exist_indb

    self
  end

  #
  # 実行本体。
  #
  def perform
    # gameid が無いよ
    # userinfoが変だよ
    return unless check_param

    @log.debug("tcdb.exist?(#{@gameid})")

    tcdb = TaikyokuChuFile.new
    tcdb.read
    # 存在しないはずのIDだよ
    return MyHtml.puts_textplain_illegalaccess unless tcdb.exist?(@gameid)

    @log.debug("tkd.setid(#{@gameid})")
    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    MyHtml.print_textplain(tkd.mif.sfen)
  end
end

# -----------------------------------
#   main
#

log = Logger.new(PathList::GETSFENLOG, Logger::Severity::INFO)
begin
  cgi = CGI.new
  getsfen = GetSfen.new(cgi, log)
  getsfen.readuserparam
  getsfen.perform
rescue StandardError => e
  log.error("class=[#{e.class}] message=[#{e444.message}] " \
       "stack=[#{e.backtrace.join("\n")}] in move")
end

# -----------------------------------
#   testing
#
