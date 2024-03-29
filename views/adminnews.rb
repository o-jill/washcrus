# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'unindent'
require 'redcarpet'

require './file/pathlist.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './views/common_ui.rb'

#
# NEWS編集画面
#
class AdminNewsScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # 編集欄の出力
  def put_edit_news
    msg = File.read(PathList::NEWSFILE, encoding: 'utf-8')
    scriptname = File.basename($PROGRAM_NAME)

    puts <<-NEWS_EDIT1.unindent
      <style type=text/css>
       .news {
         border: inset 5px blue;
         padding: 5px;
         text-align: left;
         width: 60vw;
       }
      </style>
      <div align='center'>
       Edit NEWS
       <div class='news'>
        <form action='#{scriptname}?adminnewsupdate' method=post name='adminnews'>
         <input type='submit' class='inpform' id='update'/><br>
      <textarea name='news' rows='10' style='width:100%'>
    NEWS_EDIT1

    print msg

    puts <<-NEWS_EDIT2.unindent
      </textarea>
        </form>
       </div>
      </div>
    NEWS_EDIT2
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  def show(userinfo)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    put_edit_news

    CommonUI.html_foot
  end
end
