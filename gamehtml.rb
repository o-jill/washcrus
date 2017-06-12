#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'rubygems'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './userinfo.rb'

# 表示する
class GameHtml
  def initialize(gid, mi, kif, ui)
    @gameid = gid
    @mi = mi
    @jkf = kif
    @userinfo = ui
  end

  def put(header)
    print header

    print '<html>', headerelement

    print "<body><center>洗足池</center><HR>" \
          "<div class=gamearea>" \
          " <div class=block>" \
          "  <div class='block_elem_ban'>将棋盤えりあ<canvas width='480' height='320' /></div>" \
          "  <div class='block_elem_kifu'> #{kifuelement} </div>" \
          " </div>" \
          " #{chatelement}" \
          "</div>" \
          "<HR><div style='text-align:right;'>ぢるっち(c)2017</div>" \
          "</body></html>"
  end

  def headerelement
    return "<head><title>washcrus #{@mi.playerb} vs #{@mi.playerw}</title>" \
      "<META http-equiv='Content-Type' content='text/html; charset=UTF-8' >" \
      "<link rel='shortcut icon' href='./favicon.ico' />" \
      "<link rel='stylesheet' type='text/css' href='./css/washcrus.css'>" \
      "<!-- script type='text/javascript' defer src=''></script --></head>"
  end

  def chatelement
    "<div id='chatlog' class='chat'>
     チャットえりあ<BR>幅はどうやれば変わるの？<BR>-&gt;CSSでした。<BR>
     divじゃないとタグが効かないことが判明。</div>
    <!-- form action='chat.rb?#{}' method=post -->
     <input id='chatname' type='text' value='#{@userinfo.user_name}' size='10' class='chatnm' readonly />
     :<input id='chatmsg' type='text' size='60' class='chatmsg' />
     <input type='submit' onClick='void();' />
    <!-- /form -->
    <input type='hidden' id='gameid' value='#{@gameid}' />
    <script type='text/javascript' src='./js/chat.js' defer></script>"
  end

  def kifuelement
    return "<div id='kifulog' class='kifu'>#{@jkf.to_kif.gsub("\n", '<BR>')}</div>"
  end

  # class methods
end
