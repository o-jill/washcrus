# -*- encoding: utf-8 -*-

require 'uri'

# SfenReader WebAPI 変換クラス
# http://sfenreader.appspot.com/
class WebApiSfenReader
  PIECE_DEFAULT = nil
  PIECE_KANJI = 0
  PIECE_ALPHABET = 1
  PIECE_INTL = 2

  def initialize
    @player1 = ''
    @player2 = ''
    @title = ''
    @sfen = '9/9/9/9/9/9/9/9/9 b - 1'
    @lastmove = ''
    @piecetype = PIECE_DEFAULT
    @turn = ''
  end

  attr_accessor :player1, :player2, :title, :sfen, :lastmove, :piecetype, :turn

  # set players' names
  def setplayers(pl1, pl2)
    @player1 = pl1 || ''
    @player2 = pl2 || ''
  end

  # extract moved position
  #
  # @param csa [String]  [+-][0-9](4)[A-Za-z](2).*
  #                      [手番][from][to][駒][追加があっても良い]
  def setlastmovecsa(csa)
    @lastmove = csa[3, 2] || ''
  end

  def params
    ret = { sfen: @sfen }
    ret[:lm] = @lastmove unless @lastmove.empty?
    ret[:sname] = @player1 unless @player1.empty?
    ret[:gname] = @player2 unless @player2.empty?
    ret[:title] = @title unless @title.empty?

    case @piecetype
    when PIECE_ALPHABET then ret[:piece] = 'alphabet'
    when PIECE_INTL     then ret[:piece] = 'international'
    # when PIECE_KANJI then ret[:piece] = 'kanji'
    # else ret[:piece] = 'kanji'
    end

    ret[:turn] = @turn unless @turn.empty?

    ret
  end

  def genuri
    'http://sfenreader.appspot.com/sfen?' + URI.encode_www_form(params)
  end
end
