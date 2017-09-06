# -*- encoding: utf-8 -*-

require 'cgi/session'
require './views/common_ui.rb'

#
# LOGOUT画面
#
def logout_screen(session, title, name)
  session.delete

  # header = cgi.header('charset' => 'UTF-8',
  #                     'expires' => 'Thu, 1-Jan-1970 00:00:00 GMT')
  # header = header.gsub("\r\n", "\n")
  #
  # CommonUI::HTMLHead(header, title)

  CommonUI::HTMLHead2(title)
  CommonUI::HTMLmenu(name)

  puts 'Logged out ...'

  CommonUI::HTMLfoot()
end
