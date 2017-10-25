# -*- encoding: utf-8 -*-

# require 'rubygems'
require 'unindent'

require './game/userinfo.rb'
require './views/common_ui.rb'

#
# 検索画面
#
class SearchformScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # フォームの出力
  def put_search_form
    now = Time.now
    today = now.strftime('%Y/%m/%d')
    tomorrow = (now + 24 * 3600).strftime('%Y/%m/%d')

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
       <TD>time_frame before</TD>
       <TD><INPUT id='time_frame_to' name='time_frame_to' type='date' class='inpform' placeholder='#{tomorrow}'></TD>
      </TR>
      <TR>
       <TD colspan=2 align='center'><input type='button' value='Search' onClick='check_form();' class='inpform'>&nbsp;<input type='reset' class='inpform'></TD>
      </TR>
      <TR>
       <TD colspan=2 id='errmsg'></TD>
      </TR>
      </TABLE></FORM>
      TABLE_FORM
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  def show(userinfo)
    CommonUI::HTMLHead(@header)
    CommonUI::HTMLmenu(userinfo)

    put_search_form

    CommonUI::HTMLfoot()
  end
end
