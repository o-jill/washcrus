# -*- encoding: utf-8 -*-

require 'logger'
require 'unindent'

require './file/chatfile.rb'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './file/userinfofile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'
require './util/mailmgr.rb'
require './util/settings.rb'
require './views/common_ui.rb'

#
# 対局作成確認
#
class GenNewGame2Screen
  # 初期化
  #
  # @param header htmlヘッダ
  # @param title  ページタイトル
  # @param name   ページヘッダタイトル
  def initialize(header, title, name)
    @header = header
    @title = title
    @name = name
    @stg = Settings.instance

    @errmsg = ''

    @log = Logger.new('./log/newgamegenlog.txt')
  end

  def check_datalost_gengame(params)
    params['rid'].nil? || params['rid2'].nil? || params['furigoma'].nil? \
      || params['teai'].nil?
  end

  def furifusen(furigoma)
    furigoma.count('F') >= 3
  end

  def check_players(id1, id2)
    userdb = UserInfoFile.new
    userdb.read

    userdata1 = userdb.findid(id1) # [name, pw, email]
    if userdata1.nil?
      @errmsg += "player1's id is wrong ...<BR>\n"
    else
      userdata1.unshift(id1) # [id, name, pw, email]
    end

    userdata2 = userdb.findid(id2) # [name, pw, email]
    if userdata2.nil?
      @errmsg += "player2's id is wrong ...<BR>\n"
    else
      userdata2.unshift(id2) # [id, name, pw, email]
    end

    { userdata1: userdata1, userdata2: userdata2 }
  end

  def check_newgame(params)
    return @errmsg += 'data lost ...<BR>' if check_datalost_gengame(params)

    id1 = params['rid'][0]
    id2 = params['rid2'][0]

    check_players(id1, id2)
  end

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

  def put_err_sreen(userinfo)
    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(@name, userinfo)
    puts @errmsg
    CommonUI::HTMLfoot()
  end

  def send_mail
    subject = "a game is ready!! (#{@td.player1} vs #{@td.player2})"
    msg = mail_msg_newgame(@td.player1, @td.player2, @td.gid)

    mailmgr = MailManager.new
    mailmgr.send_mail(@td.email1, subject, msg)
    mailmgr.send_mail(@td.email2, subject, msg)
  end

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

  def put_msg
    puts <<-GENMSG.unindent
      new game generated!<BR>
      <a href='washcrus.rb?game/#{@td.gid}'><big>start playing &gt;&gt;</big></a><BR>

      mails were sent to both players.
      GENMSG
  end

  def err2log(e)
    @log.warn("class=[#{e.class}] message=[#{e.message}] in gennewgame")
  end

  def show(userinfo, params)
    return put_err_sreen(userinfo) unless generate(userinfo, params)

    # @log.debug('CommonUI::HTMLHead(header, title)')
    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(@name, userinfo)
    CommonUI::HTMLAdminMenu()

    @td.dumptable

    put_msg

    CommonUI::HTMLfoot()
  rescue ScriptError => e
    err2log(e)
  rescue SecurityError => e
    err2log(e)
  rescue => e
    err2log(e)
  end
end
