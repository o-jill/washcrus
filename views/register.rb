#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby
require 'rubygems'
require 'yaml'
require 'digest/sha2'
# require 'mail'

require './file/userinfofile.rb'
require './views/common_ui.rb'

def check_register(params)
  if params['rname'].nil? || params['rpassword'].nil? \
      || params['rpassword2'].nil? || params['remail'].nil? \
      || params['remail2'].nil?
    return 'data lost ...<BR>'
  end

  username = params['rname'][0]
  password1 = params['rpassword'][0]
  password2 = params['rpassword2'][0]
  email1 = params['remail'][0]
  email2 = params['remail2'][0]

  errmsg = ''

  errmsg += 'short username ... you need 4 letters at least.<BR>' \
      if username.nil? || username.length < 4

  errmsg += 'wrong password ...<BR>' if password1.nil? || password1 != password2

  errmsg += 'short password ... you need 4 letters at least.<BR>' \
      if password1.length < 4

  errmsg += 'wrong e-mail address ...<BR>' if email1.nil? || email1 != email2

  errmsg += 'short e-mail address ...<BR>' if email1.length < 4

  errmsg
end

def mail_msg(username, pw, email)
  "Dear#{username}\n" \
  "Your information has been registed successfully as below.\n\n" \
  "User name: #{username}\nPassword: #{pw}\n" \
  "E-mail address: #{email}\n\n" \
  '* Please delete this email ' \
  "if you believe you are not the intended recipient.\n" \
  '* Please do not respond to this auto-generated email.'
end

def send_mail_register(message)
  # send mail
  dlvcfg = YAML.load_file('./config/mail.yaml')
  mail = Mail.new do
    from    dlvcfg['mailaddress']
    to      email
    subject 'Welcome to Wash Crus!'
    body    message
  end
  mail.delivery_method(dlvcfg['type'],
                       address: dlvcfg['address'], port: dlvcfg['port'],
                       domain: dlvcfg['domain'],
                       authentication: dlvcfg['authentication'],
                       user_name: dlvcfg['user_name'],
                       password: dlvcfg['password'])
  mail.deliver
  # p mail
end

#
# ユーザー登録完了or登録エラー画面
#
def register_screen(header, title, name, params)
  errmsg = check_register(params)

  if errmsg.length.zero?
    username = params['rname'][0]
    password1 = params['rpassword'][0]
    email1 = params['remail'][0]

    # 登録する
    dgpw = Digest::SHA256.hexdigest password1

    userdb.add(username, dgpw, email1)
    userdb.write

    # send mail
    send_mail_register(mail_msg(username, password1, email1))
  end

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  if errmsg.length.zero?
    print "Registered successfully.<BR>username:#{username}<BR>",
          "password:****<BR>email address:#{email1}<BR>",
          'Registration mail has been sent.<BR>'
  else
    # エラー
    print 'Unfortunately failed ...<BR>', errmsg
  end

  CommonUI::HTMLfoot()
end
