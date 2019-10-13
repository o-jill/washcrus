# -*- encoding: utf-8 -*-

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
    @lm = nil # '+0000OU__P'
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
  def setmoveinfo(lmv)
    @lm = lmv
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

  def komatype
    # var movecsa = '%0000OU__P';
    komastr = @lm[5, 2]
    promote = @lm[9, 1]
    ret = KOMACSA2KANJI[komastr.to_sym]
    return ret + '成' if promote == 'P'
    ret
  end

  def sengo
    if @strteban == 'w'
      return '下手' unless (@tesuu.to_i % 2).zero?
      '先手'
    else
      return '上手' if (@tesuu.to_i % 2).zero?
      '後手'
    end
  end

  def checksujidan(x, y)
    !(y < 1 || y > 9 || x < 1 || x > 9)
  end

  # 最終手タグの生成
  def taglastmove
    return '' unless @lm

    x = @lm[3, 2].to_i

    y = x % 10
    x /= 10

    return '' unless checksujidan(x, y) # error

    strx = '０１２３４５６７８９'[x, 1]
    stry = NUMKANJI[y]
    "手数＝#{@tesuu.to_i - 1}  #{sengo}#{strx}#{stry}#{komatype}  まで\n"
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
  def tagkomas
    banstr = "  ９ ８ ７ ６ ５ ４ ３ ２ １\n+---------------------------+\n"
    ban = @strban.split('/')

    ban.each_with_index do |adan, i|
      banstr += tagkomas_dan(adan, i + 1)
    end

    banstr + "+---------------------------+\n"
  end

  # 将棋盤のタグの生成
  def tagboardstatus
    # board = "<g id='board' transform='translate(25,70)'>\n#{taglastmove}"
    # board + SfenSVGImageMod::TAGFRAME + tagkomas + "</g>\n"
    tagkomas
  end

  NUMKANJI = [
    '零', '一', '二', '三', '四', '五', '六', '七', '八', '九',
    '十', '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九'
  ].freeze
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
    "後手：#{@gname}\n後手の持駒：#{koma}\n"
  end

  # 先手の名前と手駒
  def tagsente
    koma = @stgm
    koma = 'なし' if @stgm.length.zero?
    "先手の持駒：#{koma}\n先手：#{@sname}\n"
  end

  # 将棋内容タグの生成
  def gen
    ret = taggote + tagboardstatus + tagsente + taglastmove + "* #{@title}\n"
    return ret + "後手番\n" if @strteban == 'w'
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
