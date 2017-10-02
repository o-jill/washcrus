# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require 'redcarpet'
# require './game/userinfo.rb'
require './views/common_ui.rb'

#
# NEWS画面
#
class NewsScreen
  NEWSFILE = './config/news.txt'.freeze

  def initialize(header, title, name)
    @header = header
    @title = title
    @name = name
  end

  def put_news
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    msg = markdown.render(File.read(NEWSFILE))

    puts <<-NEWS_INFO.unindent
      <style type=text/css>
       .news {
         border: inset 5px blue;
         padding: 5px;
         text-align: left;
         width: 60vw;
       }
      </style>
      <div align='center'>
       NEWS
       <div class='news'>
        #{msg}
       </div>
      </div>
      NEWS_INFO
  end

  def show(userinfo)
    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenuLogIn(@name, !userinfo.invalid?)

    put_news

    CommonUI::HTMLfoot()
  end
end
