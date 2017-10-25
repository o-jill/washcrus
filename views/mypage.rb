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
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # エラー画面の表示
  def put_err_sreen(errmsg)
    CommonUI::HTMLHead(@header)
    CommonUI::HTMLmenu()
    puts errmsg
    CommonUI::HTMLfoot()
  end

  # 合計勝ち負けの計算
  #
  # @param wl {swin:先手勝数, slose:先手負数, gwin:後手勝数, glose:後手負数}
  # @return 合計勝ち負け
  def calctotal(wl)
    ttl = [wl[:swin] + wl[:gwin], wl[:slose] + wl[:glose], 0]
    ttl[2] = ttl[0] + ttl[1]
    ttl
  end

  # 先手と後手の総対局数を計算
  #
  # @param wl {swin:先手勝数, slose:先手負数, gwin:後手勝数, glose:後手負数}
  # @return wlに:stotal, :gtotalが追加された計算結果。
  def calc_sgtotal(wl)
    wl[:stotal] = wl[:swin] + wl[:slose]
    wl[:gtotal] = wl[:gwin] + wl[:glose]
    wl
  end

  # 勝率の文字列を生成
  #
  # @param total 局数
  # @param win   勝数
  # @return 勝率の文字列 '0.000'
  def calcratestr(total, win)
    format('%.3f', total.zero? ? 0 : win / total.to_f)
  end

  # 勝ち負け一段分の出力
  #
  # @param title 項目名
  # @param w 勝数
  # @param l 負数
  # @param r 勝率文字列
  def put_seiseki(title, w, l, r)
    puts "<tr><th>#{title}</th><td>#{w}勝#{l}敗</td><td>#{r}</td></tr>"
  end

  # 成績表の出力
  #
  # @param ttl   総合成績[勝数, 負数, 対局数]
  # @param wl    先後成績{swin:, slose:, stotal, gwin:, glose:, gtotal:}
  # @param trate 総合勝率
  # @param srate 先手勝率
  # @param grate 後手勝率
  def put_myseiseki(ttl, wl, trate, srate, grate)
    puts "<table align='center' border='3'><caption>戦績</caption>"
    put_seiseki('総合成績', ttl[0], ttl[1], trate)
    put_seiseki('先手成績', wl[:swin], wl[:slose], srate)
    put_seiseki('後手成績', wl[:gwin], wl[:glose], grate)
    puts '</table>'
  end

  # 成績表の計算と出力
  #
  # @param wl {swin:先手勝数, slose:先手負数, gwin:後手勝数, glose:後手負数}
  def put_stats(wl)
    wl = calc_sgtotal(wl)

    ttl = calctotal(wl)

    srate = calcratestr(wl[:stotal], wl[:swin])
    grate = calcratestr(wl[:gtotal], wl[:gwin])
    trate = calcratestr(ttl[2], ttl[0])

    put_myseiseki(ttl, wl, trate, srate, grate)
  end

  # 対局履歴の表のヘッダの出力
  def put_taikyokurireki_tblhead(cap)
    print <<-TAIKYOKURIREKI_TABLE.unindent
      <table align='center' border='3'><caption>#{cap}</caption>
      <tr>
       <th>ID</th><th>先手</th><th>後手</th><th>最終着手日時</th><th>棋譜</th>
      </tr>
      TAIKYOKURIREKI_TABLE
  end

  # 対局履歴の表の中身の出力
  #
  # @param tklist 対局情報Array
  def put_taikyokulist_tbl(tklist)
    tklist.each do |game|
      gid = game[:id]
      print <<-TKLIST_DAN.unindent
        <tr>
         <td><a href='./washcrus.rb?game/#{gid}'>
          <img src='image/right_fu.png' alt='#{gid}' title='move to this game!'>
          <small>#{gid}</small>
         </a></td>
         <td>#{game[:nameb]}</td><td>#{game[:namew]}</td><td>#{game[:time]}</td>
         <td><a href='./washcrus.rb?dlkifu/#{gid}' target='_blank'>
          <img src='image/dl_kif.png' alt='#{gid}' title='download kif!'>
         </a></td>
        </tr>
        TKLIST_DAN
    end
  end

  # 対局中の対局の表示
  #
  # @param uid ユーザー情報
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

  # 対局履歴の表示
  #
  # @param uid ユーザーID
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

  # 対局成績を引っ張ってくる
  #
  # @param uid ユーザーID
  # @return {swin:先手勝数, slose:先手負数, gwin:後手勝数, glose:後手負数}
  def get_mystats(uid)
    udb = UserInfoFile.new
    udb.read
    udb.stats[uid]
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  def show(userinfo)
    return put_err_sreen("your log-in information is wrong ...\n") \
      if userinfo.nil? || userinfo.invalid?

    uid = userinfo.user_id
    wl = get_mystats(uid)

    CommonUI::HTMLHead(@header)
    CommonUI::HTMLmenu(userinfo)

    put_stats(wl)
    print '<HR>'
    put_taikyokuchu(uid)
    print '<HR>'
    put_taikyokurireki(uid)

    CommonUI::HTMLfoot()
  end
end
