#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

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
class GetMatchInfo
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
    @userinfo.readsession(@session) if @session
  end

  # 情報のチェック
  def check_param
    # gameid が無いよ
    return MyHtml.puts_textplain_illegalaccess \
        unless @gameid && !@gameid.empty?

    # adminじゃないよ
    # return MyHtml.puts_textplain_errnotadmin unless @userinfo.admin

    self
  end

  #
  # 実行本体。
  #
  def perform
    # gameid が無いよ
    # userinfoが変だよ
    return unless check_param

    tcdb = TaikyokuChuFile.new
    tcdb.read
    # 存在しないはずのIDだよ
    return MyHtml.puts_textplain_illegalaccess unless tcdb.exist_id(@gameid)

    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    mif = tkd.mif
    puts "Content-Type: text/plain;\n\n" \
      "#{@gameid}\n先手:#{mif.playerb.name} 後手:#{mif.playerw.name}\n" \
      "sfen:#{mif.sfen}"
  end
end

# -----------------------------------
#   main
#

cgi = CGI.new
begin
  getsfen = GetMatchInfo.new(cgi)
  getsfen.readuserparam
  getsfen.perform
rescue ScriptError => er
  puts "Content-Type: text/plain;\n\nclass=[#{er.class}] message=[#{er.message}] " \
       "stack=[#{er.backtrace.join("\n")}]"
rescue SecurityError => er
  puts "Content-Type: text/plain;\n\nclass=[#{er.class}] message=[#{er.message}] " \
       "stack=[#{er.backtrace.join("\n")}]"
rescue StandardError => er
  puts "Content-Type: text/plain;\n\nclass=[#{er.class}] message=[#{er.message}] " \
       "stack=[#{er.backtrace.join("\n")}]"
end
# -----------------------------------
#   testing
#