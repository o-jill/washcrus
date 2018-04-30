# -*- encoding: utf-8 -*-

require 'unindent'

# http://sfenreader.appspot.com/sfen?
# sfen=lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2&
# lm=58&
# sname=aoki&
# gname=aoki

#
# Sfenから局面図SVGを生成
#
class SfenSVGImage
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
  # @param lm 最後に動かしたマス
  # @param turn 手番(b/w)or勝利情報(fb/fw)
  def setmoveinfo(lm, turn)
    @lm = lm
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

  # 名前タグの生成
  def tagname
    ret = <<-NAMETAG.unindent
      <g id="gname" transform="translate(5,25)">
       <polygon points="10,0 18,2 20,20 0,20 2,2" fill="none"/>
       <text class="name" x="25" y="10">#{@gname}</text>
      </g>
      <g id="sname" transform="translate(5,265)">
       <g transform="translate(220,0)">
        <polygon points="10,0 18,2 20,20 0,20 2,2" fill="black"/>
       </g>
       <text class="name" x="0" y="10">#{@sname}</text>
      </g>
      NAMETAG
    ret
  end

  # タイトルタグの生成
  def tagtitle
    "<g id='title'><text class='title' x='125' y='10'>#{@title}</text></g>\n"
  end

  # 手番タグの生成
  def tagteban
    tagrect = "<rect x='0' y='0' width='30' height='30' class='teban'/>"
    ptspoly = "points='15,0 22.5,5 30,0 30,30 0,30 0,0 7.5,5'"
    case @turn
    when 'w'
      "<g id='teban' transform='translate(0,20)'>\n #{tagrect}\n</g>\n"
    when 'b'
      "<g id='teban' transform='translate(220,260)'>\n #{tagrect}\n</g>\n"
    when 'fw'
      "<g id='teban' transform='translate(30,20)'>\n" \
      " <polygon #{ptspoly} class='teban'/>\n</g>\n"
    when 'fb'
      "<g id='teban' transform='translate(0,260)'>\n" \
      " <polygon #{ptspoly} class='teban'/>\n</g>\n"
    else
      ''
    end
  end

  # svgヘッダタグ
  TAG_HEADER = <<-EO_TAG_HEADER.unindent
    <?xml version="1.0"?>
    <svg width="250" height="290" viewBox="0 0 250 290" version="1.1" xmlns="http://www.w3.org/2000/svg" >
     <style>
      /* <![CDATA[ */
       polygon {
        stroke: black;
        stroke-width: 1px;
       }
       g#ban rect {
        stroke:black;
        stroke-width:2;
        fill:none;
       }
       line {
        stroke: black;
        stroke-width: 1;
       }
       text {
        font-size: 18px;
       }
       text.name {
        font-size: 16px;
        text-anchor: left;
        dominant-baseline: middle;
        alignment-baseline: middle;
        width: 220px;
        text-overflow: ellipsis;
       }
       text.title {
        font-size: 16px;
        text-anchor: middle;
        dominant-baseline: middle;
        alignment-baseline: middle;
        width: 250px;
        text-overflow: ellipsis;
       }
       text.koma {
        font-size: 18px;
        text-anchor: middle;
        dominant-baseline: middle;
        alignment-baseline: middle;
       }
       text.tegoma {
        font-size: 16px;
        text-anchor: middle;
        dominant-baseline: top;
        alignment-baseline: top;
       }
       text.ntegoma {
        font-size: 12px;
        text-anchor: middle;
        dominant-baseline: top;
        alignment-baseline: top;
       }
       text.suji {
        font-size: 10px;
        text-anchor: middle;
        alignment-baseline: after-edge;
        dominant-baseline: after-edge;
       }
       text.dan {
        font-size: 10px;
        text-anchor: left;
        dominant-baseline: middle;
        alignment-baseline: middle;
       }
       .teban {
         stroke : none;
         fill: #F3C;
       }
       .lastmv {
         stroke : none;
         fill: #FF4;
       }
      /* ]]> */
     </style>
     <g>
    EO_TAG_HEADER

  # svgフッタタグ
  TAG_FOOTER = " </g>\n</svg>\n".freeze

  # 最終手タグの生成
  def taglastmove
    return '' unless @lm

    x = @lm.to_i

    y = x % 10 - 1
    x = 9 - x / 10

    return '' if y < 0 || 8 < y || x < 0 || 8 < x # error

    y *= 20
    x *= 20

    "<rect x='#{x}' y='#{y}' width='20' height='20' class='lastmv'/>\n"
  end

  # 将棋盤フレームタグ
  TAGFRAME = <<-EOTAGFRAME.unindent
    <g id="ban">
     <rect x="0" y="0" width="180" height="180"/>
     <line x1="0" y1="20" x2="180" y2="20"/>
     <line x1="0" y1="40" x2="180" y2="40"/>
     <line x1="0" y1="60" x2="180" y2="60"/>
     <line x1="0" y1="80" x2="180" y2="80"/>
     <line x1="0" y1="100" x2="180" y2="100"/>
     <line x1="0" y1="120" x2="180" y2="120"/>
     <line x1="0" y1="140" x2="180" y2="140"/>
     <line x1="0" y1="160" x2="180" y2="160"/>
     <line x1="20" y1="0" x2="20" y2="180"/>
     <line x1="40" y1="0" x2="40" y2="180"/>
     <line x1="60" y1="0" x2="60" y2="180"/>
     <line x1="80" y1="0" x2="80" y2="180"/>
     <line x1="100" y1="0" x2="100" y2="180"/>
     <line x1="120" y1="0" x2="120" y2="180"/>
     <line x1="140" y1="0" x2="140" y2="180"/>
     <line x1="160" y1="0" x2="160" y2="180"/>
     <text x="10" y="-5" class="suji">9</text>
     <text x="30" y="-5" class="suji">8</text>
     <text x="50" y="-5" class="suji">7</text>
     <text x="70" y="-5" class="suji">6</text>
     <text x="90" y="-5" class="suji">5</text>
     <text x="110" y="-5" class="suji">4</text>
     <text x="130" y="-5" class="suji">3</text>
     <text x="150" y="-5" class="suji">2</text>
     <text x="170" y="-5" class="suji">1</text>
     <text x="185" y="10" class="dan">一</text>
     <text x="185" y="30" class="dan">二</text>
     <text x="185" y="50" class="dan">三</text>
     <text x="185" y="70" class="dan">四</text>
     <text x="185" y="90" class="dan">五</text>
     <text x="185" y="110" class="dan">六</text>
     <text x="185" y="130" class="dan">七</text>
     <text x="185" y="150" class="dan">八</text>
     <text x="185" y="170" class="dan">九</text>
    </g>
    EOTAGFRAME

  # 駒のタグの生成
  #
  # @param ch sfen文字
  # @param prmt 1:成った駒, 0:成ってない
  # @param sente true:先手, false:後手
  # @param x 筋
  # @param y 段
  #
  # @return 駒タグ
  def tagkoma(ch, prmt, sente, x, y)
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
      when /[PLNSGBRK]/
        banstr += tagkoma(ch, promote, true, nsuji, ndan)
        nsuji += 1
        promote = 0
      when /[plnsgbrk]/
        banstr += tagkoma(ch.upcase, promote, false, nsuji, ndan)
        nsuji += 1
        promote = 0
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
    board += TAGFRAME
    board += tagkomas
    board + "</g>\n"
  end

  # 手駒の数字タグの生成
  #
  # @param num 数字
  # @param y y座標
  #
  # @return 手駒数字タグ
  def numtegoma(num, y)
    "<text x='0' y='#{y - 1}' class='ntegoma'>#{num}</text>"
  end

  # sfen文字から手駒タグの生成
  #
  # @param ch sfen文字
  # @param y y座標
  #
  # @return 手駒タグ
  def str_sgtgm(ch, y)
    pos = 'PLNSGBR'.index(ch)
    return '' unless pos
    koma = '歩香桂銀金角飛'[pos, 1]
    "<text x='0' y='#{y}' class='tegoma'>#{koma}</text>"
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
      when %r{[PLNSGBR]}
        @stgm += str_sgtgm(ch, @ys)
        @ys += 16
        @stgm += numtegoma(num, @ys) if num > 1
        @ys += 16 if num > 1
        num = 0
      when %r{[plnsgbr]}
        @gtgm += str_sgtgm(ch.upcase, @yg)
        @yg += 16
        @gtgm += numtegoma(num, @yg) if num > 1
        @ys += 16 if num > 1
        num = 0
      when '0'..'9'
        num = num * 10 + ch.to_i
      end
    end
  end

  # 手駒のタグの生成
  def tagtegoma
    ret = <<-TAGTEGOMA.unindent
      <g id="gtegoma" transform="translate(7.5,65)">
       <g transform="translate(4,-7)">
        <polygon points="0,-5 4,-4 5,5 -5,5 -4,-4" fill="none"/>
       </g>
       <g transform="translate(4,16)">#{@gtgm}</g>
      </g>
      <g id="stegoma" transform="translate(230,65)">
       <g transform="translate(4,-7)">
        <polygon points="0,-5 4,-4 5,5 -5,5 -4,-4" fill="black"/>
       </g>
       <g transform="translate(4,16)">#{@stgm}</g>
      </g>
      TAGTEGOMA

    ret
  end

  # 将棋内容タグの生成
  def gen_contents
    tagtitle + tagteban + tagname + tagtegoma + tagboardstatus
  end

  # svg画像の生成
  #
  # @return svg文字列。エラーの場合はエラー情報画像。
  def gen
    svg = TAG_HEADER
    svg += gen_contents
    svg + TAG_FOOTER
  end
end
