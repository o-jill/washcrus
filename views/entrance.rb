# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require './game/userinfo.rb'
require './views/common_ui.rb'

# LOGO
def show_logo_tmpl(arr)
  print <<-LOGO_TEXT.unindent
    <TABLE bgcolor='#cc9933' align='center' bordercolor='black' border='0' frame='void' rules='all'>
     <TR><TD></TD>
      <TD class='logo_edge_ud'></TD>
      <TD class='logo_edge_ud'></TD>
      <TD></TD></TR>
     <TR><TD class='logo_edge_lr'></TD>
      <TD class='logo_center'>#{arr[0]}</TD>
      <TD class='logo_center'>#{arr[1]}</TD>
      <TD class='logo_edge_lr'></TD></TR>
     <TR><TD class='logo_edge_lr'></TD>
      <TD class='logo_center'>#{arr[2]}</TD>
      <TD class='logo_center'>#{arr[3]}</TD>
      <TD class='logo_edge_lr'></TD></TR>
     <TR><TD></TD>
      <TD class='logo_edge_ud'></TD>
      <TD class='logo_edge_ud'></TD>
      <TD></TD></TR>
    </TABLE>
    LOGO_TEXT
end

def show_logo4
  show_logo_tmpl(['角', '', '銀', '飛'])
end

def show_logo3
  show_logo_tmpl(['角', '銀', '飛', ''])
end

def show_logoya
  show_logo_tmpl(%w[銀 金 金 角])
end

def show_logoikm
  show_logo_tmpl(%w[香 銀 玉 桂])
end

def show_logofkm
  show_logo_tmpl(%w[銀 香 桂 玉])
end

def show_logo
  idx = rand(5)
  case idx
  when 1 then show_logoikm
  when 2 then show_logofkm
  when 3 then show_logo3
  when 4 then show_logo4
  else show_logoya
  end
end

def test_area
  scriptname = File.basename($PROGRAM_NAME)
  print <<-TEST_AREA.unindent
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
    print "<HR><div align=center>#{userinfo.user_name}さん" \
          "#{userinfo.visitcount}回目の訪問ですね。</div><HR>\n" \
          '<input type=hidden id=isloggedin value=1/>'
  else
    print '<HR><div align=center>どなたか存じ上げませんが' \
          "#{userinfo.visitcount}回目の訪問ですね。</div><HR>\n" \
          '<input type=hidden id=isloggedin value=0/>'
  end
end

#
# 入り口画面
#
def entrance_screen(header, title, name, userinfo, cgi)
  blogin = (!userinfo.user_id.nil? && userinfo.user_id != '')

  CommonUI::HTMLHead(header, title)

  CommonUI::HTMLmenuLogIn(name, blogin)

  print "<script type='text/javascript' defer src='js/entrance.js'></script>\n"

  # LOGO
  # show_logo

  show_visitcount(blogin, userinfo)

  # test
  test_area

  # puts "<pre>header:#{header}</pre>"

  CommonUI::HTMLfoot()
end
