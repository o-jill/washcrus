# -*- encoding: utf-8 -*-

require './file/adminconfigfile.rb'
require './file/userinfofile.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './views/common_ui.rb'

#
# userlist画面
#
def userlist_screen(header, userinfo)
  return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

  userdb = UserInfoFile.new
  userdb.read

  CommonUI.html_head(header)
  CommonUI.html_menu(userinfo)

  CommonUI.html_adminmenu

  userdb.dumphtml

  CommonUI.html_foot
end
