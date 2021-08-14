# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'cgi/session'
require 'logger'
require './views/common_ui.rb'
require './file/pathlist.rb'

#
# LOGOUT画面
#
class LogoutScreen
  # 初期化
  def initialize
    @log = Logger.new(PathList::LOGINOUTLOG)
  end

  # ログアウト
  #
  # @param session セッション情報オブジェクト
  def show(session)
    @log.info("user #{session['user_id']} logout.") if session
    session&.delete

    CommonUI.html_head2
    CommonUI.html_menu

    puts 'Logged out ...'

    CommonUI.html_foot
  end
end
