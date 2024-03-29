# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require './file/adminconfigfile.rb'
require './file/userinfofile.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './views/common_ui.rb'

#
# userlist画面
#
# @param header htmlヘッダ
# @param userinfo ユーザー情報
def userlist_screen(header, userinfo)
  return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

  userdb = UserInfoFile.new
  userdb.read

  CommonUI.html_head(header)
  CommonUI.html_menu(userinfo)

  CommonUI.html_adminmenu

  userdb.content.dumphtml

  CommonUI.html_foot
end
