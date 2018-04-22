# -*- encoding: utf-8 -*-

require 'unindent'

# http://sfenreader.appspot.com/sfen?
# sfen=lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2&
# lm=58&
# sname=aoki&
# gname=aoki

class SfenSVGImage
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

  def setnames(sname, gname)
    @sname = sname
    @gname = gname
  end

  def settitle(title)
    @title = title
  end

  def setmoveinfo(lm, turn)
    @lm = lm
    @turn = turn
  end

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

  def tagtitle
    "<g id='title'><text class='title' x='125' y='10'>#{@title}</text></g>\n"
  end

  def tagteban
    case @turn
    when 'w'
      '<g id="teban" transform="translate(0,0)">\n' \
      ' <rect x="0" y="20" width="30" height="30" stroke="none" fill="#F3C"/>\n' \
      '</g>\n'
    when 'b'
      '<g id="teban" transform="translate(220,260)">\n' \
      ' <rect x="0" y="0" width="30" height="30" stroke="none" fill="#F3C"/>\n' \
      '</g>\n'
    else
      ''
    end
  end

  def tag_header
    ret = <<-TAG_HEADER.unindent
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
          text-anchor: left;
          dominant-baseline: middle;
          alignment-baseline: middle;
          writing-mode: tb;
          glyph-orientation-vertical: 90;
          glyph-orientation-horizontal: 270;
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
        /* ]]> */
       </style>
       <g>
      TAG_HEADER
    ret
  end

  def tag_footer
    " </g>\n</svg>\n"
  end

  def taglastmove
    return '' unless @lm

    x = @lm.to_i

    y = x % 10 - 1
    x = 9 - x / 10

    return '' if y < 0 || 8 < y || x < 0 || 8 < x  #error

    y *= 20
    x *= 20

    "<rect x='#{x}' y='#{y}' width='20' height='20' stroke='none' fill='#FF4'/>\n"
  end

  def tagboardframe
    ret = <<-TAGFRAME
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
      TAGFRAME
    ret
  end

  def tagkoma(nm, sente, x, y)
    x *= 20
    y *= 20
    ret = "<g transform='translate(#{x},#{y})'>\n"
    if sente
      ret += " <text x='10' y='12' class='koma'>#{nm}</text>\n"
    else
      ret += " <g transform='translate(10,9) rotate(180)'>\n" \
             "  <text x='0' y='0' class='koma'>#{nm}</text>\n" \
             " </g>\n"
    end

    ret + "</g>\n"
  end

  def tagkomas
    banstr = ''
    ban = @strban.split('/')
    ndan = 0
    promote = false
    ban.each do |adan|
      nsuji = 0

      adan.each_char do |ch|
        case ch
        when 'p'
          banstr += tagkoma(promote ? 'と' : '歩', false, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'l'
          banstr += tagkoma(promote ? '杏' : '香', false, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'n'
          banstr += tagkoma(promote ? '圭' : '桂', false, nsuji, ndan)
          nsuji += 1
          promote = false
        when 's'
          banstr += tagkoma(promote ? '全' : '銀', false, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'g'
          banstr += tagkoma('金', false, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'b'
          banstr += tagkoma(promote ? '馬' : '角', false, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'r'
          banstr += tagkoma(promote ? '瑠' : '飛', false, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'k'
          banstr += tagkoma('玉', false, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'P'
          banstr += tagkoma(promote ? 'と' : '歩', true, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'L'
          banstr += tagkoma(promote ? '杏' : '香', true, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'N'
          banstr += tagkoma(promote ? '圭' : '桂', true, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'S'
          banstr += tagkoma(promote ? '全' : '銀', true, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'G'
          banstr += tagkoma('金', true, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'B'
          banstr += tagkoma(promote ? '馬' : '角', true, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'R'
          banstr += tagkoma(promote ? '龍' : '飛', true, nsuji, ndan)
          nsuji += 1
          promote = false
        when 'K'
          banstr += tagkoma('玉', true, nsuji, ndan)
          nsuji += 1
          promote = false
        when '1'..'9'
          nsuji += ch.to_i
          promote = false
        when '+'
          promote = true
        else
        end
      end

      ndan += 1
    end
    banstr
  end

  def tagboardstatus
    board = "<g id='board' transform='translate(25,70)'>\n#{taglastmove}"
    board += tagboardframe
    board += tagkomas
    board + "</g>\n"
  end

  def readtegoma
    return unless @strtegoma

    num = 0
    gstr = ''
    sstr = ''

    @strtegoma.each_char do |ch|
      case ch
      when 'P'
        sstr += '歩'
        sstr += num.to_s if num > 1
        num = 0
      when 'L'
        sstr += '香'
        sstr += num.to_s if num > 1
        num = 0
      when 'N'
        sstr += '桂'
        sstr += num.to_s if num > 1
        num = 0
      when 'S'
        sstr += '銀'
        sstr += num.to_s if num > 1
        num = 0
      when 'G'
        sstr += '金'
        sstr += num.to_s if num > 1
        num = 0
      when 'B'
        sstr += '角'
        sstr += num.to_s if num > 1
        num = 0
      when 'R'
        sstr += '飛'
        sstr += num.to_s if num > 1
        num = 0
      when 'p'
        gstr += '歩'
        gstr += num.to_s if num > 1
        num = 0
      when 'l'
        gstr += '香'
        gstr += num.to_s if num > 1
        num = 0
      when 'n'
        gstr += '桂'
        gstr += num.to_s if num > 1
        num = 0
      when 's'
        gstr += '銀'
        gstr += num.to_s if num > 1
        num = 0
      when 'g'
        gstr += '金'
        gstr += num.to_s if num > 1
        num = 0
      when 'b'
        gstr += '角'
        gstr += num.to_s if num > 1
        num = 0
      when 'r'
        gstr += '飛'
        gstr += num.to_s if num > 1
        num = 0
      when '0'..'9'
        num = num * 10 + ch.to_i
      end
    end

    @stgm = sstr
    @gtgm = gstr
  end

  def tagtegoma
    gtgm = "<text x='0' y='0' class='tegoma'>#{@gtgm}</text>"
    stgm = "<text x='0' y='0' class='tegoma'>#{@stgm}</text>"

    ret = <<-TAGTEGOMA.unindent
      <g id="gtegoma" transform="translate(7.5,65)">
       <g transform="translate(4,-7)">
        <polygon points="0,-5 4,-4 5,5 -5,5 -4,-4" fill="none"/>
       </g>
       #{gtgm}
      </g>
      <g id="stegoma" transform="translate(230,65)">
       <g transform="translate(4,-7)">
        <polygon points="0,-5 4,-4 5,5 -5,5 -4,-4" fill="black"/>
       </g>
       #{stgm}
      </g>
      TAGTEGOMA

    ret
  end

  def gen_contents
    cnt = tagtitle
    cnt += tagteban
    cnt += tagname
    cnt += tagtegoma
    cnt + tagboardstatus
  end

  # @return svg文字列。エラーの場合はエラー情報画像。
  def gen
    svg = tag_header
    svg += gen_contents
    svg + tag_footer
  end
end
