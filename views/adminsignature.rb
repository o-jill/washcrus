# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
# require './game/userinfo.rb'
require './views/common_ui.rb'

#
# mail signature編集画面
#
class AdminSignatureScreen
  SIGNATUREFILE = './config/signature.txt'.freeze

  # 初期化
  #
  # @param header htmlヘッダ
  # @param title  ページタイトル
  # @param name   ページヘッダタイトル
  def initialize(header, title, name)
    @header = header
    @title = title
    @name = name
  end

  # 編集領域の出力
  def put_edit_signature
    msg = File.read(SIGNATUREFILE)
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
    return puts "Content-Type: text/plain;\n\nERR_NOT_ADMIN" \
        unless userinfo.admin

    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(@name, userinfo)
    CommonUI::HTMLAdminMenu()

    put_edit_signature

    CommonUI::HTMLfoot()
  end
end
