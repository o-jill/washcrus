# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'

require './file/taikyokufile.rb'
require './file/userinfofile.rb'
require './views/common_ui.rb'

#
# mypage画面
#
class MyPageScreen
  def initialize(header, title, name)
    @header = header
    @title = title
    @name = name
  end

  def put_err_sreen(errmsg)
    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(@name)
    puts errmsg
    CommonUI::HTMLfoot()
  end

  def calctotal(wl)
    ttl = [wl[:swin] + wl[:gwin], wl[:slose] + wl[:glose], 0]
    ttl[2] = ttl[0] + ttl[1]
    ttl
  end

  def calcratestr(total, win)
    format('%.3f', total.zero? ? 0 : win / total.to_f)
  end

  def put_seiseki(title, w, l, r)
    puts "<tr><th>#{title}</th><td>#{w}勝#{l}敗</td><td>#{r}</td></tr>"
  end

  def put_stats(wl)
    wl[:stotal] = wl[:swin] + wl[:slose]
    wl[:gtotal] = wl[:gwin] + wl[:glose]

    ttl = calctotal(wl)

    srate = calcratestr(wl[:stotal], wl[:swin])
    grate = calcratestr(wl[:gtotal], wl[:gwin])
    trate = calcratestr(ttl[2], ttl[0])

    puts "<table align='center' border='3'><caption>戦績</caption>"
    put_seiseki('総合成績', ttl[0], ttl[1], trate)
    put_seiseki('先手成績', wl[:swin], wl[:slose], srate)
    put_seiseki('後手成績', wl[:gwin], wl[:glose], grate)
    puts '</table>'
  end

  def put_taikyokurireki_tblhead(cap)
    print <<-TAIKYOKURIREKI_TABLE.unindent
      <table align='center' border='3'><caption>#{cap}</caption>
      <tr>
       <th>ID</th><th>先手</th><th>後手</th><th>最終着手日時</th><th>棋譜</th>
      </tr>
      TAIKYOKURIREKI_TABLE
  end

  def put_taikyokulist_tbl(tklist)
    tklist.each do |game|
      gid = game[:id]
      print <<-TKLIST_DAN.unindent
        <tr>
         <td><a href='./washcrus.rb?game/#{gid}'>#{gid}</a></td>
         <td>#{game[:nameb]}</td><td>#{game[:namew]}</td><td>#{game[:time]}</td>
         <td><a href='./washcrus.rb?dlkifu/#{gid}' target='_blank'>download</a></td>
        </tr>
        TKLIST_DAN
    end
  end

  def put_taikyokuchu(uid)
    tkcdb = TaikyokuChuFile.new
    tkcdb.read
    chu = tkcdb.finduid(uid)
    chu.sort! do |a, b|
      b[:time] <=> a[:time]
    end

    put_taikyokurireki_tblhead('対局中')

    put_taikyokulist_tbl(chu)

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

    put_taikyokurireki_tblhead('対局履歴')

    put_taikyokulist_tbl(rireki)

    print '</table>'
  end

  def show(userinfo)
    return put_err_sreen("your log-in information is wrong ...\n") \
      if userinfo.nil? || userinfo.invalid?

    udb = UserInfoFile.new
    udb.read

    uid = userinfo.user_id
    wl = udb.stats[uid]

    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenuLogIn(@name)

    put_stats(wl)
    print '<HR>'
    put_taikyokuchu(uid)
    print '<HR>'
    put_taikyokurireki(uid)

    CommonUI::HTMLfoot()
  end
end
