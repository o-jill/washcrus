# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'unindent'

require './game/sfenkyokumenabs.rb'
require './game/sfensvgimagemod.rb'

# http://sfenreader.appspot.com/sfen?
# sfen=lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2&
# lm=58&
# sname=aoki&
# gname=aoki

#
# Sfenから局面図SVGを生成
#
class SfenSVGImage < SfenKyokumenAbstract
  include SfenSVGImageMod
  # 初期化
  #
  # @param sfen sfen文字列
  def initialize(sfen)
    super(sfen)
  end

  # 最終手タグの生成
  def taglastmove
    return '' unless lmv

    x = lmv.to_i

    y = x % 10 - 1
    x = 9 - x / 10

    return '' if invalidxy?(x, y) # error

    y *= 20
    x *= 20

    "<rect x='#{x}' y='#{y}' width='20' height='20' fill='#FF4'/>\n"
  end

  KOMATR = "font-size='18px' text-anchor='middle'"

  # 駒のタグの生成
  #
  # @param ch sfen文字
  # @param prmt 1:成った駒, 0:成ってない
  # @param x 筋
  # @param y 段
  #
  # @return 駒タグ
  def tagkoma(ch, prmt, x, y)
    sente = /[A-Z]/.match(ch) # true:先手, false:後手
    ch = ch.upcase
    x *= 20
    y *= 20
    ret = "<g transform='translate(#{x},#{y})'>\n"

    pos = 'PLNSGBRK'.index(ch)
    return '' unless pos

    nm = '歩と香杏桂圭銀全金金角馬飛龍玉玉'[2 * pos + prmt, 1]

    return ret + " <text x='10' y='17' #{KOMATR}>#{nm}</text>\n</g>\n" \
      if sente

    ret + " <g transform='translate(10,10) rotate(180)'>\n" \
           "  <text x='0' y='6' #{KOMATR}>#{nm}</text>\n" \
           " </g>\n</g>\n"
  end

  # ある段の駒達のタグの生成
  #
  # @param adan sfen文字列
  # @param ndan 段
  #
  # @return ある段の駒達のタグ
  def tagkomas_dan(adan, ndan)
    banstr = ''
    promote = 0
    nsuji = 0

    adan.each_char do |ch|
      case ch
      when /[PLNSGBRKplnsgbrk]/
        banstr += tagkoma(ch, promote, nsuji, ndan)
        promote = 0
        nsuji += 1
      when '1'..'9'
        nsuji += ch.to_i
        promote = 0
      when '+'
        promote = 1
      end
    end

    banstr
  end

  # 駒達のタグの生成
  def tagkomas
    banstr = ''
    ban = strban.split('/')
    ndan = 0

    ban.each do |adan|
      banstr += tagkomas_dan(adan, ndan)

      ndan += 1
    end

    banstr
  end

  # 将棋盤のタグの生成
  def tagboardstatus
    board = "<g id='board' transform='translate(35,65)'>\n#{taglastmove}"
    board + SfenSVGImageMod::TAGFRAME + tagkomas + "</g>\n"
  end

  # sfen文字から手駒タグの生成
  #
  # @param ch sfen文字
  # @param num 数字
  def str_tgm(ch, num)
    if ch =~ /[A-Z]/
      @stgm, @ys = str_tekoma(ch, num, @stgm, @ys)
    else
      @gtgm, @yg = str_tekoma(ch.upcase, num, @gtgm, @yg)
    end
  end

  # 将棋内容タグの生成
  def gen_contents
    tagtitle(@title) + tagteban(@turn) + tagname(sname, gname) \
      + tagtegoma(stgm, gtgm) + tagboardstatus
  end

  # svg画像の生成
  #
  # @return svg文字列。エラーの場合はエラー情報画像。
  def gen
    SfenSVGImageMod::TAG_HEADER \
      + gen_contents \
      + SfenSVGImageMod::TAG_FOOTER
  end
end
