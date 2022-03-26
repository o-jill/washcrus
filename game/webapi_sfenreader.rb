# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'uri'

require './file/matchinfofile.rb'
require './util/settings.rb'

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
    @image = '.svg'
  end

  # @!attribute [r] player1
  #   @return 先手名
  # @!attribute [r] player2
  #   @return 後手名
  # @!attribute [r] title
  #   @return 題名とかコメント
  # @!attribute [r] lastmove
  #   @return 最終着手
  # @!attribute [r] piecetype
  #   @return 駒種(PIECE_DEFAULT)
  # @!attribute [r] turn
  #   @return 手番
  attr_reader :player1, :player2, :title, :lastmove, :piecetype, :turn

  # @!attribute [rw] sfen
  #   @return SFEN文字列
  # @!attribute [rw] image
  #   @return 画像形式 '.svg' or '.png'
  attr_accessor :sfen, :image

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

  # 画像形式の設定
  #
  # @param image '.svg' or '.png'
  def setimage(image)
    @image = image
  end

  # 対局情報のセット
  #
  # @param mif MatchInfoFileオブジェクト
  def setmatchinfo(mif)
    setplayers(mif.playerb.name, mif.playerw.name)
    @sfen = mif.sfen
    setlastmovecsa(mif.lastmove)
    setturn(mif.turnex)
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

  # コマの表示形式をretに格納する
  #
  # @param ret コマの表示形式を格納するハッシュ
  #
  # @return コマの表示形式[:piece]が格納されたハッシュ
  def params_piecetype(ret)
    case @piecetype
    when PIECE_ALPHABET then ret[:piece] = 'alphabet'
    when PIECE_INTL     then ret[:piece] = 'international'
      # when PIECE_KANJI then ret[:piece] = 'kanji'
      # else ret[:piece] = 'kanji'
    end
    ret
  end

  # 最後に刺したマスの情報を返す
  def params_lastmove
    @lastmove unless @lastmove.empty?
  end

  # タイトルをretに格納する
  #
  # @param ret タイトルを格納するハッシュ
  #
  # @return タイトル[:title]が格納されたハッシュ
  def params_title(ret)
    ret[:title] = @title.to_s unless @title.nil?
    ret
  end

  # 手番をretに格納する
  #
  # @param ret 手番を格納するハッシュ
  #
  # @return 手番[:turn]が格納されたハッシュ
  def params_turn(ret)
    ret[:turn] = @turn unless @turn.empty?
    ret
  end

  # 画像形式をretに格納する
  #
  # @param ret 手番を格納するハッシュ
  #
  # @return 画像形式[:image]が格納されたハッシュ
  def params_image(ret)
    ret[:image] = image
    ret
  end

  # パラメータをハッシュで返す
  #
  # @return {sfen:, lm:, sname:, gname:, title:, piece:, turn:}
  def params
    ret = { sfen: @sfen }

    ret[:lm] = params_lastmove
    ret = params_plys(ret)
    ret = params_title(ret)
    ret = params_piecetype(ret)
    ret = params_turn(ret)
    ret = params_image(ret)

    ret
  end

  # uriの生成
  #
  # @return uri文字列
  def genuri
    stg = Settings.instance
    sfenimg = stg.value['sfenimage']
    sfenimg = 'sfenimage.rb?' if sfenimg.nil? || sfenimg.empty?
    sfenimg = stg.value['base_url'] + sfenimg unless sfenimg =~ /^http/
    sfenimg + URI.encode_www_form(params)
    # 'http://sfenreader.appspot.com/sfen?' + URI.encode_www_form(params)
  end
end
