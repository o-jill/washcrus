# -*- encoding: utf-8 -*-

require './game/userinfo.rb'
require './file/adminconfigfile.rb'
require './file/userinfofile.rb'
require './views/common_ui.rb'

#
# userlist画面
#
def userlist_screen(header, title, name, userinfo)
  ac = AdminConfigFile.new
  ac.read
  unless ac.exist?(userinfo.user_id)
    return puts "Content-Type: text/plain;\n\nERR_NOT_ADMIN"
  end

  userdb = UserInfoFile.new
  userdb.read

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenuLogIn(name)

  userdb.dumphtml

  CommonUI::HTMLfoot()
end
