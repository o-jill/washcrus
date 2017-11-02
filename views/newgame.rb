# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require './file/userinfofile.rb'
require './game/userinfo.rb'
require './views/common_ui.rb'

#
# 対局登録画面
#
class NewGameScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # フォームの出力
  def show_newgameform
    scriptname = File.basename($PROGRAM_NAME)
    print <<-FORM_NEW_GAME.unindent
      <FORM action='#{scriptname}?gennewgame' method=post name='gennewgame'>
      <TABLE align='center' class='inpform'>
       <TR id='player1'>
        <TD rowspan=2>Player 1</TD><TD>name</TD><TD><INPUT name='rname' id='rname' type=text size=25 class='inpform' required onKeyup="furifusen()"></TD>
       </TR>
       <TR id='tremail'>
        <TD>e-mail</TD><TD><INPUT name='remail' id='remail' type=email size=25 class='inpform' required></TD>
       </TR>
       <TR id='player2'>
        <TD rowspan=2>Player 2</TD><TD>name</TD><TD><INPUT name='rname2' id='rname2' type=text size=25 class='inpform' required></TD>
       </TR>
       <TR id='tremail2'>
        <TD>e-mail</TD><TD><INPUT name='remail2' id='remail2' type=email size=25 class='inpform' required></TD>
       </TR>
       <TR>
        <TD colspan=3>
        <input type='button' value='submit' class='inpform' onClick='check_form();'>&nbsp;
        <input type='reset' class='inpform'>&nbsp;
        <input type='button' id='precheck' class='inpform' value='pre-check' onClick='pre_check();'>
        <img id='komanim' src='image/komanim.gif' style='display:none'></TD>
       </TR>
       <TR>
        <TD colspan=3>
         <input type="button" id='btnfurigoma' class='inpform' onClick='lets_furigoma();' value='Player1の振り歩先で振り駒'>
         <input type="hidden" id="furigoma" name="furigoma" value="FTFTF" class='inpform'>
         <img id='furikomanim1' src='image/komanim.gif' style='display:none' width='32' height='32'>
         <img id='furikomafu1' src='image/komafu.png' style='display:none' width='32' height='32'>
         <img id='furikomato1' src='image/komato.png' style='display:none' width='32' height='32'>
         <img id='furikomanim2' src='image/komanim.gif' style='display:none' width='32' height='32'>
         <img id='furikomafu2' src='image/komafu.png' style='display:none' width='32' height='32'>
         <img id='furikomato2' src='image/komato.png' style='display:none' width='32' height='32'>
         <img id='furikomanim3' src='image/komanim.gif' style='display:none' width='32' height='32'>
         <img id='furikomafu3' src='image/komafu.png' style='display:none' width='32' height='32'>
         <img id='furikomato3' src='image/komato.png' style='display:none' width='32' height='32'>
         <img id='furikomanim4' src='image/komanim.gif' style='display:none' width='32' height='32'>
         <img id='furikomafu4' src='image/komafu.png' style='display:none' width='32' height='32'>
         <img id='furikomato4' src='image/komato.png' style='display:none' width='32' height='32'>
         <img id='furikomanim5' src='image/komanim.gif' style='display:none' width='32' height='32'>
         <img id='furikomafu5' src='image/komafu.png' style='display:none' width='32' height='32'>
         <img id='furikomato5' src='image/komato.png' style='display:none' width='32' height='32'>
        </TD>
       </TR>
       <TR><TD colspan='3' id='errmsg'></TD></TR>
      </TABLE>
      </FORM>
      FORM_NEW_GAME
  end

  # フォームの出力2
  #
  # @param udb UserInfoFileオブジェクト
  def show_newgameform2(udb)
    userselect1 = udb.to_select_id_name('rid', 'rid', 'inpform',
                                        "onchange='furifusen2();'")
    userselect2 = udb.to_select_id_name('rid2', 'rid2', 'inpform', '')
    scriptname = File.basename($PROGRAM_NAME)
    print <<-FORM_NEW_GAME.unindent
      <form action='#{scriptname}?gennewgame2' method=post name='gennewgame2'>
      <table align='center' class='inpform'>
       <tr id='player21'>
        <td>player 1</td><td>#{userselect1}</td>
       </tr>
       <tr id='player22'>
        <td>player 2</td><td>#{userselect2}</td>
       </tr>
       <tr id='teai'>
        <td>手合</td>
        <td>
         <select id='teai' class='inpform' name='teai'>
          <option value='HIRATE'>平手</option>
         </select>
        </td>
       </tr>
       <tr>
        <td colspan=2>
         <input type="button" id='btnfurigoma2' class='inpform' onclick='lets_furigoma2();' value='player1の振り歩先で振り駒'>
         <input type="hidden" id="furigoma2" name="furigoma" value="FTFTF" class='inpform'>
        </td>
       </tr>
       <tr height='32px'>
        <td colspan=2>
         <img id='furikomanim21' src='image/komanim.gif' style='display:none' width='32' height='32'>
         <img id='furikomafu21' src='image/komafu.png' style='display:none' width='32' height='32'>
         <img id='furikomato21' src='image/komato.png' style='display:none' width='32' height='32'>
         <img id='furikomanim22' src='image/komanim.gif' style='display:none' width='32' height='32'>
         <img id='furikomafu22' src='image/komafu.png' style='display:none' width='32' height='32'>
         <img id='furikomato22' src='image/komato.png' style='display:none' width='32' height='32'>
         <img id='furikomanim23' src='image/komanim.gif' style='display:none' width='32' height='32'>
         <img id='furikomafu23' src='image/komafu.png' style='display:none' width='32' height='32'>
         <img id='furikomato23' src='image/komato.png' style='display:none' width='32' height='32'>
         <img id='furikomanim24' src='image/komanim.gif' style='display:none' width='32' height='32'>
         <img id='furikomafu24' src='image/komafu.png' style='display:none' width='32' height='32'>
         <img id='furikomato24' src='image/komato.png' style='display:none' width='32' height='32'>
         <img id='furikomanim25' src='image/komanim.gif' style='display:none' width='32' height='32'>
         <img id='furikomafu25' src='image/komafu.png' style='display:none' width='32' height='32'>
         <img id='furikomato25' src='image/komato.png' style='display:none' width='32' height='32'>
        </td>
       </tr>
       <tr>
        <td><input type='reset' class='inpform'></td>
        <td align=center>
         <input type='button' value='作成' class='inpform' style='width:100%' onclick='check_form2();'>
        </td>
       </tr>
       <tr><td colspan='3' id='errmsg2'></td></tr>
      </table>
      </form>
      FORM_NEW_GAME
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  def show(userinfo)
    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    CommonUI.html_adminmenu

    udb = UserInfoFile.new
    udb.read
    show_newgameform2(udb)

    puts "<HR>\n"

    puts "<script type='text/javascript' src='./js/newgame.js' defer></script>"
    show_newgameform

    CommonUI.html_foot
  end
end
