# -*- encoding: utf-8 -*-

require './file/adminconfigfile.rb'
require './file/userinfofile.rb'
require './game/userinfo.rb'
require './views/common_ui.rb'

#
# userlist画面
#
def userlist_screen(header, title, name, userinfo)
  return puts "Content-Type: text/plain;\n\nERR_NOT_ADMIN" unless userinfo.admin

  userdb = UserInfoFile.new
  userdb.read

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name, userinfo)

  userdb.dumphtml

  CommonUI::HTMLfoot()
end
