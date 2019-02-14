# -*- encoding: utf-8 -*-

require 'uri'

# SfenReader WebAPI 変換クラス
# http://sfenreader.appspot.com/
class WebApiSfenReader
  PIECE_DEFAULT = nil
  PIECE_KANJI = 0
  PIECE_ALPHABET = 1
  PIECE_INTL = 2

  # 初期化
  def initialize
    @playerb = ''
    @playerw = ''
    @title = ''
    @sfen = '9/9/9/9/9/9/9/9/9 b - 1'
    @lastmove = ''
    @piecetype = PIECE_DEFAULT
    @turn = ''
  end

  attr_reader :player1, :player2, :title, :lastmove, :piecetype, :turn
  attr_accessor :sfen

  # set players' names
  #
  # @param plb 先手の名前
  # @param plw 後手の名前
  def setplayers(plb, plw)
    @playerb = plb || ''
    @playerw = plw || ''
  end

  # extract moved position
  #
  # @param csa [String]  [+-][0-9](4)[A-Za-z](2).*
  #                      [手番][from][to][駒][追加があっても良い]
  def setlastmovecsa(csa)
    @lastmove = csa[3, 2] || ''
  end

  # タイトル文字列の設定
  #
  # @param ttl タイトル文字列
  def settitle(ttl)
    @title = ttl
  end

  # 手番の設定
  #
  # @param trn 手番
  def setturn(trn)
    @turn = trn
  end

  # ハッシュに名前を追加
  #
  # @param hash ハッシュ
  # @return 名前が追加されたハッシュ
  def params_plys(hash)
    hash[:sname] = @playerb unless @playerw.empty?
    hash[:gname] = @playerw unless @playerb.empty?
    hash
  end

  def param_piecetype(ret)
    case @piecetype
    when PIECE_ALPHABET then ret[:piece] = 'alphabet'
    when PIECE_INTL     then ret[:piece] = 'international'
      # when PIECE_KANJI then ret[:piece] = 'kanji'
      # else ret[:piece] = 'kanji'
    end
  end

  # パラメータをハッシュで返す
  #
  # @return {sfen:, lm:, sname:, gname:, title:, piece:, turn:}
  def params
    ret = { sfen: @sfen }
    ret[:lm] = @lastmove unless @lastmove.empty?
    ret = params_plys(ret)
    ret[:title] = @title.to_s unless @title.nil?

    ret = param_piecetype(ret)

    ret[:turn] = @turn unless @turn.empty?

    ret
  end

  # uriの生成
  #
  # @return uri文字列
  def genuri
    'sfenimage.rb?' + URI.encode_www_form(params)
    # 'http://sfenreader.appspot.com/sfen?' + URI.encode_www_form(params)
  end
end
