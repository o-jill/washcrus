# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require 'redcarpet'
require './game/userinfo.rb'
require './views/common_ui.rb'

#
# NEWS編集画面
#
class AdminNewsScreen
  NEWSFILE = './config/news.txt'.freeze

  def initialize(header)
    @header = header
  end

  def put_edit_news
    msg = File.read(NEWSFILE)
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

  def show(userinfo)
    return puts "Content-Type: text/plain;\n\nERR_NOT_ADMIN" \
        unless userinfo.admin

    CommonUI::HTMLHead(@header)
    CommonUI::HTMLmenu(userinfo)
    CommonUI::HTMLAdminMenu()

    put_edit_news

    CommonUI::HTMLfoot()
  end
end
