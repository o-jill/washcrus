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
    print <<-FORM_NEW_GAME_HEAD.unindent
      <FORM action='#{scriptname}?gennewgame' method=post name='gennewgame'>
      <TABLE align='center' class='inpform'>
       <TR id='player1'>
        <TD rowspan=2>Player 1</TD><TD>name</TD><TD><INPUT name='rname' id='rname' type=text size=20 class='inpform' required onKeyup="furifusen()"></TD>
       </TR>
       <TR id='tremail'>
        <TD>e-mail</TD><TD><INPUT name='remail' id='remail' type=email size=20 class='inpform' required></TD>
       </TR>
       <TR id='player2'>
        <TD rowspan=2>Player 2</TD><TD>name</TD><TD><INPUT name='rname2' id='rname2' type=text size=20 class='inpform' required></TD>
       </TR>
       <TR id='tremail2'>
        <TD>e-mail</TD><TD><INPUT name='remail2' id='remail2' type=email size=20 class='inpform' required></TD>
       </TR>
       <tr id='comment2'><td>comment</td><td colspan='2'><input name='cmt' id='cmt' type=text style='width:100%'></td></tr>
       <TR>
        <TD colspan=3>
        <input type='button' value='submit' class='inpform' onClick='check_form();'>&nbsp;
        <input type='reset' class='inpform'>&nbsp;
        <input type='button' id='precheck' class='inpform' value='pre-check' onClick='pre_check();'>
        <img id='komanim' src='image/komanim.gif' style='display:none'></TD>
       </TR>
       <TR><TD colspan=3>
        <input type="button" id='btnfurigoma' class='inpform' onClick='lets_furigoma();' value='Player1の振り歩先で振り駒'>
        <input type="hidden" id="furigoma" name="furigoma" value="FTFTF" class='inpform'>
      FORM_NEW_GAME_HEAD

    put_furigomaimg('', "style='display:none' width='32' height='32'")
    puts ' </TD></TR>'

    print <<-FORM_NEW_GAME_TAIL.unindent
       <TR><TD colspan='3' id='errmsg'></TD></TR>
      </TABLE>
      </FORM>
      FORM_NEW_GAME_TAIL
  end

  # フォームの出力2
  #
  # @param udb UserInfoFileContentオブジェクト
  def show_newgameform2(udb)
    userselect1 = udb.to_select_id_name('rid', 'rid', 'inpform',
                                        "onchange='furifusen2();'")
    userselect2 = udb.to_select_id_name('rid2', 'rid2', 'inpform', '')
    scriptname = File.basename($PROGRAM_NAME)
    print <<-FORM_NEW_GAME_HEAD.unindent
      <form action='#{scriptname}?gennewgame2' method=post name='gennewgame2'>
      <table align='center' class='inpform'>
       <tr id='player21'><td>player 1</td><td>#{userselect1}</td></tr>
       <tr id='player22'><td>player 2</td><td>#{userselect2}</td></tr>
       <tr id='teai'>
        <td>手合</td>
        <td>
         <select id='teai' class='inpform' name='teai'>
          <option value='HIRATE'>平手</option>
         </select>
        </td>
       </tr>
       <tr id='comment2'><td>comment</td><td><input name='cmt2' id='cmt2' type=text style='width:100%'></td></tr>
       <tr>
        <td colspan=2>
         <input type="button" id='btnfurigoma2' class='inpform' onclick='lets_furigoma2();' value='player1の振り歩先で振り駒'>
         <input type="hidden" id="furigoma2" name="furigoma" value="FTFTF" class='inpform'>
        </td>
       </tr>
      FORM_NEW_GAME_HEAD

    puts " <tr height='32px'><td colspan=2>"
    sz_and_style = "style='display:none' width='32' height='32'"
    put_furigomaimg('2', sz_and_style)
    puts ' </td></tr>'

    print <<-FORM_NEW_GAME_TAIL.unindent
       <tr>
        <td><input type='reset' class='inpform'></td>
        <td align=center>
         <input type='button' value='作成' class='inpform' style='width:100%' onclick='check_form2();'>
        </td>
       </tr>
       <tr><td colspan='3' id='errmsg2'></td></tr>
      </table>
      </form>
      FORM_NEW_GAME_TAIL
  end

  # 振り駒用の画像タグの出力
  def put_furigomaimg(prefix, style)
    (1..5).each do |i|
      puts <<-KOMAIMG.unindent
        <img id='furikomanim#{prefix}#{i}' src='image/komanim.gif' #{style}>
        <img id='furikomafu#{prefix}#{i}' src='image/komafu.png' #{style}>
        <img id='furikomato#{prefix}#{i}' src='image/komato.png' #{style}>
        KOMAIMG
    end
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
    show_newgameform2(udb.content)

    puts "<HR>\n"

    puts "<script type='text/javascript' src='./js/newgame.js' defer></script>"
    show_newgameform

    CommonUI.html_foot
  end
end
