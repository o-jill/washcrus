# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'erb'
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
    @cmt = 'blank'
    @errmsg = ''

    @log = Logger.new(PathList::GENNEWGAMELOG)
  end

  # @!attribute [r] email1
  #   @return 対局者1のメールアドレス
  # @!attribute [r] email2
  #   @return 対局者2のメールアドレス
  # @!attribute [r] name1
  #   @return 対局者名1
  # @!attribute [r] name2
  #   @return 対局者名2
  # @!attribute [r] cmt
  #   @return コメント
  # @!attribute [r] td
  #   @return 対局情報
  # @!attribute [r] log
  #   @return logging
  attr_reader :email1, :email2, :name1, :name2, :cmt, :td, :log

  # データの存在チェック
  #
  # @param params パラメータハッシュオブジェクト
  # @return データが１つでも欠けてたらfalse
  def check_datalost_gengame(params)
    params['rname'] && params['remail'] \
      && params['rname2'] && params['remail2'] && params['cmt']
  end

  # 歩とと金のどっちが多いかを返す
  #
  # @param furigoma 振りごま結果文字列。F or T
  # @return 歩が３枚以上ならtrue
  def furifusen(furigoma)
    furigoma.count('F') >= 3
  end

  # ユーザー名とメアドのチェック
  #
  # @param udb ユーザーDB
  # @param name 名前
  # @param email メールアドレス
  # @param errmsg エラー時に付加するエラーメッセージ
  #
  # @return ユーザーデータ
  def check_playersdata(udb, name, email, errmsg)
    userdata = udb.findname(name) # [id, name, pw, email]
    # @errmsg += errmsg unless userdata && email == userdata[:email]
    if userdata.nil?
      @errmsg += errmsg
    elsif email != userdata[:email]
      @errmsg += errmsg
    end
    userdata
  end

  # プレイヤー情報の取得
  #
  # @return { userdataa:, userdatab: }
  def check_players
    userdb = UserInfoFile.new
    userdb.read
    udb = userdb.content

    userdataa = check_playersdata(
      udb, name1, email1,
      "name or e-mail address in player 1 is wrong ...<BR>\n"
    )

    userdatab = check_playersdata(
      udb, name2, email2,
      "name or e-mail address in player 2 is wrong ...<BR>\n"
    )

    { userdataa: userdataa, userdatab: userdatab }
  end

  # paramsから値を取り出す。
  # keyが無いときはdefaultを使う。
  def safer_params(params, key, default)
    val = params[key] || default
    val[0]
  end

  # 名前とメールアドレスの読み取り
  #
  # @param params パラメータハッシュオブジェクト
  def read_nameemail(params)
    # プレイヤー1の名前
    @name1 = safer_params(params, 'rname', [])
    # プレイヤー1のアドレス
    @email1 = safer_params(params, 'remail', [])
    # プレイヤー2の名前
    @name2 = safer_params(params, 'rname2', [])
    # プレイヤー2のアドレス
    @email2 = safer_params(params, 'remail2', [])
    @cmt = safer_params(params, 'cmt', ['blank'])
  end

  # プレイヤー情報の確認
  #
  # @param params パラメータハッシュオブジェクト
  # @return { userdataa:, userdatab: }
  def check_newgame(params)
    return @errmsg += 'data lost ...<BR>' unless check_datalost_gengame(params)

    read_nameemail(params)

    check_players
  end

  # 新規対局のメール文面の生成
  #
  # @param userb 先手の名前
  # @param userw 後手の名前
  # @param gameid game-id
  # @return 文面
  def mail_msg_newgame(userb, userw, gameid)
    baseurl = @stg.value['base_url']

    ERB.new(
      File.read('./mail/newgame.erb', encoding: 'utf-8')
    ).result(binding)
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
    plyb = td.playerb
    plyw = td.playerw
    subject = "a game is ready!! (#{plyb} vs #{plyw})"
    msg = mail_msg_newgame(plyb, plyw, td.gid)

    mailmgr = MailManager.new
    mailmgr.send_mail_withfooter(td.emailb, subject, msg)
    mailmgr.send_mail_withfooter(td.emailw, subject, msg)
  end

  # 対局者のセット
  #
  # @param userdta 対局者A
  # @param userdtb 対局者B
  # @param furigomastr 振り駒の結果
  def config_players(userdta, userdtb, furigomastr)
    # @log.debug("td.setplayerb,#{userdta}")
    td.setplayerb(userdta[:id], userdta[:name], userdta[:email])

    # @log.debug("td.setplayerw,#{userdtb}")
    td.setplayerw(userdtb[:id], userdtb[:name], userdtb[:email])

    # @log.debug("furifusen(#{params['furigoma'][0].count('F')})")
    td.switchplayers unless furifusen(furigomastr)
  end

  # 対局情報の設定
  #
  # @param userdta 対局者A情報
  # @param userdtb 対局者B情報
  # @param userinfo ユーザー情報
  # @param furigomastr 振りごま結果文字列。[FT]{5}
  def config_taikyoku(userdta, userdtb, userinfo, furigomastr)
    config_players(userdta, userdtb, furigomastr)

    # @log.debug('td.creator')
    td.creator = "#{userinfo.user_name}(#{userinfo.user_id})"

    # @log.debug('td.generate(@cmt)')
    td.generate(cmt)
  end

  # 対局生成
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  # @return 生成できたらtrue
  def generate(userinfo, params)
    ret = check_newgame(params)

    # @log.debug('check_newgame(params)')
    @errmsg += "your log-in information is wrong ...\n" if userinfo.invalid?

    return false unless @errmsg.empty?

    # @log.debug('put_err_sreen')

    @td = TaikyokuData.new
    # @log.debug("TaikyokuData.new:#{td}")
    td.log = log
    # @log.debug(
    # "config_taikyoku(#{ret[:userdataa]}, #{ret[:userdatab]}, #{userinfo}," \
    #                 "#{params['furigoma'][0]})")
    config_taikyoku(ret[:userdataa], ret[:userdatab], userinfo,
                    params['furigoma'][0])

    # send mail to the players
    send_mail

    true
  end

  # メッセージの出力
  def put_msg
    td.dumptableex

    puts <<-GENMSG.unindent
      a new game was generated!<BR>
      <a href='index.rb?game/#{td.gid}'><big>start playing &gt;&gt;</big></a><BR>

      mails were sent to both players.
    GENMSG
  end

  # エラーをログに出力
  #
  # @param err エラー情報
  def err2log(err)
    @log.warn("class=[#{err.class}] message=[#{err.message}] in gennewgame")
    @log.warn("callstack:#{err.backtrace}")
  end

  # htmlの出力
  #
  # @param userinfo ユーザー情報
  def put_html(userinfo)
    # @log.debug('CommonUI.html_head(header)')
    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu if userinfo.admin

    put_msg

    CommonUI.html_foot
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return put_err_sreen(userinfo) unless generate(userinfo, params)

    put_html(userinfo)
  rescue ScriptError => e
    err2log(e)
  rescue SecurityError => e
    err2log(e)
  rescue StandardError => e
    err2log(e)
  end
end
