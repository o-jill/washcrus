# -*- encoding: utf-8 -*-

require 'logger'
require 'unindent'

require './file/chatfile.rb'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './file/pathlist.rb'
require './file/userinfofile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'
require './util/mailmgr.rb'
require './util/settings.rb'
require './views/common_ui.rb'

#
# 対局作成確認
#
class GenNewGameScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
    @stg = Settings.instance

    @errmsg = ''

    @log = Logger.new(PathList::GENNEWGAMELOG)
  end

  # データの存在チェック
  #
  # @param params パラメータハッシュオブジェクト
  # @return データが１つでも欠けてたらtrue
  def check_datalost_gengame(params)
    params['rname'].nil? || params['remail'].nil? \
        || params['rname2'].nil? || params['remail2'].nil?
  end

  # 歩とと金のどっちが多いかを返す
  #
  # @param furigoma 振りごま結果文字列。F or T
  # @return 歩が３枚以上ならtrue
  def furifusen(furigoma)
    furigoma.count('F') >= 3
  end

  # プレイヤー情報の取得
  #
  # @param name1  プレイヤー1の名前
  # @param email1 プレイヤー1のアドレス
  # @param name2  プレイヤー2の名前
  # @param email2 プレイヤー2のアドレス
  # @return { userdata1:, userdata2: }
  def check_players(name1, email1, name2, email2)
    userdb = UserInfoFile.new
    userdb.read

    userdata1 = userdb.findname(name1) # [id, name, pw, email]
    if userdata1.nil? || email1 != userdata1[3]
      @errmsg += "name or e-mail address in player 1 is wrong ...<BR>\n"
    end

    userdata2 = userdb.findname(name2) # [id, name, pw, email]
    if userdata2.nil? || email2 != userdata2[3]
      @errmsg += "name or e-mail address in player 2 is wrong ...<BR>\n"
    end

    { userdata1: userdata1, userdata2: userdata2 }
  end

  # プレイヤー情報の確認
  #
  # @param params パラメータハッシュオブジェクト
  # @return { userdata1:, userdata2: }
  def check_newgame(params)
    return @errmsg += 'data lost ...<BR>' if check_datalost_gengame(params)

    name1 = params['rname'][0]
    email1 = params['remail'][0]
    name2 = params['rname2'][0]
    email2 = params['remail2'][0]

    check_players(name1, email1, name2, email2)
  end

  # 新規対局のメール文面の生成
  #
  # @param user1 名前1
  # @param user2 名前2
  # @param gameid game-id
  # @return 文面
  def mail_msg_newgame(user1, user2, gameid)
    baseurl = @stg.value['base_url']
    msg = <<-MAIL_MSG.unindent
      Dear #{user1} and #{user2}

      a new game is ready for you.
      please visit a URL bellow to play.
      #{baseurl}washcrus.rb?game/#{gameid}

      MAIL_MSG
    msg += MailManager.footer
    msg
  end

  # エラー画面の出力
  #
  # @param userinfo ユーザー情報
  def put_err_sreen(userinfo)
    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    puts @errmsg
    CommonUI.html_foot
  end

  # 新規対局メールの送信
  def send_mail
    subject = "a game is ready!! (#{@td.player1} vs #{@td.player2})"
    msg = mail_msg_newgame(@td.player1, @td.player2, @td.gid)

    mailmgr = MailManager.new
    mailmgr.send_mail(@td.email1, subject, msg)
    mailmgr.send_mail(@td.email2, subject, msg)
  end

  # 対局情報の設定
  #
  # @param userdata1 対局者１情報
  # @param userdata2 対局者2情報
  # @param userinfo ユーザー情報
  # @param furigomastr 振りごま結果文字列。[FT]{5}
  def config_taikyoku(userdata1, userdata2, userinfo, furigomastr)
    # @log.debug('td.setplayer1')
    @td.setplayer1(userdata1[0], userdata1[1], userdata1[3])

    # @log.debug('td.setplayer2')
    @td.setplayer2(userdata2[0], userdata2[1], userdata2[3])

    # @log.debug("furifusen(#{params['furigoma'][0].count('F')})")
    @td.switchplayers unless furifusen(furigomastr)

    # @log.debug('td.creator')
    @td.creator = "#{userinfo.user_name}(#{userinfo.user_id})"

    # @log.debug('td.generate')
    @td.generate
  end

  # 対局生成
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  # @return 生成できたらtrue
  def generate(userinfo, params)
    ret = check_newgame(params)

    # @log.debug('check_newgame(params)')
    @errmsg += "your log-in information is wrong ...\n" \
        if userinfo.nil? || userinfo.invalid?

    return false unless @errmsg.length.zero?

    # @log.debug('put_err_sreen')

    # @log.debug('TaikyokuData.new')
    @td = TaikyokuData.new
    @td.log = @log

    config_taikyoku(ret[:userdata1], ret[:userdata2], userinfo,
                    params['furigoma'][0])

    # send mail to the players
    send_mail

    true
  end

  # メッセージの出力
  def put_msg
    @td.dumptable

    puts <<-GENMSG.unindent
      a new game was generated!<BR>
      <a href='washcrus.rb?game/#{@td.gid}'><big>start playing &gt;&gt;</big></a><BR>

      mails were sent to both players.
      GENMSG
  end

  # エラーをログに出力
  #
  # @param e エラー情報
  def err2log(e)
    @log.warn("class=[#{e.class}] message=[#{e.message}] in gennewgame")
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return put_err_sreen(userinfo) unless generate(userinfo, params)

    # @log.debug('CommonUI.html_head(header)')
    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    put_msg

    CommonUI.html_foot
  rescue ScriptError => e
    err2log(e)
  rescue SecurityError => e
    err2log(e)
  rescue => e
    err2log(e)
  end
end
