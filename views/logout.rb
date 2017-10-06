# -*- encoding: utf-8 -*-

require 'cgi/session'
require './views/common_ui.rb'

#
# LOGOUT画面
#
class LogoutScreen
  # 初期化
  #
  # @param header htmlヘッダ
  # @param title  ページタイトル
  # @param name   ページヘッダタイトル
  def initialize(title, name)
    @title = title
    @name = name
  end

  # ログアウト
  #
  # @param session セッション情報オブジェクト
  def show(session)
    session.delete if session

    CommonUI::HTMLHead2(@title)
    CommonUI::HTMLmenu(@name)

    puts 'Logged out ...'

    CommonUI::HTMLfoot()
  end
end
