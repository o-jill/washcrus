#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './file/chatfile.rb'
require './common_ui.rb'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './taikyokudata.rb'
require './userinfo.rb'
require './file/userinfofile.rb'

def check_datalost(params)
  params['rname'].nil? || params['rname'][0].length.zero? \
      || params['remail'].nil? || params['remail'][0].length.zero? \
      || params['rname2'].nil? || params['rname2'][0].length.zero? \
      || params['remail2'].nil? || params['remail2'][0].length.zero?
end

def furifusen(furigoma)
  furigoma.count('F') >= 3
end

def check_players
  errmsg = ''
  userdb = UserInfoFile.new
  userdb.read

  userdata1 = userdb.findname(name1) # [id, name, pw, email]
  if userdata1.nil? || email1 != userdata1[3]
    errmsg += "name or e-mail address in player 1 is wrong ...<BR>\n"
  end

  userdata2 = userdb.findemail(name2) # [id, name, pw, email]
  if userdata2.nil? || email2 != userdata2[3]
    errmsg += "name or e-mail address in player 2 is wrong ...<BR>\n"
  end

  { errmsg: ermsg, userdata1: userdata1, userdata2: userdata2 }
end

def generatenewgame_screen(header, title, name, userinfo, params)
  #
  # 対局作成確認
  #
  errmsg = ''

  if check_datalost(params)
    errmsg += 'data lost ...<BR>'
  else
    name1 = params['rname'][0]
    email1 = params['remail'][0]
    name2 = params['rname2'][0]
    email2 = params['remail2'][0]

    ret = check_players(name1, email1, name2, email2)
    errmsg += ret[:errmsg]
    if errmsg.length.zero?
      userdata1 = ret[:userdata1]
      userdata2 = ret[:userdata2]
    end
    # userdb = UserInfoFile.new
    # userdb.read
    # userdata1 = userdb.findemail(email1)  # [id, @names[id], @passwords[id]]
    # if userdata1.nil? || name1 != userdata1[1]
    #   errmsg += "name or e-mail address in player 1 is wrong ...<BR>\n"
    # end
    # userdata2 = userdb.findemail(email2)  # [id, @names[id], @passwords[id]]
    # if userdata2.nil? || name2 != userdata2[1]
    #   errmsg += "name or e-mail address in player 2 is wrong ...<BR>\n"
    # end
  end

  if userinfo.nil? || userinfo.invalid?
    errmsg += "your log-in information is wrong ...\n"
  end

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  if errmsg != ''
    puts errmsg
  else
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

    td.dumptable

    # send mail to the players

    puts <<-NEWGAMEMSG
      new game generated!<BR>
      <a href='game.rb?#{td.gid}'><big>start playing &gt;&gt;</big></a>
      NEWGAMEMSG
  end

  CommonUI::HTMLfoot()
end
