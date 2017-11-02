# -*- encoding: utf-8 -*-

require './file/taikyokufile.rb'
require './views/common_ui.rb'

#
# matchlist画面
#
def matchlist_screen(header, userinfo)
  tkcdb = TaikyokuChuFile.new
  tkcdb.read

  CommonUI.html_head(header)
  CommonUI.html_menu(userinfo)

  tkcdb.to_html('対局中')

  CommonUI.html_foot
end
