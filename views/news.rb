# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'unindent'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'
require './file/pathlist.rb'
# require './game/userinfo.rb'
require './views/common_ui.rb'

# htmlレンダラ with Rouge
class NewsRender < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet

  # def block_code(code, language)
  #   Rouge.highlight(code, language || 'ruby', 'html')
  # end
end

#
# NEWS画面
#
class NewsScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # newsの出力
  def put_news
    render = NewsRender.new(
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: 'nofollow', target: '_blank' }
      # with_toc_data: true
    )
    extensions = {
      autolink: true,
      disble_indented_code_blocks: true,
      # escape_html: true,
      fenced_code_blocks: true,
      highlight: true,
      no_intra_emphasis: true,
      # quote: true,
      space_after_headers: true,
      strikethrough: true,
      superscript: true,
      tables: true,
      underline: true
    }
    markdown = Redcarpet::Markdown.new(render, extensions)
    msg = markdown.render(File.read(PathList::NEWSFILE, encoding: 'utf-8'))

    puts <<-NEWS_INFO.unindent
      <div align='center'>
       NEWS
       <link rel='stylesheet' type='text/css' href='./css/news.css'>
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
