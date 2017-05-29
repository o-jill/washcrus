#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './common_ui.rb'
require './userinfo.rb'

#
# ログイン画面
#
def login_screen(header, title, name, _userinfo)
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

  print <<-TABLE_FORM
    <FORM action='#{File.basename($PROGRAM_NAME)}?logincheck' method=post name='signin'>
    <TABLE align=center>
    <TR id='siemail'>
     <TD>e-mail</TD>
     <TD><INPUT name='siemail' id='siemail' type=email size=25 required></TD>
    </TR>
    <TR id='sipassword'>
     <TD>password</TD>
     <TD><INPUT name='sipassword' id='sipassword' type=password size=25 required></TD>
    </TR>
    <TR>
     <TD colspan=2><input type='submit'>&nbsp;<input type='reset'></TD>
    </TR>
    </TABLE></FORM>
    TABLE_FORM
  CommonUI::HTMLfoot()
end
