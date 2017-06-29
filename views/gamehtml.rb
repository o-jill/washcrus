# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './game/userinfo.rb'

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
    print <<-HTMLELEMENTS.unindent
      <html>
      #{headerelement}
      <body><center>洗足池</center><HR>
      <div class=gamearea>
       <div class=block>
        <div class='block_elem_ban' id='block_elem_ban'> #{banelement} </div>
        <div class='block_elem_kifu'> #{kifuelement} </div>
       </div>
       #{chatelement}
      </div>
      <HR><div style='text-align:right;'>ぢるっち(c)2017</div>
      <div class='fogscreen' id='fogscreen'>
       <section class='msg_fogscreen' id='msg_fogscreen'>
        <BIG>sending data to server..</BIG><img src='image/komanim.gif'>
       </section>
      </div>
<div style="align-items: center; -webkit-align-items: center; justify-content: center; -webkit-justify-content: center; display: -webkit-flex; position:absolute; visibility:hidden; background-Color:white; opacity: 0.8; width:100%; height:100%;" id="fogscreen">
</div>
      </body></html>
HTMLELEMENTS
  end

  def banelement
    ret = <<-BOARD_TEXT.unindent
      <table id='gotegoma' class='gotegoma' border='0'>
       <tr id='gg_fu'>
        <td id='gg_hisha_img' width='45' height='45'>飛車</td><td id='gg_hisha_num' align='center'>0</td>
        <td id='gg_kaku_img' width='45'>角行</td><td id='gg_kaku_num' align='center'>0</td>
        <td id='gg_kin_img' width='45'>金将</td><td id='gg_kin_num' align='center'>0</td>
        <td id='gg_gin_img' width='45'>銀将</td><td id='gg_gin_num' align='center'>0</td>
        <td id='gg_kei_img' width='45'>桂馬</td><td id='gg_kei_num' align='center'>0</td>
        <td id='gg_kyo_img' width='45'>香車</td><td id='gg_kyo_num' align='center'>0</td>
        <td id='gg_fu_img' width='45'>歩</td><td id='gg_fu_num' align='center'>0</td>
       </tr>
      </table>
      <table id='ban' class='ban' border='2'>
       <tr><th width='45'>９</th><th width='45'>８</th><th width='45'>７</th><th width='45'>６</th><th width='45'>５</th><th width='45'>４</th><th width='45'>３</th><th width='45'>２</th><th width='45'>１</th><th>&nbsp;</th></tr>
       <tr><td id='b91'>---</td><td id='b81'>---</td><td id='b71'>---</td><td id='b61'>---</td><td id='b51'>---</td><td id='b41'>---</td><td id='b31'>---</td><td id='b21'>---</td><td id='b11'>---</td><th height='45'>一</th></tr>
       <tr><td id='b92'>---</td><td id='b82'>---</td><td id='b72'>---</td><td id='b62'>---</td><td id='b52'>---</td><td id='b42'>---</td><td id='b32'>---</td><td id='b22'>---</td><td id='b12'>---</td><th height='45'>二</th></tr>
       <tr><td id='b93'>---</td><td id='b83'>---</td><td id='b73'>---</td><td id='b63'>---</td><td id='b53'>---</td><td id='b43'>---</td><td id='b33'>---</td><td id='b23'>---</td><td id='b13'>---</td><th height='45'>三</th></tr>
       <tr><td id='b94'>---</td><td id='b84'>---</td><td id='b74'>---</td><td id='b64'>---</td><td id='b54'>---</td><td id='b44'>---</td><td id='b34'>---</td><td id='b24'>---</td><td id='b14'>---</td><th height='45'>四</th></tr>
       <tr><td id='b95'>---</td><td id='b85'>---</td><td id='b75'>---</td><td id='b65'>---</td><td id='b55'>---</td><td id='b45'>---</td><td id='b35'>---</td><td id='b25'>---</td><td id='b15'>---</td><th height='45'>五</th></tr>
       <tr><td id='b96'>---</td><td id='b86'>---</td><td id='b76'>---</td><td id='b66'>---</td><td id='b56'>---</td><td id='b46'>---</td><td id='b36'>---</td><td id='b26'>---</td><td id='b16'>---</td><th height='45'>六</th></tr>
       <tr><td id='b97'>---</td><td id='b87'>---</td><td id='b77'>---</td><td id='b67'>---</td><td id='b57'>---</td><td id='b47'>---</td><td id='b37'>---</td><td id='b27'>---</td><td id='b17'>---</td><th height='45'>七</th></tr>
       <tr><td id='b98'>---</td><td id='b88'>---</td><td id='b78'>---</td><td id='b68'>---</td><td id='b58'>---</td><td id='b48'>---</td><td id='b38'>---</td><td id='b28'>---</td><td id='b18'>---</td><th height='45'>八</th></tr>
       <tr><td id='b99'>---</td><td id='b89'>---</td><td id='b79'>---</td><td id='b69'>---</td><td id='b59'>---</td><td id='b49'>---</td><td id='b39'>---</td><td id='b29'>---</td><td id='b19'>---</td><th height='45'>九</th></tr>
      </table>
      <table id='sentegoma' class='sentegoma' border='0'>
       <tr id='sg_fu'>
        <td id='sg_fu_img' width='45' height='45'>歩</td><td id='sg_fu_num' align='center'>0</td>
        <td id='sg_kyo_img' width='45'>香車</td><td id='sg_kyo_num' align='center'>0</td>
        <td id='sg_kei_img' width='45'>桂馬</td><td id='sg_kei_num' align='center'>0</td>
        <td id='sg_gin_img' width='45'>銀将</td><td id='sg_gin_num' align='center'>0</td>
        <td id='sg_kin_img' width='45'>金将</td><td id='sg_kin_num' align='center'>0</td>
        <td id='sg_kaku_img' width='45'>角行</td><td id='sg_kaku_num' align='center'>0</td>
        <td id='sg_hisha_img' width='45'>飛車</td><td id='sg_hisha_num' align='center'>0</td>
       </tr>
      </table>
      <div id="narimenu" style="border:2px solid black; position:absolute; visibility:hidden; background-Color:gray;" width="100">
       <div align="center">
        <span id="naru" style="color:red;">&nbsp;成り&nbsp;</span>
        <HR>
        <span id="narazu">&nbsp;不成&nbsp;</span>
       </div>
      </div>
      <label><input type='checkbox' id='hifumineye' onclick='check_hifumin_eye();'>ひふみんアイ</input></label>
      <script type='text/javascript' src='./js/shogi.js'></script>
      <script type='text/javascript' src='./js/ui.js' async></script>
      BOARD_TEXT
    ret += "<span style='display:none;' id='sfen_'>#{@mi.sfen}</span>"
    # ret += "<input type='text' size ='60' id='sfen'>#{@mi.sfen}</input><BR>"
    # ret += "<input type='text' size ='60' id='sfen' value='#{@mi.sfen}'/><BR>"
    ret += "<input type='hidden' size ='10' id='jsonmove' value=''/><BR>"
    if @mi.idb == @userinfo.user_id && @mi.teban == 'b'
      ret += "先手の#{@userinfo.user_name}さんの手番です。"
      ret += "<input type='hidden' id='myturn' value='1'/>"
    elsif @mi.idw == @userinfo.user_id && @mi.teban == 'w'
      ret += "後手の#{@userinfo.user_name}さんの手番です。"
      ret += "<input type='hidden' id='myturn' value='1'/>"
    else
      ret += "<input type='hidden' id='myturn' value='0'/>"
    end

    ret
  end

  def headerelement
    "<head><title>washcrus #{@mi.playerb} vs #{@mi.playerw}</title>" \
      "<META http-equiv='Content-Type' content='text/html; charset=UTF-8' >" \
      "<meta http-equiv='Pragma' content='no-chache' />" \
      "<meta http-equiv='cache-control' content='no-cache' />" \
      "<meta http-equiv='expires' content='0' />" \
      "<link rel='shortcut icon' href='./image/favicon.ico' />" \
      "<link rel='stylesheet' type='text/css' href='./css/washcrus.css'>" \
      "<!-- script type='text/javascript' defer src=''></script --></head>"
  end

  def chatelement
    "<div id='chatlog' class='chat'>
     チャットえりあ<BR>幅はどうやれば変わるの？<BR>-&gt;CSSでした。<BR>
     divじゃないとタグが効かないことが判明。</div>
     <input id='chatname' type='text' value='#{@userinfo.user_name}' size='10' class='chatnm' readonly/>
     :<input id='chatmsg' type='text' size='60' class='chatmsg'/>
     <input type='button' id='chatbtn' onClick='onChatSay();' value='&gt;&gt;'/>
     <input type='hidden' id='gameid' value='#{@gameid}'/>
    <script type='text/javascript' src='./js/chat.js' defer></script>"
  end

  def kifuelement
    "<textarea id='kifulog' class='kifu' readonly>#{@jkf.to_kif}</textarea>"
    # "<div id='kifulog' class='kifu'>#{@jkf.to_kif.gsub("\n", '<BR>')}</div>"
  end

  # class methods
end
