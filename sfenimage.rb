#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'bundler/setup'

require 'cgi'

require './game/sfensvgimage.rb'

# api spec
# ret = { sfen: @sfen }
# ret[:lm] = @lastmove unless @lastmove.empty?
# h[:sname] = @playerb unless @playerw.empty?
# h[:gname] = @playerw unless @playerb.empty?
# ret[:title] = @title unless @title.empty?
# case @piecetype
# when PIECE_ALPHABET then ret[:piece] = 'alphabet'
# when PIECE_INTL     then ret[:piece] = 'international'
#   # when PIECE_KANJI then ret[:piece] = 'kanji'
#   # else ret[:piece] = 'kanji'
# end
# ret[:turn] = @turn unless @turn.empty?

#
# CGI本体
#
class SfenImage
  # 初期化
  #
  # @param cgi CGIオブジェクト
  def initialize(cgi)
    params = CGI.parse(cgi.query_string)

    readparam(params)
  end

  # class methods

  # paramから読み取ったメンバの配列を外す。
  def saferead(hash, key)
    a = hash[key] | []
    a[0]
  end

  # paramから読み取ってメンバにコピー。
  #
  # @param params [Hash] query_stringで受け取ったハッシュ
  def readparam(params)
    @sfen = saferead(params, 'sfen')
    @sname = saferead(params, 'sname')
    @gname = saferead(params, 'gname')
    @lm = saferead(params, 'lm')
    @title = saferead(params, 'title')
    @piecetype = saferead(params, 'piece')
    @turn = saferead(params, 'turn')
  end

  #
  # cgi実行本体。
  #
  def perform
    ssi = SfenSVGImage.new(@sfen)
    ssi.setnames(@sname, @gname)
    ssi.settitle(@title)
    ssi.setmoveinfo(@lm, @turn)
    ssi.setui(@piecetype)

    puts "Content-type:image/svg+xml\n\n#{ssi.gen}"
  end

  # class methods
end

# -----------------------------------
#   main
#

begin
cgi = CGI.new
sfenimg = SfenImage.new(cgi)
sfenimg.perform
rescue StandardError => err
  puts "Content-Type: text/html; charset=UTF-8\n\n"
  puts <<-ERRMSG.unindent
    <html><title>ERROR SfenImage</title><body><pre>
    ERROR:#{err}
    STACK:#{err.backtrace.join("\n")}
    </pre></body></html>
  ERRMSG
end

# -----------------------------------
#   testing
#
