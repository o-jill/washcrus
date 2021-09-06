# -*- encoding: utf-8 -*-
# frozen_string_literal: true

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
     <!-- style>/* <![CDATA[ */
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
     /* ]]> */</style -->
     <g>
  EO_TAG_HEADER

  # svgフッタタグ
  TAG_FOOTER = " </g>\n</svg>\n"

  # 将棋盤フレームタグ
  TAGFRAME = <<-EO_TAGFRAME.unindent
    <g id="ban">
     <rect x="0" y="0" width="180" height="180" class='waku' fill='none' stroke='black' stroke-width='2'/>
     <rect x="0" y="20" width="180" height="20" class='line' fill='none' stroke='black' stroke-width='1'/>
     <rect x="0" y="60" width="180" height="20" class='line' fill='none' stroke='black' stroke-width='1'/>
     <rect x="0" y="100" width="180" height="20" class='line' fill='none' stroke='black' stroke-width='1'/>
     <rect x="0" y="140" width="180" height="20" class='line' fill='none' stroke='black' stroke-width='1'/>
     <rect x="20" y="0" width="20" height="180" class='line' fill='none' stroke='black' stroke-width='1'/>
     <rect x="60" y="0" width="20" height="180" class='line' fill='none' stroke='black' stroke-width='1'/>
     <rect x="100" y="0" width="20" height="180" class='line' fill='none' stroke='black' stroke-width='1'/>
     <rect x="140" y="0" width="20" height="180" class='line' fill='none' stroke='black' stroke-width='1'/>
     <text x="10" y="-5" class="suji" font-size="10px" text-anchor="middle" alignment-baseline="after-edge" dominant-baseline="after-edge">9</text>
     <text x="30" y="-5" class="suji" font-size="10px" text-anchor="middle" alignment-baseline="after-edge" dominant-baseline="after-edge">8</text>
     <text x="50" y="-5" class="suji" font-size="10px" text-anchor="middle" alignment-baseline="after-edge" dominant-baseline="after-edge">7</text>
     <text x="70" y="-5" class="suji" font-size="10px" text-anchor="middle" alignment-baseline="after-edge" dominant-baseline="after-edge">6</text>
     <text x="90" y="-5" class="suji" font-size="10px" text-anchor="middle" alignment-baseline="after-edge" dominant-baseline="after-edge">5</text>
     <text x="110" y="-5" class="suji" font-size="10px" text-anchor="middle" alignment-baseline="after-edge" dominant-baseline="after-edge">4</text>
     <text x="130" y="-5" class="suji" font-size="10px" text-anchor="middle" alignment-baseline="after-edge" dominant-baseline="after-edge">3</text>
     <text x="150" y="-5" class="suji" font-size="10px" text-anchor="middle" alignment-baseline="after-edge" dominant-baseline="after-edge">2</text>
     <text x="170" y="-5" class="suji" font-size="10px" text-anchor="middle" alignment-baseline="after-edge" dominant-baseline="after-edge">1</text>
     <text x="185" y="13" font-size="10px" text-anchor="left" >一</text>
     <text x="185" y="33" font-size="10px" text-anchor="left" >二</text>
     <text x="185" y="53" font-size="10px" text-anchor="left" >三</text>
     <text x="185" y="73" font-size="10px" text-anchor="left" >四</text>
     <text x="185" y="93" font-size="10px" text-anchor="left" >五</text>
     <text x="185" y="113" font-size="10px" text-anchor="left" >六</text>
     <text x="185" y="133" font-size="10px" text-anchor="left" >七</text>
     <text x="185" y="153" font-size="10px" text-anchor="left" >八</text>
     <text x="185" y="173" font-size="10px" text-anchor="left" >九</text>
    </g>
  EO_TAGFRAME

  TEBANRECT = " <rect x='0' y='0' width='30' height='30' class='teban'" \
         " fill='#F3C' stroke='none'/>"

  TAGWINNER = " <polygon points='15,0 22.5,5 30,0 30,30 0,30 0,0 7.5,5'" \
         " class='teban' fill='#F3C' stroke='none'/>"

  # 名前タグの生成
  #
  # @param snm 先手の名前
  # @param gnm 後手の名前
  def tagname(snm, gnm)
    nmattr = 'font-size="16px" text-anchor="left" ' \
            ' width="220px" text-overflow="ellipsis"'

    ret = <<-NAMETAG.unindent
      <g id="gname" transform="translate(5,25)">
       <polygon points="10,0 18,2 20,20 0,20 2,2" fill="none" stroke='black' stroke-width="1"/>
       <text class="name" x="25" y="15" #{nmattr}>#{gnm}</text>
      </g>
      <g id="sname" transform="translate(5,265)">
       <g transform="translate(220,0)">
        <polygon points="10,0 18,2 20,20 0,20 2,2" fill="black" stroke='black' stroke-width="1"/>
       </g>
       <text class="name" x="0" y="15" #{nmattr}>#{snm}</text>
      </g>
    NAMETAG
    ret
  end

  # タイトルタグの生成
  #
  # @param titl タイトル
  def tagtitle(titl)
    titleattr = "font-size='16px' text-anchor='middle' " \
      "width='250px' text-overflow='ellipsis'"
    "<g id='title'><text class='title' x='125' y='15' #{titleattr} >" \
    "#{titl}</text></g>\n"
  end

  # 手番タグの生成
  #
  # @param trn 手番。 b or w or gb or fw.
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
    "<text x='0' y='#{y - 1}' class='ntegoma' font-size='12px' " \
    "text-anchor='middle' dominant-baseline='top' alignment-baseline='top' " \
    ">#{num}</text>"
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
    "<text x='0' y='#{y}' class='tegoma' font-size='16px' " \
    "text-anchor='middle' dominant-baseline='top' alignment-baseline='top' >" \
    "#{koma}</text>"
  end

  # 手駒用のタグと座標の計算
  #
  # @param ch sfen文字
  # @param num 枚数
  # @param tgm 既に処理された手駒タグ
  # @param y y座標
  #
  # @return 手駒タグ
  def str_tekoma(ch, num, tgm, y)
    tgm += str_tagtgm(ch, y)
    y += 16
    tgm += numtegoma(num, y) if num > 1
    y += 16 if num > 1
    [tgm, y]
  end

  # 手駒のタグの生成
  #
  # @param stegoma
  # @param gtegoma
  #
  # @return 手駒のタグ
  def tagtegoma(stegoma, gtegoma)
    ret = <<-TAGTEGOMA.unindent
      <g id="gtegoma" transform="translate(7.5,65)">
       <g transform="translate(4,-7)">
        <polygon points="0,-5 4,-4 5,5 -5,5 -4,-4" fill="none" stroke='black'/>
       </g>
       <g transform="translate(4,16)">#{gtegoma}</g>
      </g>
      <g id="stegoma" transform="translate(230,65)">
       <g transform="translate(4,-7)">
        <polygon points="0,-5 4,-4 5,5 -5,5 -4,-4" fill="black" stroke='black'/>
       </g>
       <g transform="translate(4,16)">#{stegoma}</g>
      </g>
    TAGTEGOMA

    ret
  end
end
