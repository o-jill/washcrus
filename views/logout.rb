# -*- encoding: utf-8 -*-

require 'cgi/session'
require './views/common_ui.rb'

#
# LOGOUT画面
#
class LogoutScreen
  # 初期化
  def initialize
  end

  # ログアウト
  #
  # @param session セッション情報オブジェクト
  def show(session)
    session.delete if session

    CommonUI::HTMLHead2()
    CommonUI::HTMLmenu()

    puts 'Logged out ...'

    CommonUI::HTMLfoot()
  end
end
