# -*- encoding: utf-8 -*-

require 'unindent'

require './game/sfensvgimagemod.rb'

# http://sfenreader.appspot.com/sfen?
# sfen=lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2&
# lm=58&
# sname=aoki&
# gname=aoki

#
# Sfenから局面図SVGを生成
#
class SfenSVGImage
  include SfenSVGImageMod
  # 初期化
  #
  # @param sfen sfen文字列
  def initialize(sfen)
    @sfen = sfen
    @sname = nil
    @gname = nil
    @lm = nil # xy [1-9][1-9]
    @title = nil
    @piecetype = nil # not upported yet
    @turn = nil

    parse
  end

  # 対局者名の設定
  #
  # @param sname 先手
  # @param gname 後手
  def setnames(sname, gname)
    @sname = sname
    @gname = gname
  end

  # タイトルの設定
  #
  # @param title タイトル
  def settitle(title)
    @title = title
  end

  # 指し手情報の設定
  #
  # @param lmv 最後に動かしたマス
  # @param turn 手番(b/w)or勝利情報(fb/fw)
  def setmoveinfo(lmv, turn)
    @lm = lmv
    @turn = turn
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

    return unless @sfen # error

    sfenitem = @sfen.split(' ')
    return if sfenitem.length < 4 # error

    @strban = sfenitem[0]
    @strtegoma = sfenitem[2]

    readtegoma
  end

  # 最終手タグの生成
  def taglastmove
    return '' unless @lm

    x = @lm.to_i

    y = x % 10 - 1
    x = 9 - x / 10

    return '' if y < 0 || y > 8 || x < 0 || x > 8 # error

    y *= 20
    x *= 20

    "<rect x='#{x}' y='#{y}' width='20' height='20' class='lastmv'/>\n"
  end

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

    if sente
      ret + " <text x='10' y='12' class='koma'>#{nm}</text>\n</g>\n"
    else
      ret + " <g transform='translate(10,9) rotate(180)'>\n" \
             "  <text x='0' y='0' class='koma'>#{nm}</text>\n" \
             " </g>\n</g>\n"
    end
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
    ban = @strban.split('/')
    ndan = 0

    ban.each do |adan|
      banstr += tagkomas_dan(adan, ndan)

      ndan += 1
    end

    banstr
  end

  # 将棋盤のタグの生成
  def tagboardstatus
    board = "<g id='board' transform='translate(25,70)'>\n#{taglastmove}"
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

  # 手駒の読み取り
  def readtegoma
    return unless @strtegoma

    num = 0
    @stgm = ''
    @gtgm = ''
    @ys = 0
    @yg = 0

    @strtegoma.each_char do |ch|
      case ch
      when /[PLNSGBRplnsgbr]/
        str_tgm(ch, num)
        num = 0
      when '0'..'9'
        num = num * 10 + ch.to_i
      end
    end
  end

  # 将棋内容タグの生成
  def gen_contents
    tagtitle(@title) + tagteban(@turn) + tagname(@sname, @gname) \
      + tagtegoma(@stgm, @gtgm) + tagboardstatus
  end

  # svg画像の生成
  #
  # @return svg文字列。エラーの場合はエラー情報画像。
  def gen
    svg = SfenSVGImageMod::TAG_HEADER
    svg += gen_contents
    svg + SfenSVGImageMod::TAG_FOOTER
  end
end

if $PROGRAM_NAME == __FILE__
  # sfn = 'lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2'
  sfn = '1n4gn1/4r2sk/5Snll/2p2ppBp/1p2pP3/2P3PS1/1P1+p3GL/2S2+b1KL/8R' \
        ' b GNPg6p 105'
  # sfn = 'l6nl/1r4gk1/4bs1p1/2pp+Spp1s/pp1n5/2PS2PP1/PP1G1P3/1KGB3R1/LN6L' \
  #       ' w GPn4p 64'
  ssi = SfenSVGImage.new(sfn)
  ssi.setnames('先手太郎', '後手花子')
  ssi.settitle('たいとるだよ')
  ssi.setmoveinfo('99', 'b')
  # ssi.setui(@piecetype)
  puts ssi.gen
end
