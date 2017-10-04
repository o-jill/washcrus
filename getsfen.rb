#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'logger'

require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'

#
# CGI本体
#
class GetSfen
  TEXTPLAIN_HEAD = "Content-Type: text/plain; charset=UTF-8\n\n".freeze

  # 初期化
  #
  # @param cgi CGIオブジェクト
  def initialize(cgi)
    @cgi = cgi
    @params = cgi.params
    @gameid = cgi.query_string
  end

  # sessionの取得と情報の読み取り
  def readuserparam
    begin
      @session = CGI::Session.new(@cgi,
                                  'new_session' => false,
                                  'session_key' => '_washcrus_session',
                                  'tmpdir' => './tmp')
    rescue ArgumentError
      @session = nil
    end

    @userinfo = UserInfo.new
    @userinfo.readsession(@session) unless @session.nil?
  end

  # 情報のチェック
  def check_param
    # gameid が無いよ
    return print TEXTPLAIN_HEAD + 'ERROR:illegal access.' \
        if @gameid.nil? || @gameid.empty?

    # userinfoが変だよ
    return print TEXTPLAIN_HEAD + 'ERROR:please log in.' \
        unless @userinfo.nil? || @userinfo.exist_indb

    self
  end

  #
  # 実行本体。
  #
  def perform
    # gameid が無いよ
    # userinfoが変だよ
    return if check_param.nil?

    tcdb = TaikyokuChuFile.new
    tcdb.read
    # 存在しないはずのIDだよ
    return print TEXTPLAIN_HEAD + 'ERROR:illegal access.' \
      unless tcdb.exist_id(@gameid)

    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    print TEXTPLAIN_HEAD + tkd.mi.sfen
  end
end

# -----------------------------------
#   main
#

cgi = CGI.new
begin
  getsfen = GetSfen.new(cgi)
  getsfen.readuserparam
  getsfen.perform
end
# -----------------------------------
#   testing
#
