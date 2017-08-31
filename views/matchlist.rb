# -*- encoding: utf-8 -*-

require './file/taikyokufile.rb'
require './views/common_ui.rb'

#
# matchlist画面
#
def matchlist_screen(header, title, name, userinfo)
  tkcdb = TaikyokuChuFile.new
  tkcdb.read

  blogin = (!userinfo.user_id.nil? && userinfo.user_id != '')

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenuLogIn(name, blogin)

  tkcdb.to_html('対局中')

  CommonUI::HTMLfoot()
end
