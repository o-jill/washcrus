#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'cgi'
require 'digest/sha2'
require './common_ui.rb'
require './userinfofile.rb'

def check_login(params)
  password1 = params['sipassword']
  return { errmsg: 'data lost ...<BR>' } if password1.nil? || password1.length.zero?

  email1 = params['siemail']
  return { errmsg: 'data lost ...<BR>' } if email1.nil? || email1.length.zero?

  errmsg = ''

  password1 = password1[0]
  errmsg += 'wrong password ...<BR>' if password1.nil? || password1.length < 4

  email1 = email1[0]
  errmsg += 'wrong e-mail address ...<BR>' if email1.nil? || email1.length < 4

  userdb = UserInfoFile.new
  userdb.read
  userdata = userdb.findemail(email1) # [id, @names[id], @passwords[id]]

  dgpw = Digest::SHA256.hexdigest password1

  if userdata.nil? || dgpw != userdata[2]
    errmsg += 'e-mail address or password is wrong ...<BR>'
    return { errmsg: errmsg }
  end

  userinfo = UserInfo.new(1, userdata[0], userdata[1], email1)

  # 登録する
  userdb.add(userinfo.user_name, dgpw, email1)
  userdb.write

  { errmsg: errmsg, userinfo: userinfo }
end

#
# ログイン完了orログインエラー画面
#
def logincheck_screen(header, session, title, name, cgi)
  ret = check_login(cgi.params, session)
  errmsg = ret[:errmsg]

  if errmsg.length.zero?
    userinfo = ret[:userinfo]

    userinfo.hashsession.each { |k, v| session[k] = v }

    session['session_expires'] = Time.now + 2_592_000 # 30days

    session.update

    CommonUI::HTMLHead(header, title)
    CommonUI::HTMLmenuLogIn(name)
    print "Logged in successfully.<BR>\nusername:#{userinfo.user_name}<BR>\n",
          "password:****<BR>\nemail address:#{userinfo.user_email}<BR>\n"
  else
    CommonUI::HTMLHead(header, title)
    CommonUI::HTMLmenu(name)
    # エラー
    print "<SPAN class='err'>Unfortunately failed ...<BR>#{errmsg}</SPAN>\n"
  end
  CommonUI::HTMLfoot()
end
