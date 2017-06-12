#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './file/taikyokufile.rb'
require './views/common_ui.rb'

#
# matchlist画面
#
def matchlist_screen(header, title, name, userinfo)
  tkcdb = TaikyokuChuFile.new
  tkcdb.read

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  tkcdb.dumphtml

  CommonUI::HTMLfoot()
end
