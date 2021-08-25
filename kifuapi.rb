#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'bundler/setup'
require 'cgi'

require './file/taikyokufile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'

#
# 棋譜のダウンロード
#
class KifuAPI
  # 初期化
  #
  # @param cgi CGIオブジェクト
  def initialize(cgi)
    # @params = cgi.params
    return if cgi.query_string.empty?
    @gameid = cgi.query_string[/(\h+)\./, 1]
    @type = cgi.query_string[/\.(.+)/, 1]
  end

  # class methods

  # パラメータのチェック
  #
  # @return おかしいときnil
  def checkparam
    # gameid が無いよ
    return MyHtml.puts_textplain_illegalaccess unless @gameid
    return MyHtml.puts_textplain_illegalaccess \
      unless @type == 'kif' # %w[kif csa].include?(@type)

    tdb = TaikyokuFile.new
    tdb.read
    # 存在しないはずのIDだよ
    return MyHtml.puts_textplain_illegalaccess unless tdb.exist?(@gameid)

    self
  end

  #
  # 実行本体。
  #
  def perform
    return unless checkparam

    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    # 表示する
    puts "Content-Type: text/plain; charset=UTF-8\n\n"
    tkd.show_converted_kifu(@type)
  end

  # class methods
end

begin
  cgi = CGI.new
  kifuapi = KifuAPI.new(cgi)
  kifuapi.perform
rescue StandardError => err
  puts "Content-Type: text/html; charset=UTF-8\n\n"
  puts <<-ERRMSG.unindent
    <html><title>ERROR Washcrus</title><body><pre>
    ERROR:#{err}
    STACK:#{err.backtrace.join("\n")}
    </pre></body></html>
  ERRMSG
end
