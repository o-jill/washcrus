# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'

require './file/taikyokufile.rb'
require './file/userinfofile.rb'
require './views/common_ui.rb'

def put_err_sreen(header, title, name, errmsg)
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)
  puts errmsg
  CommonUI::HTMLfoot()
end

def put_stats(uid)
  udb = UserInfoFile.new
  udb.read

  wl = udb.stats[uid]
  wl[:stotal] = wl[:swin] + wl[:slose]
  wl[:gtotal] = wl[:gwin] + wl[:glose]

  ttl = [wl[:swin] + wl[:gwin], wl[:gwin] + wl[:glose], 0]
  ttl[2] = ttl[0] + ttl[1]

  srate = format('%.3f', wl[:stotal].zero? ? 0 : wl[:swin] / wl[:stotal].to_f)
  grate = format('%.3f', wl[:gtotal].zero? ? 0 : wl[:gwin] / wl[:gtotal].to_f)
  trate = format('%.3f', ttl[2].zero? ? 0 : ttl[0] / ttl[2].to_f)

  print <<-STATS.unindent
    <table align='center' border='3'><caption>対局中</caption>
    <tr>
     <th>総合成績</th><td>#{ttl[0]}勝#{ttl[1]}敗</td><td>#{trate}</td>
    </tr>
    <tr>
     <th>先手成績</th><td>#{wl[:swin]}勝#{wl[:slose]}敗</td><td>#{srate}</td>
    </tr>
    <tr>
     <th>後手成績</th><td>#{wl[:gwin]}勝#{wl[:glose]}敗</td><td>#{grate}</td>
    </tr>
    </table>
    STATS
end

def put_taikyokuchu(uid)
  tkcdb = TaikyokuChuFile.new
  tkcdb.read
  chu = tkcdb.finduid(uid)
  chu.sort! do |a, b|
    b[:time] <=> a[:time]
  end

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

  put_stats(userinfo.user_id)
  print '<HR>'
  put_taikyokuchu(userinfo.user_id)
  print '<HR>'
  put_taikyokurireki(userinfo.user_id)

  CommonUI::HTMLfoot()
end
