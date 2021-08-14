# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'cgi'
require './game/userinfo.rb'
require './views/common_ui.rb'

#
# ACTIONエラー画面
#
# @param userinfo ユーザー情報
# @param params 入力パラメータ
# @param action 試みた行動
def error_action_screen(userinfo, params, action)
  CommonUI.html_head2
  CommonUI.html_menu

  print 'cgi.params:'
  params.each { |key, val| print key, '=', val, '&' }

  puts "<HR>action=#{action}<BR>"

  puts "<HR>HTTP_COOKIE:<BR>#{ENV['HTTP_COOKIE']}<HR>"

  userinfo.dumptable

  CommonUI.html_foot
end
