# -*- encoding: utf-8 -*-
#!d:\ruby193\bin\ruby

#!/usr/bin/ruby

require 'cgi'
require 'digest/sha2'
require './common_ui.rb'
require './userinfofile.rb'

#
# ログイン完了orログインエラー画面
#
def logincheck_screen(header, session, title, name, params)
  errmsg = ''

  if params['sipassword'].nil? || params['sipassword'].length.zero? \
      || params['siemail'].nil? || params['siemail'].length.zero?
    errmsg += 'data lost ...<BR>'
  else
    password1 = params['sipassword'][0]
    email1 = params['siemail'][0]

    dgpw = nil
    if password1.nil? || password1.length < 4
      errmsg += 'wrong password ...<BR>'
    else
      dgpw = Digest::SHA256.hexdigest password1
    end
    if email1.nil? || email1.length < 4
      errmsg += 'wrong e-mail address ...<BR>'
    end

    userdb = UserInfoFile.new
    userdb.read
    userdata = userdb.findemail(email1)  # [id, @names[id], @passwords[id]]
    if userdata.nil? || dgpw != userdata[2]
      errmsg += 'e-mail address or password is wrong ...<BR>'
    else
      userinfo = UserInfo.new(1, userdata[0], userdata[1], email1)
      userinfo.hashsession.each { |k, v|
        session[k] = v
      }

      username = userinfo.user_name
    end
  end

  if errmsg != ''
    # エラー
    CommonUI::HTMLHead(header, title)
    CommonUI::HTMLmenu(name)

    print <<-STYLESHEET
      <style type="text/css">
      <!--
        span.err { font-size: 2rem; border: 1px solid red; }
      -->
      </style>
      STYLESHEET
    print '<SPAN class=err>Unfortunately failed ...<BR>', errmsg, "</SPAN>\n"

    CommonUI::HTMLfoot()
  else
    # 登録する
    dgpw = Digest::SHA256.hexdigest password1

    userdb.add(username, dgpw, email1)
    userdb.write

    CommonUI::HTMLHead(header, title)
    CommonUI::HTMLmenuLogIn(name)

    print 'Logged in successfully.<BR>',
          'username:', userinfo.user_name, '<BR>',
          'password:****<BR>',
          'email address:', email1, '<BR>'

    CommonUI::HTMLfoot()
  end
end
