# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'unindent'

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
    @lmv = nil # '+0000OU__P'
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
  # @!attribute [r] ys
  #   @return 先手の手駒の表示位置計算用
  # @!attribute [r] yg
  #   @return 後手の手駒の表示位置計算用
  attr_reader :gname, :gtgm, :lmv, :sfen, :sname,
              :strban, :stgm, :strtegoma, :strteban, :tesuu, :yg, :ys

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
  def setmoveinfo(lamv)
    @lmv = lamv
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

    @strban, @strtebn, @strtegoma, @tesuu = sfenitem

    readtegoma
  end

  # 駒表現変換テーブル
  KOMACSA2KANJI = {
    FU: '歩',
    TO: 'と',
    KY: '香',
    NY: '杏',
    KE: '桂',
    NK: '圭',
    GI: '銀',
    NG: '全',
    KI: '金',
    KA: '角',
    UM: '馬',
    HI: '飛',
    RY: '龍',
    OU: '玉'
  }.freeze

  # ’歩’とか'歩成'とか
  def komatype
    # var movecsa = '%0000OU__P';
    komastr = lmv[5, 2]
    promote = lmv[9, 1]
    ret = KOMACSA2KANJI[komastr.to_sym]

    return ret + '成' if promote == 'P'

    ret
  end

  # 直前(=手番じゃない方)の先手後手または上手下手を返す
  def sengo
    kisuu = tesuu.to_i % 2
    siroban = strteban == 'w' ? 2 : 0
    # 2b 3b 2w 3w
    %w[上手 下手 先手 後手][siroban + kisuu]
  end

  # 筋とか段の数字が正しいかチェック
  #
  # @param x 筋
  # @param y 段
  #
  # @return 正しいときtrue
  def checksujidan(x, y)
    !(y < 1 || y > 9 || x < 1 || x > 9)
  end

  # 最終手タグの生成
  #
  # @return 最終手文字列
  def taglastmove
    return '' unless lmv

    x = lmv[3, 2].to_i

    y = x % 10
    x /= 10

    return '' unless checksujidan(x, y) # error

    strx = '０１２３４５６７８９'[x, 1]
    stry = NUMKANJI[y]
    "手数＝#{tesuu.to_i - 1}  #{sengo}#{strx}#{stry}#{komatype}  まで\n"
  end

  # 駒のタグの生成
  #
  # @param ch sfen文字
  # @param prmt 1:成った駒, 0:成ってない
  #
  # @return 駒タグ
  def tagkoma(ch, prmt)
    sente = /[A-Z]/.match(ch) # true:先手, false:後手
    ch = ch.upcase

    pos = 'PLNSGBRK'.index(ch)
    return '' unless pos

    nm = '歩と香杏桂圭銀全金金角馬飛龍玉玉'[2 * pos + prmt, 1]
    return " #{nm}" if sente

    "v#{nm}" # gote
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

    banstr + '|' + NUMKANJI[ndan] + "\n"
  end

  # 駒達のタグの生成
  #
  # @return 駒達のタグ
  def tagkomas
    banstr = "  ９ ８ ７ ６ ５ ４ ３ ２ １\n+---------------------------+\n"
    ban = strban.split('/')

    ban.each_with_index do |adan, i|
      banstr += tagkomas_dan(adan, i + 1)
    end

    banstr + "+---------------------------+\n"
  end

  # 将棋盤のタグの生成
  #
  # @return 駒達のタグ
  def tagboardstatus
    # board = "<g id='board' transform='translate(25,70)'>\n#{taglastmove}"
    # board + SfenSVGImageMod::TAGFRAME + tagkomas + "</g>\n"
    tagkomas
  end

  # 漢数字テーブル
  NUMKANJI = %w[
    零 一 二 三 四 五 六 七 八 九 十 十一 十二 十三 十四 十五 十六 十七 十八 十九
  ].freeze

  # sfen文字から手駒タグの生成
  #
  # @param ch sfen文字
  # @param num 何枚同じ駒を持っているか
  #
  # @return 手駒タグ
  def str_tekoma(ch, num)
    pos = 'PLNSGBR'.index(ch)
    return '' unless pos

    ch = '歩香桂銀金角飛'[pos, 1]
    # Array.new(num, ch).join("")
    ch += NUMKANJI[num] unless num.zero?

    ch + '　'
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

  # 後手の名前と手駒
  def taggote
    koma = gtgm
    koma = 'なし' if gtgm.length.zero?

    "後手：#{gname}\n後手の持駒：#{koma}\n"
  end

  # 先手の名前と手駒
  def tagsente
    koma = stgm
    koma = 'なし' if stgm.length.zero?

    "先手の持駒：#{koma}\n先手：#{sname}\n"
  end

  # 将棋内容タグの生成
  def gen
    ret = taggote + tagboardstatus + tagsente + taglastmove + "* #{@title}\n"
    return ret + "後手番\n" if strteban == 'w'

    ret
  end
end

# test
if $PROGRAM_NAME == __FILE__
  # sfn = 'lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2'
  # sfn = '1n4gn1/4r2sk/5Snll/2p2ppBp/1p2pP3/2P3PS1/1P1+p3GL/2S2+b1KL/8R' \
  #       ' b GNPg6p 105'
  sfn = 'l6nl/1r4gk1/4bs1p1/2pp+Spp1s/pp1n5/2PS2PP1/PP1G1P3/1KGB3R1/LN6L' \
        ' w GPn4p 64'
  skt = SfenKyokumenTxt.new(sfn)
  skt.settitle('タイトル')
  skt.setnames('先手太郎', '後手花子')
  # skt.setmoveinfo('+5958OU___')
  skt.setmoveinfo('+6354GIKIP')
  print skt.gen
end
