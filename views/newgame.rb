# -*- encoding: utf-8 -*-

require 'rubygems'
# require 'unindent'
require './game/userinfo.rb'
require './views/common_ui.rb'

#
# 対局登録画面
#
class NewGameScreen
  def initialize(header, title, name)
    @header = header
    @title = title
    @name = name
  end

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
      </TABLE>
      </FORM>
      FORM_NEW_GAME
  end

  def show(userinfo)
    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(@name, userinfo)

    puts "<script type='text/javascript' src='./js/newgame.js' defer></script>"
    show_newgameform

    CommonUI::HTMLfoot()
  end
end
