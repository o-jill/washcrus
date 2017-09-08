# -*- encoding: utf-8 -*-

require 'cgi/session'
require './views/common_ui.rb'

#
# LOGOUT画面
#
class LogoutScreen
  def initialize(title, name)
    @title = title
    @name = name
  end

  def show(session)
    session.delete if session

    CommonUI::HTMLHead2(@title)
    CommonUI::HTMLmenu(@name)

    puts 'Logged out ...'

    CommonUI::HTMLfoot()
  end
end
