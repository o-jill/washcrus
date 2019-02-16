# -*- encoding: utf-8 -*-

require 'unindent'

# http://sfenreader.appspot.com/sfen?
# sfen=lnsgkgsnl/1r5b1/p1ppppp1p/9/9/9/P1PPPPP1P/1B2K2R1/LNSG1GSNL w 2P2p 2&
# lm=58&
# sname=aoki&
# gname=aoki

# SfenSVGImageクラス用定数
module SfenSVGImageMod
  # svgヘッダタグ
  TAG_HEADER = <<-EO_TAG_HEADER.unindent
    <?xml version="1.0"?>
    <svg width="250" height="290" viewBox="0 0 250 290" version="1.1" xmlns="http://www.w3.org/2000/svg" >
     <style>/* <![CDATA[ */
       polygon { stroke: black; stroke-width: 1px; }
       rect.waku { stroke:black; stroke-width:2; fill:none; }
       rect.line { stroke: black; stroke-width: 1; fill:none }
       line { stroke: black; stroke-width: 1; }
       text { font-size: 18px; }
       text.name { font-size: 16px; text-anchor: left;
        dominant-baseline: middle; alignment-baseline: middle;
        width: 220px; text-overflow: ellipsis; }
       text.title { font-size: 16px; text-anchor: middle;
        dominant-baseline: middle; alignment-baseline: middle;
        width: 250px; text-overflow: ellipsis; }
       text.koma { font-size: 18px; text-anchor: middle;
        dominant-baseline: middle; alignment-baseline: middle; }
       text.tegoma { font-size: 16px; text-anchor: middle;
        dominant-baseline: top; alignment-baseline: top; }
       text.ntegoma { font-size: 12px; text-anchor: middle;
        dominant-baseline: top; alignment-baseline: top; }
       text.suji { font-size: 10px; text-anchor: middle;
        alignment-baseline: after-edge; dominant-baseline: after-edge; }
       text.dan { font-size: 10px; text-anchor: left;
        dominant-baseline: middle; alignment-baseline: middle; }
       .teban { stroke : none; fill: #F3C; }
       .lastmv { stroke : none; fill: #FF4; }
     /* ]]> */</style>
     <g>
  EO_TAG_HEADER

  # svgフッタタグ
  TAG_FOOTER = " </g>\n</svg>\n".freeze

  # 将棋盤フレームタグ
  TAGFRAME = <<-EO_TAGFRAME.unindent
    <g id="ban">
     <rect x="0" y="0" width="180" height="180" class='waku'/>
     <rect x="0" y="20" width="180" height="20" class='line'/>
     <rect x="0" y="60" width="180" height="20" class='line'/>
     <rect x="0" y="100" width="180" height="20" class='line'/>
     <rect x="0" y="140" width="180" height="20" class='line'/>
     <rect x="20" y="0" width="20" height="180" class='line'/>
     <rect x="60" y="0" width="20" height="180" class='line'/>
     <rect x="100" y="0" width="20" height="180" class='line'/>
     <rect x="140" y="0" width="20" height="180" class='line'/>
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
  EO_TAGFRAME

  TEBANRECT = " <rect x='0' y='0' width='30' height='30' class='teban'/>".freeze

  TAGWINNER = " <polygon points='15,0 22.5,5 30,0 30,30 0,30 0,0 7.5,5'" \
         " class='teban'/>".freeze

  # 名前タグの生成
  def tagname(snm, gnm)
    ret = <<-NAMETAG.unindent
      <g id="gname" transform="translate(5,25)">
       <polygon points="10,0 18,2 20,20 0,20 2,2" fill="none"/>
       <text class="name" x="25" y="10">#{gnm}</text>
      </g>
      <g id="sname" transform="translate(5,265)">
       <g transform="translate(220,0)">
        <polygon points="10,0 18,2 20,20 0,20 2,2" fill="black"/>
       </g>
       <text class="name" x="0" y="10">#{snm}</text>
      </g>
    NAMETAG
    ret
  end

  # タイトルタグの生成
  def tagtitle(titl)
    "<g id='title'><text class='title' x='125' y='10'>#{titl}</text></g>\n"
  end

  # 手番タグの生成
  def tagteban(trn)
    ret = "<g id='teban' transform='translate("
    case trn
    when 'w' then
      ret + "0,20)'>\n#{SfenSVGImageMod::TEBANRECT}\n</g>\n"
    when 'b' then
      ret + "220,260)'>\n#{SfenSVGImageMod::TEBANRECT}\n</g>\n"
    when 'fw' then
      ret + "30,20)'>\n#{SfenSVGImageMod::TAGWINNER}\n</g>\n"
    when 'fb' then
      ret + "0,260)'>\n#{SfenSVGImageMod::TAGWINNER}\n</g>\n"
    else
      ''
    end
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
  def str_tagtgm(ch, y)
    pos = 'PLNSGBR'.index(ch)
    return '' unless pos
    koma = '歩香桂銀金角飛'[pos, 1]
    "<text x='0' y='#{y}' class='tegoma'>#{koma}</text>"
  end

  def str_tekoma(ch, num, tgm, y)
    tgm += str_tagtgm(ch, y)
    tgm += "a"
    y += 16
    tgm += numtegoma(num, y) if num > 1
    y += 16 if num > 1
    [tgm, y]
  end

  # 手駒のタグの生成
  def tagtegoma(stegoma, gtegoma)
    ret = <<-TAGTEGOMA.unindent
      <g id="gtegoma" transform="translate(7.5,65)">
       <g transform="translate(4,-7)">
        <polygon points="0,-5 4,-4 5,5 -5,5 -4,-4" fill="none"/>
       </g>
       <g transform="translate(4,16)">#{gtegoma}</g>
      </g>
      <g id="stegoma" transform="translate(230,65)">
       <g transform="translate(4,-7)">
        <polygon points="0,-5 4,-4 5,5 -5,5 -4,-4" fill="black"/>
       </g>
       <g transform="translate(4,16)">#{stegoma}</g>
      </g>
    TAGTEGOMA

    ret
  end
end
