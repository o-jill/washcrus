# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'

require './file/taikyokufile.rb'
require './file/userinfofile.rb'
require './game/taikyokudata.rb'
require './game/webapi_sfenreader.rb'
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
  #
  # @param errmsg エラーメッセージ
  def put_err_sreen(errmsg)
    CommonUI.html_head(@header)
    CommonUI.html_menu
    puts errmsg
    CommonUI.html_foot
  end

  def put_navi
    puts <<-NAVI_AREA
      <div id=mypagenav class=mynav>
        <ul>
          <li onclick='clicknav("mypage_stat")'>Stats</li>
          <hr>
          <li onclick='clicknav("mypage_rireki")'>History</li>
          <hr>
          <li onclick='clicknav("mypage_password")'>Password</li>
          <hr>
          <li onclick='clicknav("mypage_email")'>Email</li>
        </ul>
      </div>
      NAVI_AREA
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
  # @param wn 勝数
  # @param ls 負数
  # @param rt 勝率文字列
  def put_seiseki(title, wn, ls, rt)
    puts "<tr><th>#{title}</th><td>#{wn}勝#{ls}敗</td><td>#{rt}</td></tr>"
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
  #
  # @param cap 表のタイトル
  def put_taikyokurireki_tblhead(cap)
    print <<-TAIKYOKURIREKI_TABLE.unindent
      <table align='center' border='3'><caption>#{cap}</caption>
      <tr>
       <th>ID</th><th>先手</th><th>後手</th><th>手番</th><th>最終着手日時</th><th>棋譜</th>
      </tr>
      TAIKYOKURIREKI_TABLE
  end

  # 対局履歴の表の中身の出力
  #
  # @param tklist 対局情報Array
  def put_taikyokulist_tbl(tklist)
    tklist.each do |game|
      gid = game[:id]
      turnstr = CommonUI.turn2str(game[:turn])
      print <<-TKLIST_DAN.unindent
        <tr>
         <td><a href='./index.rb?game/#{gid}'>
          <img src='image/right_fu.png' alt='#{gid}' title='move to this game!'>
          <small>#{gid}</small>
         </a></td>
         <td>#{game[:nameb]}</td><td>#{game[:namew]}</td>
         <td>#{turnstr}</td><td>#{game[:time]}</td>
         <td><a href='./index.rb?dlkifu/#{gid}' target='_blank'>
          <img src='image/dl_kif.png' alt='#{gid}' title='download kif!'>
         </a></td>
        </tr>
        TKLIST_DAN
    end
  end

  # 局面画像生成サイトへのリンクの生成
  #
  # @param gid game id
  # @return 局面画像へのリンク
  def kyokumen_img(gid, turn)
    tkd = TaikyokuData.new
    tkd.log = nil # @log
    tkd.setid(gid)
    tkd.lock do
      tkd.read
    end
    mi = tkd.mi

    sr = WebApiSfenReader.new
    sr.setplayers(mi.playerb.name, mi.playerw.name)
    sr.sfen = mi.sfen
    sr.setlastmovecsa(mi.lastmove)
    sr.setturn(turn)
    sr.settitle(mi.dt_lastmove)

    "<img src='#{sr.genuri}' alt='局面図画像#{gid}'" \
    " title='move to game[#{gid}]!'>"
  end

  # 対局情報の出力
  #
  # @param tklist 対局情報array
  #               [{id:, idb:, idw:, nameb:, namew:, turn:, time:, comment:}]
  def put_taikyokulist_tbl_img(tklist)
    # puts "<TABLE align='center' border='1'><caption>対局中</caption>"
    puts "<style>.taikyokuchu{display:flex; flex-wrap:wrap;}</style>"
    puts "<div align='center'>対局中</div>\n<div class='taikyokuchu'>"
    tklist.each do |game|
      gid = game[:id]
      print <<-GAMEINFO.unindent
        <table border='1'><tr><td><a href='index.rb?game/#{gid}'>
          #{kyokumen_img(gid, game[:turn])}
         </a></td></tr>
        <tr><td>#{game[:comment]}</td></tr></table>
        GAMEINFO
    end
    # puts '</TABLE>'
    puts '</div>'
    # taikyokuchu
  end

  # 対局中の対局の表示
  #
  # @param uid ユーザー情報
  def put_taikyokuchu(uid)
    tkcdb = TaikyokuChuFile.new
    tkcdb.read
    chu = tkcdb.finduid(uid)
    chu.sort! do |aa, bb|
      bb[:time] <=> aa[:time]
    end

    put_taikyokulist_tbl_img(chu)
    # put_taikyokurireki_tblhead('対局中')
    # put_taikyokulist_tbl(chu)
  end

  # 対局履歴の表示
  #
  # @param uid ユーザーID
  def put_taikyokurireki(uid)
    tkdb = TaikyokuFile.new
    tkdb.read
    rireki = tkdb.finduid(uid)
    rireki.sort! do |aa, bb|
      # aa[:time] <=> bb[:time]
      bb[:time] <=> aa[:time]
    end

    puts '<div class=myarticle id=mypage_rireki style="display:none;">'

    put_taikyokurireki_tblhead('対局履歴')

    put_taikyokulist_tbl(rireki)

    puts '</table></div>'
  end

  # 対局成績を引っ張ってくる
  #
  # @param uid ユーザーID
  # @return {swin:先手勝数, slose:先手負数, gwin:後手勝数, glose:後手負数}
  def get_mystats(uid)
    udb = UserInfoFile.new
    udb.read
    udb.content.stats[uid]
  end

  def put_accountsettings
    puts <<-ACCOUNTSETTINGS.unindent
      <div class=myarticle id=mypage_password style="display:none;">
        アカウント設定<BR>
        <hr>
        パスワードの再設定
        <FORM action='index.rb?update_password' method=post name='update_password'>
        <table>
        <tr><td>今の</td><td><input name='sipassword' id='sipassword' type='password' class='inpform' required></td></tr>
        <tr id='trnewpassword'><td>新しいの</td><td><input name='rnewpassword' id='rnewpassword' type='password' class='inpform' required></td></tr>
        <tr id='trnewpassword2'><td>(再)新しいの</td><td><input name='rnewpassword2' id='rnewpassword2' type='password' class='inpform' required></td></tr>
        <tr><td></td><td><input type='submit' class='inpform' onClick='return check_form_mypagepswd();'></td></tr>
        </table>
        </form>
      </div>
      <div class=myarticle id=mypage_email style="display:none;">
        メールアドレスの変更
        <form action='index.rb?update_email' method=post name='update_email'>
        <table>
        <tr id='trnewemail'><td>新しいの</td><td><input name='rnewemail' id='rnewemail' type='email' class='inpform' required></td></tr>
        <tr id='trnewemail2'><td>(再)新しいの</td><td><input name='rnewemail2' id='rnewemail2' type='email' class='inpform' required></td></tr>
        <tr><td></td><td><input type='submit' class='inpform' onClick='return check_form_mypageemail();'></td></tr>
        </table>
        </form>
      </div>
      ACCOUNTSETTINGS
  end

  def put_script
    puts <<-SCRIPT.unindent
      <script>
      var target = false;
      target = document.getElementById('mypage_stat');
      function clicknav(strid) {
        if (target) {
          target.style.display = 'none';
        }
        target = document.getElementById(strid);
        target.style.display = 'block';
      }
      </script>
      SCRIPT
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  def show(userinfo)
    return put_err_sreen("your log-in information is wrong ...\n") \
      if userinfo.invalid?

    uid = userinfo.user_id
    wl = get_mystats(uid)

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    puts '<script src="js/signup.js"></script>'
    puts '<script src="js/mypage.js"></script>'
    puts '<div class=mypage_main>'

    put_navi

    puts '<div class=myarticle id=mypage_stat>'
    put_stats(wl)
    puts '<HR>'
    put_taikyokuchu(uid)
    puts '</div>'

    put_taikyokurireki(uid)

    put_accountsettings

    puts '</div>'

    put_script

    CommonUI.html_foot
  end
end
