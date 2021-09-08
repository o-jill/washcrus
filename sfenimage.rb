#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

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
# ret[:image] = @image || '.svg'

#
# CGI本体
#
class SfenImage
  # SVG2PNG = 'rsvg-convert' # rsvg-convert
  SVG2PNG = '/usr/bin/inkscape --export-png=- -z --file=-' # inkscape 0.92
  # SVG2PNG = 'inkscape --export-type=png -p' # inkscape 1.0

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
    @image = saferead(params, 'image')
  end

  def svg2png(svg)
    IO.popen(SVG2PNG, 'r+') do |io|
      io.puts svg
      io.close_write
      io.read
    end
  end

  # png形式の出力
  #
  # @param svg svgデータ
  def put_png(svg)
    pngbuf = svg2png(svg)
    print "Content-type:image/png\n\n#{pngbuf}"
    # debug
    # File.open('./tmp/svg2png.png', 'wb') do |file|
    #   file.write(pngbuf)
    # end
    # File.open('./tmp/svg2png.svg', 'wb') do |file|
    #   file.write(svg)
    # end
  end

  # 画像データを出力
  def put_image(svg)
    return put_png(svg) if @image == '.png'
    puts "Content-type:image/svg+xml\n\n#{svg}"
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

    put_image(ssi.gen)
  end

  # class methods
end

# -----------------------------------
#   main
#

# svg画像上での改行
#
# @param str
# @param y Y座標
# @param height 文字の高さ
#
# @return 改行された文字列のSVGタグ
def kaigyo(str, y, height)
  str.split("\n").map.with_index do |elem, i|
    "<text x='0' y='#{y + i * height}'>#{elem}</text>\n"
  end
end

# エラー出力をsvg画像として出力
#
# @param err エラー情報
def errtrace(err)
  errtype =  err.to_s.gsub(
    /[<>&]/,
    '&' => '&amp;', '<' => '&lt;', '>' => '&gt;'
  )
  errtype = kaigyo("ERROR:\n#{errtype}", 10, 11).join('')
  bktrace = err.backtrace.join("\n").gsub(
    /[<>&]/,
    '&' => '&amp;', '<' => '&lt;', '>' => '&gt;'
  )
  bktrace = kaigyo("STACK:\n#{bktrace}", 40, 11).join('')
  puts "Content-type:image/svg+xml\n\n" \
    "<?xml version='1.0'?>\n" \
    "<svg width='300' height='100' viewBox='0 0 300 100' version='1.1' " \
    "xmlns='http://www.w3.org/2000/svg' >\n" \
    "<style>\n/* <![CDATA[ */\ntext {font-size: 10px;}\n/* ]]> */\n</style>\n" \
    "<g>\n#{errtype}#{bktrace}</g>\n" \
    "</svg>\n"
end

# syntax errors are impossible to be catch.
begin
  cgi = CGI.new
  sfenimg = SfenImage.new(cgi)
  sfenimg.perform
rescue ScriptError => err
  errtrace(err)
rescue SecurityError => err
  errtrace(err)
rescue StandardError => err
  # puts "Content-Type: text/html; charset=UTF-8\n\n"
  # puts <<-ERRMSG.unindent
  #   <html><title>ERROR SfenImage</title><body><pre>
  #   ERROR:#{err}
  #   STACK:#{err.backtrace.join("\n")}
  #   </pre></body></html>
  # ERRMSG
  errtrace(err)
end

# -----------------------------------
#   testing
#
