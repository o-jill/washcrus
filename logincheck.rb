#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'cgi'
require 'digest/sha2'
require './common_ui.rb'
require './userinfofile.rb'

def check_login(params, session)
  if params['sipassword'].nil? || params['sipassword'].length.zero?
    return ['data lost ...<BR>']
  end
  if params['siemail'].nil? || params['siemail'].length.zero?
    return ['data lost ...<BR>']
  end

  errmsg = ''

  password1 = params['sipassword'][0]
  errmsg += 'wrong password ...<BR>' if password1.nil? || password1.length < 4

  email1 = params['siemail'][0]
  errmsg += 'wrong e-mail address ...<BR>' if email1.nil? || email1.length < 4

  userdb = UserInfoFile.new
  userdb.read
  userdata = userdb.findemail(email1) # [id, @names[id], @passwords[id]]

  dgpw = Digest::SHA256.hexdigest password1

  if userdata.nil? || dgpw != userdata[2]
    return [errmsg += 'e-mail address or password is wrong ...<BR>']
  end

  userinfo = UserInfo.new(1, userdata[0], userdata[1], email1)
  userinfo.hashsession.each { |k, v| session[k] = v }
  username = userinfo.user_name

  # 登録する
  userdb.add(username, dgpw, email1)
  userdb.write

  [errmsg, userinfo]
end

#
# ログイン完了orログインエラー画面
#
def logincheck_screen(header, session, title, name, params)
  ret = check_login(params, session)
  errmsg = ret[0]

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)
  if errmsg != ''
    # エラー
    print "<SPAN class='err'>Unfortunately failed ...<BR>#{errmsg}</SPAN>\n"
  else
    userinfo = ret[1]
    print "Logged in successfully.<BR>\nusername:#{userinfo.user_name}<BR>\n",
          "password:****<BR>\nemail address:#{userinfo.user_email}<BR>\n"
  end
  CommonUI::HTMLfoot()
end
