# -*- encoding: utf-8 -*-
# frozen_string_literal: true

# require 'unindent'

# require './game/sfensvgimagemod.rb'

# http://sfenreader.appspot.com/sfen?
# sfen=lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2&
# lm=58&
# sname=aoki&
# gname=aoki

#
# Sfenから局面図SVGを生成
#
class SfenKyokumenAbstract
  # include SfenSVGImageMod
  # 初期化
  #
  # @param sfen sfen文字列
  def initialize(sfen)
    @sfen = sfen
    @sname = nil
    @gname = nil
    @lmv = nil # xy [1-9][1-9]
    @title = nil
    @piecetype = nil # not upported yet
    @turn = nil

    parse
  end

  # @!attribute [r] sname
  #   @return 先手の対局者名
  # @!attribute [r] gname
  #   @return 後手の対局者名
  # @!attribute [r] stgm
  #   @return 先手の手駒
  # @!attribute [r] gtgm
  #   @return 後手の手駒
  # @!attribute [r] lmv
  #   @return 最終着手
  # @!attribute [r] sfen
  #   @return sfen文字列
  # @!attribute [r] strban
  #   @return 盤面のSVG文字列
  # @!attribute [r] strtegoma
  #   @return 手駒部分のSVG文字列
  # @!attribute [r] strteban
  #   @return sfenの手番部分
  # @!attribute [r] tesuu
  #   @return sfenの手数部分
  # @!attribute [r] turn
  #   @return 手番
  # @!attribute [r] ys
  #   @return 先手の手駒の表示位置計算用
  # @!attribute [r] yg
  #   @return 後手の手駒の表示位置計算用
  attr_reader :gname, :gtgm, :lmv, :sfen, :sname,
              :strban, :stgm, :strtegoma, :strteban, :tesuu, :turn, :yg, :ys

  # 対局者名の設定
  #
  # @param names 先手
  # @param nameg 後手
  def setnames(names, nameg)
    @sname = names
    @gname = nameg
  end

  # タイトルの設定
  #
  # @param title タイトル
  def settitle(title)
    @title = title
  end

  # 指し手情報の設定
  #
  # @param lamv 最後に動かしたマス
  # @param trn 手番(b/w)or勝利情報(fb/fw)
  def setmoveinfo(lamv, trn = nil)
    @lmv = lamv
    @turn = trn
  end

  # コマの種類の設定
  #
  # @param piecetype コマの種類
  # @note not supported yet.
  def setui(piecetype)
    @piecetye = piecetype
  end

  # sfen = lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2
  def parse
    @strban = ''
    @strtegoma = ''

    return unless sfen # error

    sfenitem = sfen.split(' ')
    return if sfenitem.length < 4 # error

    @strban, @strteban, @strtegoma, @tesuu = sfenitem

    readtegoma
  end

  # xyが正しいかチェック
  #
  # @param x 筋-1
  # @param y 段-1
  #
  # @return 変な数字のときtrue
  def invalidxy?(x, y)
    y.negative? || y > 8 || x.negative? || x > 8
  end

  # 手駒の読み取り
  def readtegoma
    return unless strtegoma

    num = 0
    @stgm = ''
    @gtgm = ''
    @ys = 0
    @yg = 0

    strtegoma.each_char do |ch|
      case ch
      when /[PLNSGBRplnsgbr]/
        str_tgm(ch, num)
        num = 0
      when '0'..'9'
        num = num * 10 + ch.to_i
      end
    end
  end
end
