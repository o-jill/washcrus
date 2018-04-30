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

  # svgヘッダタグ
  def tag_header
    TAG_HEADER
  end

  # svgフッタタグの生成
  def tag_footer
    " </g>\n</svg>\n"
  end

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
  def tagkoma(nm, sente, x, y)
    x *= 20
    y *= 20
    ret = "<g transform='translate(#{x},#{y})'>\n"
    if sente
      ret + " <text x='10' y='12' class='koma'>#{nm}</text>\n</g>\n"
    else
      ret + " <g transform='translate(10,9) rotate(180)'>\n" \
             "  <text x='0' y='0' class='koma'>#{nm}</text>\n" \
             " </g>\n</g>\n"
    end
  end

  # 駒達のタグの生成
  def tagkomas
    banstr = ''
    ban = @strban.split('/')
    ndan = 0
    promote = false
    ban.each do |adan|
      nsuji = 0

      adan.each_char do |ch|
        case ch
        when 'p', 'P'
          banstr += tagkoma(promote ? 'と' : '歩', ch == 'P', nsuji, ndan)
          nsuji += 1
          promote = false
        when 'l', 'L'
          banstr += tagkoma(promote ? '杏' : '香', ch == 'L', nsuji, ndan)
          nsuji += 1
          promote = false
        when 'n', 'N'
          banstr += tagkoma(promote ? '圭' : '桂', ch == 'N', nsuji, ndan)
          nsuji += 1
          promote = false
        when 's', 'S'
          banstr += tagkoma(promote ? '全' : '銀', ch == 'S', nsuji, ndan)
          nsuji += 1
          promote = false
        when 'g', 'G'
          banstr += tagkoma('金', ch == 'G', nsuji, ndan)
          nsuji += 1
          promote = false
        when 'b', 'B'
          banstr += tagkoma(promote ? '馬' : '角', ch == 'B', nsuji, ndan)
          nsuji += 1
          promote = false
        when 'r', 'R'
          banstr += tagkoma(promote ? '龍' : '飛', ch == 'R', nsuji, ndan)
          nsuji += 1
          promote = false
        when 'k', 'K'
          banstr += tagkoma('玉', ch == 'K', nsuji, ndan)
          nsuji += 1
          promote = false
        when '1'..'9'
          nsuji += ch.to_i
          promote = false
        when '+'
          promote = true
        end
      end

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
  def numtegoma(num, y)
    return ['', 0] if num <= 0

    ["<text x='0' y='#{y - 1}' class='ntegoma'>#{num}</text>", 16]
  end

  # 手駒の読み取り
  def readtegoma
    return unless @strtegoma

    num = 0
    gstr = ''
    sstr = ''
    needsuji = false
    @ys = 0
    @yg = 0

    @strtegoma.each_char do |ch|
      case ch
      when 'P'
        sstr += "<text x='0' y='#{@ys}' class='tegoma'>歩</text>"
        needsuji = true
      when 'L'
        sstr += "<text x='0' y='#{@ys}' class='tegoma'>香</text>"
        needsuji = true
      when 'N'
        sstr += "<text x='0' y='#{@ys}' class='tegoma'>桂</text>"
        needsuji = true
      when 'S'
        sstr += "<text x='0' y='#{@ys}' class='tegoma'>銀</text>"
        needsuji = true
      when 'G'
        sstr += "<text x='0' y='#{@ys}' class='tegoma'>金</text>"
        needsuji = true
      when 'B'
        sstr += "<text x='0' y='#{@ys}' class='tegoma'>角</text>"
        needsuji = true
      when 'R'
        sstr += "<text x='0' y='#{@ys}' class='tegoma'>飛</text>"
        needsuji = true
      when 'p'
        gstr += "<text x='0' y='#{@yg}' class='tegoma'>歩</text>"
        needsuji = true
      when 'l'
        gstr += "<text x='0' y='#{@yg}' class='tegoma'>香</text>"
        needsuji = true
      when 'n'
        gstr += "<text x='0' y='#{@yg}' class='tegoma'>桂</text>"
        needsuji = true
      when 's'
        gstr += "<text x='0' y='#{@yg}' class='tegoma'>銀</text>"
        needsuji = true
      when 'g'
        gstr += "<text x='0' y='#{@yg}' class='tegoma'>金</text>"
        needsuji = true
      when 'b'
        gstr += "<text x='0' y='#{@yg}' class='tegoma'>角</text>"
        needsuji = true
      when 'r'
        gstr += "<text x='0' y='#{@yg}' class='tegoma'>飛</text>"
        needsuji = true
      when '0'..'9'
        num = num * 10 + ch.to_i
      end
      next unless needsuji
      if /[A-Z]/ =~ ch
        @ys += 16
        ret = numtegoma(num, @ys)
        sstr += ret[0]
        @ys += ret[1]
      else
        @yg += 16
        ret = numtegoma(num, @yg)
        gstr += ret[0]
        @yg += ret[1]
      end
      num = 0
      needsuji = false
    end

    @stgm = sstr
    @gtgm = gstr
    # @gtgm = "<text x='0' y='0' class='tegoma'>#{gstr}</text>"
    # @stgm = "<text x='0' y='0' class='tegoma'>#{sstr}</text>"
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
    cnt = tagtitle
    cnt += tagteban
    cnt += tagname
    cnt += tagtegoma
    cnt + tagboardstatus
  end

  # svg画像の生成
  #
  # @return svg文字列。エラーの場合はエラー情報画像。
  def gen
    svg = tag_header
    svg += gen_contents
    svg + tag_footer
  end
end
