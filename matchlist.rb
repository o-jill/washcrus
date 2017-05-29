#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './common_ui.rb'
require './taikyokufile.rb'

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
