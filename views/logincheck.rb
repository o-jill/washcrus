#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'cgi'
require 'digest/sha2'
require './file/userinfofile.rb'
require './views/common_ui.rb'

def check_login(params)
  pswd = params['sipassword']
  return { errmsg: 'data lost ...<BR>' } if pswd.nil? || pswd.length.zero?

  email = params['siemail']
  return { errmsg: 'data lost ...<BR>' } if email.nil? || email.length.zero?

  errmsg = ''

  pswd = pswd[0]
  errmsg += 'wrong password ...<BR>' if pswd.nil? || pswd.length < 4

  email = email[0]
  errmsg += 'wrong e-mail address ...<BR>' if email.nil? || email.length < 4

  userdb = UserInfoFile.new
  userdb.read
  userdata = userdb.findemail(email) # [id, @names[id], @passwords[id]]

  dgpw = Digest::SHA256.hexdigest pswd

  if userdata.nil? || dgpw != userdata[2]
    errmsg += 'e-mail address or password is wrong ...<BR>'
    return { errmsg: errmsg }
  end

  userinfo = UserInfo.new(1, userdata[0], userdata[1], email)

  { errmsg: errmsg, userinfo: userinfo }
end

#
# ログイン完了orログインエラー画面
#
def logincheck_screen(header, session, title, name, cgi)
  ret = check_login(cgi.params)
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
