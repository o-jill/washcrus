# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'

require './file/taikyokufile.rb'
require './views/common_ui.rb'

def put_err_sreen(header, title, name, errmsg)
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)
  puts errmsg
  CommonUI::HTMLfoot()
end

#
# mypage画面
#
def mypage_screen(header, title, name, userinfo)
  errmsg = ''
  errmsg = "your log-in information is wrong ...\n" \
      if userinfo.nil? || userinfo.invalid?

  return put_err_sreen(header, title, name, errmsg) unless errmsg.empty?

  uid = userinfo.user_id

  tkcdb = TaikyokuChuFile.new
  tkcdb.read
  chu = tkcdb.finduid(uid)

  tkdb = TaikyokuFile.new
  tkdb.read
  rireki = tkdb.finduid(uid)
  rireki.sort! do |a, b|
    # a[:time] <=> b[:time]
    b[:time] <=> a[:time]
  end

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenuLogIn(name)

  print "<table align='center' border='3'><caption>対局中</caption>"
  print "<tr><th>ID</th><th>先手</th><th>後手</th><th>最終着手日時</th><th>棋譜</th></tr>"

  chu.each do |game|
    print <<-CHU_DAN.unindent
      <tr>
       <td><a href='./game.rb?#{game[:id]}' target='_blank'>#{game[:id]}</a></td>
       <td>#{game[:nameb]}</td><td>#{game[:namew]}</td><td>#{game[:time]}</td>
       <td><a href='./dlkifu.rb?#{game[:id]}' target='_blank'>download</a></td>
      </tr>
      CHU_DAN
  end

  print "</table><HR>"

  print "<table align='center' border='3'><caption>対局履歴</caption>"
  print "<tr><th>ID</th><th>先手</th><th>後手</th><th>最終着手日時</th><th>棋譜</th></tr>"

  rireki.each do |game|
    print <<-RIREKI_DAN.unindent
      <tr>
       <td><a href='./game.rb?#{game[:id]}' target='_blank'>#{game[:id]}</a></td>
       <td>#{game[:nameb]}</td><td>#{game[:namew]}</td><td>#{game[:time]}</td>
       <td><a href='./dlkifu.rb?#{game[:id]}' target='_blank'>download</a></td>
      </tr>
      RIREKI_DAN
  end

  print "</table>"

  CommonUI::HTMLfoot()
end
