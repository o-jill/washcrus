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

    @sfen = params['sfen'] | []
    @sname = params['sname'] | []
    @gname = params['gname'] | []
    @lm = params['lm'] | []
    @title = params['title'] | []
    @piecetype = params['piece'] | []
    @turn = params['turn'] | []

    @sfen = @sfen[0]
    @sname = @sname[0]
    @gname = @gname[0]
    @lm = @lm[0]
    @title = @title[0]
    @piecetype = @piecetype[0]
    @turn = @turn[0]
  end

  # class methods

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

cgi = CGI.new
sfenimg = SfenImage.new(cgi)
sfenimg.perform

# -----------------------------------
#   testing
#
