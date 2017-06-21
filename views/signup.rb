#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

require './game/userinfo.rb'
require './views/common_ui.rb'

def show_tableform
  print <<-TABLE_FORM
  <FORM action='#{File.basename($PROGRAM_NAME)}?register' method=post name='signup'>
  <TABLE class='inpform'>
  <TR id='trname'>
   <TD>name</TD>
   <TD><INPUT name='rname' id='rname' type='text' size='25' class='inpform' required></TD>
  </TR>
  <TR id='tremail'>
   <TD>e-mail</TD>
   <TD><INPUT name='remail' id='remail' type='email' size='25' class='inpform' required></TD>
  </TR>
  <TR id='tremail2'>
   <TD>e-mail(again)</TD>
   <TD><INPUT name='remail2' id='remail2' type='email' size='25' class='inpform' required></TD>
  </TR>
  <TR id='trpassword'>
   <TD>password</TD>
   <TD><INPUT name='rpassword' id='rpassword' type='password' size='25' class='inpform' required></TD>
  </TR>
  <TR id='trpassword2'>
   <TD>password(again)</TD>
   <TD><INPUT name='rpassword2' id='rpassword2' type='password' size='25' class='inpform' required></TD>
  </TR>
  <TR>
   <TD colspan=2><input type='button' value='submit' onClick='check_form();' class='inpform'>&nbsp;<input type='reset' class='inpform'></TD>
  </TR>
  </TABLE></FORM>
  TABLE_FORM
end

#
# 登録画面
#
def signup_screen(header, title, name, _userinfo)
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  print "<script type='text/javascript' src='./js/signup.js' defer></script>\n"

  show_tableform

  CommonUI::HTMLfoot()
end
