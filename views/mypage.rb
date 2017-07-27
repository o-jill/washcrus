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

def put_taikyokuchu(uid)
  tkcdb = TaikyokuChuFile.new
  tkcdb.read
  chu = tkcdb.finduid(uid)

  print <<-TAIKYOKUCHU_TABLE.unindent
    <table align='center' border='3'><caption>対局中</caption>
    <tr>
     <th>ID</th><th>先手</th><th>後手</th><th>最終着手日時</th><th>棋譜</th>
    </tr>
    TAIKYOKUCHU_TABLE

  chu.each do |game|
    gid = game[:id]
    print <<-CHU_DAN.unindent
      <tr>
       <td><a href='./game.rb?#{gid}' target='_blank'>#{gid}</a></td>
       <td>#{game[:nameb]}</td><td>#{game[:namew]}</td><td>#{game[:time]}</td>
       <td><a href='./dlkifu.rb?#{gid}' target='_blank'>download</a></td>
      </tr>
      CHU_DAN
  end

  print '</table>'
end

def put_taikyokurireki(uid)
  tkdb = TaikyokuFile.new
  tkdb.read
  rireki = tkdb.finduid(uid)
  rireki.sort! do |a, b|
    # a[:time] <=> b[:time]
    b[:time] <=> a[:time]
  end

  print <<-TAIKYOKURIREKI_TABLE.unindent
    <table align='center' border='3'><caption>対局履歴</caption>
    <tr>
     <th>ID</th><th>先手</th><th>後手</th><th>最終着手日時</th><th>棋譜</th>
    </tr>
    TAIKYOKURIREKI_TABLE

  rireki.each do |game|
    gid = game[:id]
    print <<-RIREKI_DAN.unindent
      <tr>
       <td><a href='./game.rb?#{gid}' target='_blank'>#{gid}</a></td>
       <td>#{game[:nameb]}</td><td>#{game[:namew]}</td><td>#{game[:time]}</td>
       <td><a href='./dlkifu.rb?#{gid}' target='_blank'>download</a></td>
      </tr>
      RIREKI_DAN
  end

  print '</table>'
end

#
# mypage画面
#
def mypage_screen(header, title, name, userinfo)
  errmsg = ''
  errmsg = "your log-in information is wrong ...\n" \
      if userinfo.nil? || userinfo.invalid?

  return put_err_sreen(header, title, name, errmsg) unless errmsg.empty?

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenuLogIn(name)

  put_taikyokuchu(userinfo.user_id)
  print '<HR>'
  put_taikyokurireki(userinfo.user_id)

  CommonUI::HTMLfoot()
end
