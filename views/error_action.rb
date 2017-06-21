#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

require 'cgi'
require './game/userinfo.rb'
require './views/common_ui.rb'

#
# ACTIONエラー画面
#
def error_action_screen(header, title, name, userinfo, params, action)
  CommonUI::HTMLHead2(title)
  CommonUI::HTMLmenu(name)

  print 'cgi.params:'
  params.each { |key, val| print key, '=', val, '&' }

  print '<HR>action=', action, "<BR>\n"

  print '<HR>HTTP_COOKIE:<BR>', ENV['HTTP_COOKIE'], "<HR>\n"

  userinfo.dumptable

  CommonUI::HTMLfoot()
end
