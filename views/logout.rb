# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'cgi/session'
require './views/common_ui.rb'

#
# LOGOUT画面
#
class LogoutScreen
  # 初期化
  def initialize; end

  # ログアウト
  #
  # @param session セッション情報オブジェクト
  def show(session)
    session.delete if session

    CommonUI.html_head2
    CommonUI.html_menu

    puts 'Logged out ...'

    CommonUI.html_foot
  end
end
