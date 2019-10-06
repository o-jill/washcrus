# -*- encoding: utf-8 -*-

require 'unindent'

# http://sfenreader.appspot.com/sfen?
# sfen=lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2&
# lm=58&
# sname=aoki&
# gname=aoki

#
# Sfenから局面図textを生成
#
class SfenKyokumenTxt
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
    @strteban = sfenitem[1]
    @strtegoma = sfenitem[2]
    @tesuu = sfenitem[3]

    readtegoma
  end

  # 最終手タグの生成
  def taglastmove
    return '' unless @lm

    x = @lm.to_i

    y = x % 10
    x = x / 10

    return '' if y < 1 || y > 9 || x < 1 || x > 9 # error

    strx = '０１２３４５６７８９'[x, 1]
    stry = '零一二三四五六七八九'[y, 1]
    "#{@tesuu.to_i - 1}手目 #{strx}#{stry}？？まで\n"
  end

  # 駒のタグの生成
  #
  # @param ch sfen文字
  # @param prmt 1:成った駒, 0:成ってない
  # @param x 筋
  # @param y 段
  #
  # @return 駒タグ
  def tagkoma(ch, prmt)
    sente = /[A-Z]/.match(ch) # true:先手, false:後手
    ch = ch.upcase
    ret =

    pos = 'PLNSGBRK'.index(ch)
    return '' unless pos
    nm = '歩と香杏桂圭銀全金金角馬飛龍玉玉'[2 * pos + prmt, 1]

    return " #{nm}" if sente
    "v#{nm}"  # gote
  end

  # ある段の駒達のタグの生成
  #
  # @param adan sfen文字列
  # @param ndan 段
  #
  # @return ある段の駒達のタグ
  def tagkomas_dan(adan, ndan)
    banstr = '|'
    promote = 0

    adan.each_char do |ch|
      case ch
      when /[PLNSGBRKplnsgbrk]/
        banstr += tagkoma(ch, promote)
        promote = 0
      when '1'..'9'
        banstr += Array.new(ch.to_i, ' ・').join('')
        promote = 0
      when '+'
        promote = 1
      end
    end

    banstr + "|\n"
  end

  # 駒達のタグの生成
  def tagkomas
    banstr = "+---------------------------+\n"
    ban = @strban.split('/')
    ndan = 0

    ban.each do |adan|
      banstr += tagkomas_dan(adan, ndan)

      ndan += 1
    end

    banstr + "+---------------------------+\n"
  end

  # 将棋盤のタグの生成
  def tagboardstatus
    # board = "<g id='board' transform='translate(25,70)'>\n#{taglastmove}"
    # board + SfenSVGImageMod::TAGFRAME + tagkomas + "</g>\n"
    tagkomas
  end

  # sfen文字から手駒タグの生成
  #
  # @param ch sfen文字
  # @param y y座標
  #
  # @return 手駒タグ
  def str_tekoma(ch, num)
    pos = 'PLNSGBR'.index(ch)
    return '' unless pos
    ch = '歩香桂銀金角飛'[pos, 1]
    return ch unless num
    Array.new(num, ch).join("")
    # ch + num.to_s
  end

  # sfen文字から手駒タグの生成
  #
  # @param ch sfen文字
  # @param num 数字
  def str_tgm(ch, num)
    if ch =~ /[A-Z]/
      @stgm += str_tekoma(ch, num)
    else
      @gtgm += str_tekoma(ch.upcase, num)
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

  # 後手の名前と手駒
  def taggote
    koma = @gtgm
    koma = 'なし' if @gtgm.length.zero?
    "後手:#{@gname}\n後手の持駒:#{koma}\n"
  end

  #　先手の名前と手駒
  def tagsente
    koma = @stgm
    koma = 'なし' if @stgm.length.zero?
    "先手の持駒:#{koma}\n先手:#{@sname}\n"
  end

  # 将棋内容タグの生成
  def gen
    "「#{@title}」\n" + taggote + tagboardstatus \
      + tagsente + taglastmove
  end
end

# test
# skt = SfenKyokumenTxt.new(
#     'lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2')
# skt.settitle('タイトル')
# skt.setnames('先手太郎', '後手花子')
# skt.setmoveinfo('58', 'b')
# print skt.gen
