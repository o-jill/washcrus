# -*- encoding: utf-8 -*-

require 'cgi/session'
require './views/common_ui.rb'

#
# LOGOUT画面
#
def logout_screen(session, title, name)
  session.delete

  CommonUI::HTMLHead2(title)
  CommonUI::HTMLmenu(name)

  puts 'Logged out ...'

  CommonUI::HTMLfoot()
end
