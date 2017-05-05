#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby
require "rubygems"
require 'yaml'
require 'digest/sha2'
#require 'mail'

require './common_ui.rb'
require "./userinfofile.rb"

#
# ユーザー登録完了or登録エラー画面
#
def register_screen(header, title, name, params)
  errmsg = ""

  if params['rname'] == nil || params['rname'].length == 0 \
      || params['rpassword'] == nil || params['rpassword'].length == 0 \
      || params['rpassword2'] == nil || params['rpassword2'].length == 0 \
      || params['remail'] == nil || params['remail'].length == 0 \
      || params['remail2'] == nil || params['remail2'].length == 0
    errmsg += "data lost ...<BR>"
  else
    username = params['rname'][0]
    password1 = params['rpassword'][0]
    password2 = params['rpassword2'][0]
    email1 = params['remail'][0]
    email2 = params['remail2'][0]

    if username == nil || username.length < 4
      errmsg += "short username ...<BR>"
    end
    if password1 == nil || password1 != password2
      errmsg += "wrong password ...<BR>"
    end
    if password1.length < 4
      errmsg += "short password ...<BR>"
    end
    if email1 == nil || email1 != email2
      errmsg += "wrong e-mail address ...<BR>"
    end
    if email1.length < 4
      errmsg += "short e-mail address ...<BR>"
    end

    userdb = UserInfoFile.new
    userdb.read
    if userdb.exist_name(username)
      errmsg += "same user name is already exists ...<BR>"
    end
    if userdb.exist_email(email1)
      errmsg += "same e-mail address is already exists ...<BR>"
    end
  end

  if errmsg != ""
    # エラー
    CommonUI::HTMLHead(header, title)
    CommonUI::HTMLmenu(name)

    print "Unfortunately failed ...<BR>", errmsg

    CommonUI::HTMLfoot()
  else
    # 登録する
    dgpw = Digest::SHA256.hexdigest password1

    userdb.add(username, dgpw, email1)
    userdb.write

    CommonUI::HTMLHead(header, title)
    CommonUI::HTMLmenu(name)

    print "Registered successfully.<BR>",
    "username:", username, "<BR>",
    "password:****<BR>",
    "email address:", email1, "<BR>",
    "Registration mail has been sent.<BR>"

    CommonUI::HTMLfoot()

    message = "Dear ", username, "\n",
      "Your information has been registed successfully as below.\n\n",
      "User name: ", username, "\n",
      "Password: ", password1, "\n",
      "E-mail address: ", email1, "\n\n",
      "* Please delete this email if you believe you are not the intended recipient.\n",
      "* Please do not respond to this auto-generated email."

    dlvcfg = YAML.load_file('./config/mail.yaml')
    mail = Mail.new do
      from    dlvcfg['mailaddress']
      to      email1
      subject "Welcome to Wash Crus!"
      body    message
    end
    mail.delivery_method(dlvcfg['type'],
      address:        dlvcfg['address'],
      port:           dlvcfg['port'],
      domain:         dlvcfg['domain'],
      authentication: dlvcfg['authentication'],
      user_name:      dlvcfg['user_name'],
      password:       dlvcfg['password']
    )
p mail
    mail.deliver
  end
end
