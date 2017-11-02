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

  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # newsの出力
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

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  def show(userinfo)
    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    put_news

    CommonUI.html_foot
  end
end
