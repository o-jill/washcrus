#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './file/chatfile.rb'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './file/userinfofile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'
require './views/common_ui.rb'

def check_datalost(params)
  params['rname'].nil? || params['remail'].nil? \
      || params['rname2'].nil? || params['remail2'].nil?
end

def furifusen(furigoma)
  furigoma.count('F') >= 3
end

def check_players
  userdb = UserInfoFile.new
  userdb.read

  errmsg = ''
  userdata1 = userdb.findname(name1) # [id, name, pw, email]
  if userdata1.nil? || email1 != userdata1[3]
    errmsg += "name or e-mail address in player 1 is wrong ...<BR>\n"
  end

  userdata2 = userdb.findemail(name2) # [id, name, pw, email]
  if userdata2.nil? || email2 != userdata2[3]
    errmsg += "name or e-mail address in player 2 is wrong ...<BR>\n"
  end

  { errmsg: errmsg, userdata1: userdata1, userdata2: userdata2 }
end

def check_newgame(params)
  return { errmsg: 'data lost ...<BR>' } if check_datalost(params)

  name1 = params['rname'][0]
  email1 = params['remail'][0]
  name2 = params['rname2'][0]
  email2 = params['remail2'][0]

  check_players(name1, email1, name2, email2)
end

def generatenewgame_screen(header, title, name, userinfo, params)
  #
  # 対局作成確認
  #

  ret = check_newgame(params)
  errmsg = ret[:errmsg]
  unless errmsg.length.zero?
    userdata1 = ret[:userdata1]
    userdata2 = ret[:userdata2]
  end

  errmsg += "your log-in information is wrong ...\n" \
      if userinfo.nil? || userinfo.invalid?

  if errmsg != ''
    CommonUI::HTMLHead(header, title)
    CommonUI::HTMLmenu(name)
    puts errmsg
    return CommonUI::HTMLfoot()
  end

  td = TaikyokuData.new
  if furifusen(params['furigoma'][0])
    td.setplayer1(userdata1[0], name1, email1)
    td.setplayer2(userdata2[0], name2, email2)
  else
    td.setplayer1(userdata2[0], name2, email2)
    td.setplayer2(userdata1[0], name1, email1)
  end

  td.creator = userinfo.user_name + '(' + userinfo.user_id + ')'

  td.generate

  # send mail to the players

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  td.dumptable

  puts "new game generated!<BR>" \
       "<a href='game.rb?#{td.gid}'><big>start playing &gt;&gt;</big></a>"

  CommonUI::HTMLfoot()
end
