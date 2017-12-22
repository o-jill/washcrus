# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require 'redcarpet'

require './file/pathlist.rb'
require './game/userinfo.rb'
require './views/common_ui.rb'
require './views/news.rb'

#
# NEWS編集結果画面
#
class AdminNewsUpdateScreen < NewsScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
    @errmsg = ''
  end

  # news内容の確認と保存
  #
  # @param params パラメータハッシュオブジェクト
  def write_param(params)
    if params['news']
      update_news(params['news'][0])
    else
      @errmsg += 'invalid parameters...<br>'
    end
  end

  # newsをファイルに書き込む
  #
  # @param news newsの内容
  def update_news(news)
    File.write(PathList::NEWSFILE, news)
  rescue
    @errmsg += 'failed to update...'
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return puts "Content-Type: text/plain;\n\nERR_NOT_ADMIN" \
        unless userinfo.admin

    write_param(params)

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    if @errmsg.length.zero?
      put_news
    else
      puts @errmsg
    end

    CommonUI.html_foot
  end
end
