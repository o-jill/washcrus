#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './chatfile.rb'
require './common_ui.rb'
require './jsonkifu.rb'
require './matchinfofile.rb'
require './taikyokudata.rb'
require './userinfo.rb'
require './userinfofile.rb'

def check_datalost(params)
  params['rname'].nil? || params['rname'] == '' \
      || params['remail'].nil? || params['remail'] == '' \
      || params['rname2'].nil? || params['rname2'] == '' \
      || params['remail2'].nil? || params['remail2'] == ''
end

def furifusen(furigoma)
  furigoma.count('F') >= 3
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

    userdb = UserInfoFile.new
    userdb.read
    userdata1 = userdb.findemail(email1)  # [id, @names[id], @passwords[id]]
    if userdata1.nil? || name1 != userdata1[1]
      errmsg += "name or e-mail address in player 1 is wrong ...\n"
    end
    userdata2 = userdb.findemail(email2)  # [id, @names[id], @passwords[id]]
    if userdata2.nil? || name2 != userdata2[1]
      errmsg += "name or e-mail address in player 2 is wrong ...\n"
    end
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
      td.setplayer1(name1, email1)
      td.setplayer2(name2, email2)
    else
      td.setplayer1(name2, email2)
      td.setplayer2(name1, email1)
    end
    td.creator = userinfo.user_name + '(' + userinfo.user_id + ')'

    td.generate

    td.dumptable

    # match information file
    mi = MatchInfoFile.new(td.id)
    mi.initial_write(td, userdata1[0], userdata2[0])

    # kifu file
    kif = JSONKifu.new(td.id)
    kif.initial_write(td)

    # chat file
    chat = ChatFile.new(td.id)
    chat.sayex("<span id='chatadmin'>Witness</span>",
               "it's on time. plz start your move #{name1}-san.")

    # send mail to the players

    puts <<-NEWGAMEMSG
      new game generated!<BR>
      <a href='game.rb?#{td.id}'><big>start playing &gt;&gt;</big></a>
      NEWGAMEMSG
  end

  CommonUI::HTMLfoot()
end
