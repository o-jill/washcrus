# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require 'redcarpet'
# require './game/userinfo.rb'
require './views/common_ui.rb'

#
# NEWS編集結果画面
#
class AdminNewsUpdateScreen
  NEWSFILE = './config/news.txt'.freeze

  def initialize(header, title)
    @header = header
    @title = title
    @errmsg = ''
  end

  def write_param(params)
    if params['news'].nil?
      @errmsg += 'invalid parameters...<br>'
    else
      update_news(params['news'][0])
    end
  end

  def update_news(news)
    File.write(NEWSFILE, news)
  rescue
    @errmsg += 'failed to update...'
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
       NEWS updated
       <div class='news'>
        #{msg}
       </div>
      </div>
      NEWS_INFO
  end

  def show(userinfo, params)
    return puts "Content-Type: text/plain;\n\nERR_NOT_ADMIN" \
        unless userinfo.admin

    write_param(params)

    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(userinfo)
    CommonUI::HTMLAdminMenu()

    if @errmsg.length.zero?
      put_news
    else
      puts @errmsg
    end

    CommonUI::HTMLfoot()
  end
end
