# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require './file/pathlist.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './views/common_ui.rb'

#
# mail signature編集画面
#
class AdminSignatureScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # 編集領域の出力
  def put_edit_signature
    msg = File.read(PathList::SIGNATUREFILE, encoding: 'utf-8')
    scriptname = File.basename($PROGRAM_NAME)

    puts <<-SIGNATURE_EDIT1.unindent
      <style type=text/css>
       .news {
         border: inset 5px blue;
         padding: 5px;
         text-align: left;
         width: 60vw;
       }
      </style>
      <div align='center'>
       Edit Mail signature
       <div class='news'>
        <form action='#{scriptname}?adminsignatureupdate' method=post name='adminsignature'>
         <input type='submit' class='inpform' id='update'/><br>
      <textarea name='signature' rows='10' style='width:100%'>
    SIGNATURE_EDIT1

    print msg

    puts <<-SIGNATURE_EDIT2.unindent
      </textarea>
        </form>
       </div>
      </div>
    SIGNATURE_EDIT2
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  def show(userinfo)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    put_edit_signature

    CommonUI.html_foot
  end
end
