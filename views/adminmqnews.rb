# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'unindent'
# require 'redcarpet'

require './file/pathlist.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './views/common_ui.rb'

#
# MarqueeNEWS編集画面
#
class AdminMarqueeNewsScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # 編集欄の出力
  def put_edit_news
    msg = File.read(PathList::MQNEWSFILE, encoding: 'utf-8')
    scriptname = File.basename($PROGRAM_NAME)

    puts <<-NEWS_EDIT1.unindent
      <style type=text/css>
       .mqnews {
         border: inset 5px blue;
         padding: 5px;
         text-align: left;
         width: 60vw;
       }
      </style>
      <div align='center'>
       Edit Marquee News
       <div class='mqnews'>
        <form action='#{scriptname}?adminmqnewsupdate' method=post name='adminmqnews'>
         <input type='submit' class='inpform' id='update'/><br>
      <textarea name='mqnews' rows='10' style='width:100%'>
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
