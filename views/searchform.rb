# -*- encoding: utf-8 -*-

# require 'rubygems'
# require 'unindent'

require './game/userinfo.rb'
require './views/common_ui.rb'

def put_search_form
  today = Time.now.strftime('%Y/%m/%d')

  print <<-TABLE_FORM.unindent
    <script type='text/javascript' defer src='js/searchform.js'></script>
    <FORM action='#{File.basename($PROGRAM_NAME)}?search' method='post' name='searchform'>
    <TABLE align='center' class='inpform' border='3'>
    <TR>
     <TD>player1</TD>
     <TD><INPUT id='player1' name='player1' type='search' class='inpform' placeholder='先手太郎'></TD>
    </TR>
    <TR>
     <TD>player2</TD>
     <TD><INPUT id='player2' name='player2' type='search' class='inpform' placeholder='後手花子'></TD>
    </TR>
    <TR>
     <TD>time_frame from</TD>
     <TD><INPUT id='time_frame_from' name='time_frame_from' type='date' class='inpform' placeholder='#{today}'></TD>
    </TR>
    <TR>
     <TD>time_frame to</TD>
     <TD><INPUT id='time_frame_to' name='time_frame_to' type='date' class='inpform' placeholder='#{today}'></TD>
    </TR>
    <TR>
     <TD colspan=2 align='center'><input type='button' value='Search' onClick='check_form();' class='inpform'>&nbsp;<input type='reset' class='inpform'></TD>
    </TR>
    </TABLE></FORM>
    TABLE_FORM
end

#
# 検索画面
#
def searchform_screen(header, title, name, userinfo)
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenuLogIn(name, !userinfo.invalid?)

  put_search_form

  CommonUI::HTMLfoot()
end
