#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './common_ui.rb'
require './file/userinfofile.rb'

#
# userlist画面
#
def userlist_screen(header, title, name, _userinfo)
  userdb = UserInfoFile.new
  userdb.read

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  userdb.dumphtml

  CommonUI::HTMLfoot()
end
