#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './common_ui.rb'
require './userinfo.rb'

#
# 登録画面
#
def signup_screen(header, title, name, _userinfo)
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  print <<-STYLESHEET
    <style type="text/css">
    <!--
      table { font-size: 2rem; }
      input { font-size: 2rem; }
    -->
    </style>
    STYLESHEET

  print "<script type='text/javascript' src='./js/signup.js' defer></script>\n"

  print <<-TABLE_FORM
    <FORM action='#{File.basename($PROGRAM_NAME)}?register' method=post name='signup'>
    <TABLE>
    <TR id='trname'>
     <TD>name</TD>
     <TD><INPUT name='rname' id='rname' type=text size=25 required></TD>
    </TR>
    <TR id='tremail'>
     <TD>e-mail</TD>
     <TD><INPUT name='remail' id='remail' type=email size=25 required></TD>
    </TR>
    <TR id='tremail2'>
     <TD>e-mail(again)</TD>
     <TD><INPUT name='remail2' id='remail2' type=email size=25 required></TD>
    </TR>
    <TR id='trpassword'>
     <TD>password</TD>
     <TD><INPUT name='rpassword' id='rpassword' type=password size=25 required></TD>
    </TR>
    <TR id='trpassword2'>
     <TD>password(again)</TD>
     <TD><INPUT name='rpassword2' id='rpassword2' type=password size=25 required></TD>
    </TR>
    <TR>
     <TD colspan=2><input type='button' value='submit' onClick='check_form();'>&nbsp;<input type='reset'></TD>
    </TR>
    </TABLE></FORM>
    TABLE_FORM

  CommonUI::HTMLfoot()
end
