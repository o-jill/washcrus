# -*- encoding: utf-8 -*-

require './file/taikyokufile.rb'
require './views/common_ui.rb'

#
# matchlist画面
#
def matchlist_screen(header, title, userinfo)
  tkcdb = TaikyokuChuFile.new
  tkcdb.read

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(userinfo)

  tkcdb.to_html('対局中')

  CommonUI::HTMLfoot()
end
