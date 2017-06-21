#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

require './game/userinfo.rb'
require './views/common_ui.rb'

def put_login_form
  print <<-TABLE_FORM
    <FORM action='#{File.basename($PROGRAM_NAME)}?logincheck' method=post name='signin'>
    <TABLE align='center' class='inpform'>
    <TR id='siemail'>
     <TD>e-mail</TD>
     <TD><INPUT name='siemail' id='siemail' type='email' size='25' class='inpform' required></TD>
    </TR>
    <TR id='sipassword'>
     <TD>password</TD>
     <TD><INPUT name='sipassword' id='sipassword' type='password' size='25' class='inpform' required></TD>
    </TR>
    <TR>
     <TD colspan=2><input type='submit' class='inpform'>&nbsp;<input type='reset' class='inpform'></TD>
    </TR>
    </TABLE></FORM>
    TABLE_FORM
end

#
# ログイン画面
#
def login_screen(header, title, name, _userinfo)
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  put_login_form

  CommonUI::HTMLfoot()
end
