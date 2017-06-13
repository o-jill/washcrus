#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './game/userinfo.rb'
require './views/common_ui.rb'

# LOGO
def show_logo
  print <<-LOGO_TEXT
    <TABLE bgcolor='#cc9933' align='center' bordercolor='black' border='0' frame='void' rules='all'>
     <TR><TD><span style='font-size:3em'>&nbsp;&nbsp;&nbsp;</span></TD>
      <TD></TD>
      <TD></TD>
      <TD><span style='font-size:3em'>&nbsp;&nbsp;&nbsp;</span></TD></TR>
     <TR><TD></TD>
      <TD><strong><span style='font-size:12em'>角</span></strong></TD>
      <TD></TD>
      <TD></TD></TR>
     <TR><TD></TD>
      <TD><strong><span style='font-size:12em'>銀</span></strong></TD>
      <TD><strong><span style='font-size:12em'>飛</span></strong></TD>
      <TD></TD></TR>
     <TR><TD><span style='font-size:2em'>&nbsp;</span></TD>
      <TD></TD>
      <TD></TD>
      <TD><span style='font-size:2em'>&nbsp;</span></TD></TR>
    </TABLE>
    LOGO_TEXT
end

def test_area
  scriptname = File.basename($PROGRAM_NAME)
  print <<-TEST_AREA
  <span id=signup><A href='#{scriptname}?signup'>signup</a></span><BR>
  <span id=signin><A href='#{scriptname}?login'>signin</a></span><BR>
  <span id=users><A href='#{scriptname}?userlist'>users</a></span><BR>
  <span id=matchs><A href='#{scriptname}?matchlist'>matchs</a></span><BR>
  <span id=signout><A href='#{scriptname}?logout'>signout</a></span><BR>
  <span id=create><A href='#{scriptname}?newgame'>newgame</a></span><BR>
  <A href='washcrus.rb?anywhere'>anywhere</a>
TEST_AREA
end

def show_visitcount(blogin, userinfo)
  if blogin
    print '<HR><div align=center>', userinfo.user_name, 'さん',
          userinfo.visitcount, "回目の訪問ですね。</div><HR>\n",
          '<input type=hidden id=isloggedin value=1/>'
  else
    print '<HR><div align=center>どなたか存じ上げませんが',
          userinfo.visitcount, "回目の訪問ですね。</div><HR>\n",
          '<input type=hidden id=isloggedin value=0/>'
  end
end

#
# 入り口画面
#
def entrance_screen(header, title, name, userinfo)
  blogin = (!userinfo.user_id.nil? && userinfo.user_id != '')

  CommonUI::HTMLHead(header, title)

  CommonUI::HTMLmenuLogIn(name, blogin)

  print "<script type='text/javascript' defer src='js/entrance.js'></script>\n"

  # LOGO
  # show_logo

  show_visitcount(blogin, userinfo)

  # test
  test_area

  CommonUI::HTMLfoot()
end