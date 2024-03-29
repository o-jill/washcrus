# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'unindent'

require './file/taikyokufile.rb'
require './file/userchatfile.rb'
require './file/userinfofile.rb'
require './game/taikyokudata.rb'
require './game/webapi_sfenreader.rb'
require './game/winsloses.rb'
require './util/settings.rb'
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

  # ナビゲーションメニューの出力
  def put_navi
    puts <<-NAVI_AREA.unindent
      <div><div id='mypagenav' class='mynav'>
        <div id='navbtn_stats'><img src='./image/right_fu.png' title='Stats' alt='Stats'></div>
        <div id='navbtn_chat'><img src='./image/balloon3216.png' title='Chat' alt='Chat'></div>
        <div id='navbtn_rireki'><img src='./image/history3216.png' title='History' alt='History'></div>
        <div id='navbtn_pswd'><img src='./image/pwd3216.png' title='Password' alt='Password'></div>
        <div id='navbtn_email'><img src='./image/email3216.png' title='Email' alt='Email'></div>
        <div id='navbtn_unsubscribe'><img src='./image/unsubscribe3216.png' title='Unsubscribe' alt='Unsubscribe'></div>
      </div><hr></div>
    NAVI_AREA
  end

  # 対局履歴の表のヘッダの出力
  #
  # @param cap 表のタイトル
  def put_taikyokurireki_tblhead(cap)
    print <<-TAIKYOKURIREKI_TABLE.unindent
      <table align='center' border='3'><caption>#{cap}</caption>
      <tr>
       <th>ID</th><th>先手</th><th>後手</th><th>手番</th><th>最終着手日時</th><th>棋譜</th><th>検討</th>
      </tr>
    TAIKYOKURIREKI_TABLE
  end

  # 検討用リンク生成
  #
  # @param gid 対局ID
  # @param status 対局の手番
  #
  # return 終局後:検討用リンク, 対局中:'ダメ'
  def put_kentourl(gid, status)
    return 'ダメ' if %w[b w].include?(status)

    stg = Settings.instance
    baseurl = stg.value['base_url']
    kentourl = stg.value['kento_url'] + baseurl
    "<a href='#{kentourl}kifuapi.rb%3f#{gid}.kif' target='_blank'>検討</a>"
  end

  # ある対局の対局者名と手番、最終着手日時のセルのタグ
  #
  # @param turn 手番
  #
  # @return 先手後手の名前と手番、最終着手日時のセルのタグ
  def print_gamedetail(turn, nameb: 'b', namew: 'w', time: '0 0', **_other)
    turnstr = CommonUI.turn2str(turn)
    "<td>#{nameb}</td><td>#{namew}</td>" \
    "<td>#{turnstr}</td><td>#{time}</td>"
  end

  # 進行中の対局の局面付き対局へのリンクの出力
  def print_game(id: 'gid', turn: 't', **others)
    print <<-TKLIST_DAN.unindent
      <tr>
       <td><a href='./index.rb?game/#{id}'>
        <img src='image/right_fu.png' alt='#{id}' title='move to this game!'>
        <small>#{id}</small>
       </a></td>
       #{print_gamedetail(turn, **others)}
       <td><a href='./index.rb?dlkifu/#{id}' target='_blank'>
        <img src='image/dl_kif.png' alt='#{id}' title='download kif!'>
       </a></td>
       <td>#{put_kentourl(id, turn)}</td>
      </tr>
    TKLIST_DAN
  end

  # 対局履歴の表の中身の出力
  #
  # @param tklist 対局情報Array
  def put_taikyokulist_tbl(tklist)
    tklist.each do |game|
      print_game(**game)
    end
  end

  # WebApiSfenReaderオブジェクトの生成と値のセット
  #
  # @param mif  対局情報
  # @param turn 手番
  #
  # @return WebApiSfenReaderオブジェクト
  def gen_sfen_reader(mif, turn)
    sr = WebApiSfenReader.new
    sr.setmatchinfo(mif)
    sr.setturn(turn)
    sr.settitle(mif.dt_lastmove)
    sr
  end

  # 局面画像生成サイトへのリンクの生成
  #
  # @param gid game id
  # @return 局面画像へのリンク
  def kyokumen_img(gid, turn)
    tkd = TaikyokuData.new
    tkd.log = nil # @log
    tkd.setid(gid)
    tkd.lockex do
      tkd.read
    end
    mif = tkd.mif

    sr = gen_sfen_reader(mif, turn)

    "<img src='#{sr.genuri}' alt='局面図画像#{gid}'" \
    " title='move to game[#{gid}]!'>"
  end

  # 対局情報の出力
  #
  # @param tklist 対局情報array
  #               [{id:, idb:, idw:, nameb:, namew:, turn:, time:, comment:}]
  def put_taikyokulist_tbl_img(tklist)
    # puts "<TABLE align='center' border='1'><caption>対局中</caption>"
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

  # 成績表の計算と出力
  # 対局中の対局の表示
  #
  # @param winlose WinsLosesオブジェクト
  # @param user ユーザー情報
  def put_mypage_stats(winlose, user)
    puts '<div class="myarticle" id="mypage_stats">'
    winlose.put(user.user_name)
    puts '<HR>'
    put_taikyokuchu(user.user_id)
    puts '</div>'
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
    WinsLoses.new(udb.content.stats[uid])
  end

  # チャットのやり取りの表示
  def put_chat(uid, unm)
    chat = UserChatFile.new(uid)
    chat.read
    puts '<div class=myarticle id=mypage_chat style="display:none;">' \
      '<a id="cvtop"></a><div align="center">' \
      "<button onclick='scrollToNew()'>new messages</button> " \
      "<button onclick='scrollToBottom()'>↓ latest</button>" \
      '</div><hr><div class="chatarea">'
    puts chat.empty? ? 'chat will be here.' : chat.msg4mypage(unm)
    puts '</div><hr id="cvbottom"><div align=center>' \
      "<button onclick='scrollToTop()'>↑ top</button></div></div>"
  end

  # アカウント設定、メールアドレス設定、退会設定の出力
  def put_accountsettings
    puts <<-ACCOUNTSETTINGS.unindent
      <div class=myarticle id=mypage_pswd style="display:none;">
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
      <div class=myarticle id=mypage_unsubscribe style="display:none;">
        <span class='unsubscribe'>[注意]退会する</span>
        <form action='index.rb?unsubscribe' method=post name='unsubscribe'>
        <table><tr><td>
        <input type='email' name='unsubscribe' id='unsubscribe' class='inpform' placeholder='e-mail address'>
        </td></tr><tr><td>
        <input type='submit' class='unsubscribe' onClick='return confirm_unsubscribe();'>
        </td></tr></table>
        </form>
      </div>
    ACCOUNTSETTINGS
  end

  # ヘッダとフッタ以外の表示
  #
  # @param userinfo ユーザー情報
  def put(userinfo)
    puts "<script src='js/signup.js'></script>\n" \
         "<script src='js/mypage.js?v002'></script>\n" \
         "<div class='mypage_main'>\n"

    put_navi

    uid = userinfo.user_id
    wl = get_mystats(uid)

    put_mypage_stats(wl, userinfo)

    put_taikyokurireki(uid)
    put_chat(uid, userinfo.user_name)
    put_accountsettings

    puts '</div>'
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  def show(userinfo)
    return put_err_sreen("your log-in information is wrong ...\n") \
      if userinfo.invalid?

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    put(userinfo)

    CommonUI.html_foot
  end
end
