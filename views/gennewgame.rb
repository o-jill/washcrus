# -*- encoding: utf-8 -*-

require 'logger'

require './file/chatfile.rb'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './file/userinfofile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'
require './util/mailmgr.rb'
require './views/common_ui.rb'

def check_datalost_gengame(params)
  params['rname'].nil? || params['remail'].nil? \
      || params['rname2'].nil? || params['remail2'].nil?
end

def furifusen(furigoma)
  furigoma.count('F') >= 3
end

def check_players(name1, email1, name2, email2)
  userdb = UserInfoFile.new
  userdb.read

  errmsg = ''
  userdata1 = userdb.findname(name1) # [id, name, pw, email]
  if userdata1.nil? || email1 != userdata1[3]
    errmsg += "name or e-mail address in player 1 is wrong ...<BR>\n"
  end

  userdata2 = userdb.findname(name2) # [id, name, pw, email]
  if userdata2.nil? || email2 != userdata2[3]
    errmsg += "name or e-mail address in player 2 is wrong ...<BR>\n"
  end

  { errmsg: errmsg, userdata1: userdata1, userdata2: userdata2 }
end

def check_newgame(params)
  return { errmsg: 'data lost ...<BR>' } if check_datalost_gengame(params)

  name1 = params['rname'][0]
  email1 = params['remail'][0]
  name2 = params['rname2'][0]
  email2 = params['remail2'][0]

  check_players(name1, email1, name2, email2)
end


def mail_msg_newgame(user1, user2, gameid)
  msg = <<-MAIL_MSG.unindent
    Dear #{user1} and #{user2}

    a new game is ready for you.
    please visit a URL bellow to play.
    http://localhost/cgi-bin/game.rb?#{gameid}

    MAIL_MSG
  msg += MailManager.footer
  msg
end

def put_err_sreen(header, title, name, errmsg)
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)
  puts errmsg
  CommonUI::HTMLfoot()
end

def generatenewgame_screen(header, title, name, userinfo, params)
  #
  # 対局作成確認
  #
  log = Logger.new('./tmp/newgamegenlog.txt')

  ret = check_newgame(params)
  errmsg = ret[:errmsg]
log.debug('check_newgame(params)')
  errmsg += "your log-in information is wrong ...\n" \
      if userinfo.nil? || userinfo.invalid?

  return put_err_sreen(header, title, name, errmsg) if errmsg != ''

log.debug('put_err_sreen')

  userdata1 = ret[:userdata1]
  userdata2 = ret[:userdata2]

log.debug('TaikyokuData.new')
  td = TaikyokuData.new

log.debug('td.setplayer1')
  td.setplayer1(userdata1[0], userdata1[1], userdata1[3])
log.debug('td.setplayer2')
  td.setplayer2(userdata2[0], userdata2[1], userdata2[3])
log.debug("furifusen(#{params['furigoma'][0].count('F')})")
  td.switchplayers unless furifusen(params['furigoma'][0])

log.debug('td.creator')
  td.creator = "#{userinfo.user_name}(#{userinfo.user_id})"

log.debug('td.generate')
td.log = log
  td.generate

  # send mail to the players
  subject = "a game is ready!! (#{td.player1} vs #{td.player2})"
  msg = mail_msg_newgame(td.player1, td.player2, td.gid)
  mailmgr = MailManager.new
  mailmgr.send_mail(td.email1, subject, msg)
  mailmgr.send_mail(td.email2, subject, msg)

log.debug('CommonUI::HTMLHead(header, title)')
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenuLogIn(name, true)

  td.dumptable

  puts 'new game generated!<BR>' \
       "<a href='game.rb?#{td.gid}'><big>start playing &gt;&gt;</big></a><BR>"

  puts 'mails were sent to both players.'

  CommonUI::HTMLfoot()
end
