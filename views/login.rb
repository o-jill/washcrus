# -*- encoding: utf-8 -*-

require 'rubygems'
# require 'unindent'

require './game/userinfo.rb'
require './views/common_ui.rb'

def put_login_form
  print <<-TABLE_FORM.unindent
    <FORM action='washcrus.rb?logincheck' method=post name='signin'>
    <TABLE align='center' class='inpform'>
    <CAPTION>Log in</CAPTIOIN>
    <TR id='siemail'>
     <TD>e-mail</TD>
     <TD><INPUT name='siemail' id='siemail' type='email' size='20' class='inpform' required></TD>
    </TR>
    <TR id='sipassword'>
     <TD>password</TD>
     <TD><INPUT name='sipassword' id='sipassword' type='password' size='20' class='inpform' required></TD>
    </TR>
    <TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>
    <TR>
     <TD><input type='reset' class='inpform'></TD>
     <TD><input style='width:100%' type='submit' class='inpform'></TD>
    </TR>
    </TABLE></FORM>
    TABLE_FORM
end

#
# ログイン画面
#
def login_screen(header, title, name, _params)
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  put_login_form

  CommonUI::HTMLfoot()
end
