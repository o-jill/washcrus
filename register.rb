#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby
require 'rubygems'
require 'yaml'
require 'digest/sha2'
# require 'mail'

require './common_ui.rb'
require './userinfofile.rb'

def check_register(params)
  if params['rname'].nil? || params['rname'].length.zero? \
      || params['rpassword'].nil? || params['rpassword'].length.zero? \
      || params['rpassword2'].nil? || params['rpassword2'].length.zero? \
      || params['remail'].nil? || params['remail'].length.zero? \
      || params['remail 2'].nil? || params['remail2'].length.zero?
    return 'data lost ...<BR>'
  end

  username = params['rname'][0]
  password1 = params['rpassword'][0]
  password2 = params['rpassword2'][0]
  email1 = params['remail'][0]
  email2 = params['remail2'][0]

  errmsg = ''

  errmsg += 'short username ...<BR>' if username.nil? || username.length < 4

  errmsg += 'wrong password ...<BR>' if password1.nil? || password1 != password2

  errmsg += 'short password ...<BR>' if password1.length < 4

  errmsg += 'wrong e-mail address ...<BR>' if email1.nil? || email1 != email2

  errmsg += 'short e-mail address ...<BR>' if email1.length < 4

  errmsg
end

#
# ユーザー登録完了or登録エラー画面
#
def register_screen(header, title, name, params)
  errmsg = check_register(params)

  if errmsg == ''
    username = params['rname'][0]
    password1 = params['rpassword'][0]
    email1 = params['remail'][0]

    # 登録する
    dgpw = Digest::SHA256.hexdigest password1

    userdb.add(username, dgpw, email1)
    userdb.write
  end

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  if errmsg != ''
    # エラー

    print 'Unfortunately failed ...<BR>', errmsg

    CommonUI::HTMLfoot()
  else
    print 'Registered successfully.<BR>',
          'username:', username, '<BR>',
          'password:****<BR>',
          'email address:', email1, '<BR>',
          'Registration mail has been sent.<BR>'

    CommonUI::HTMLfoot()

    # send mail
    message = "Dear#{username}\n",
              "Your information has been registed successfully as below.\n\n",
              "User name: #{username}\nPassword: #{password1}\n",
              "E-mail address: #{email1}\n\n",
              '* Please delete this email ',
              "if you believe you are not the intended recipient.\n",
              '* Please do not respond to this auto-generated email.'

    dlvcfg = YAML.load_file('./config/mail.yaml')
    mail = Mail.new do
      from    dlvcfg['mailaddress']
      to      email1
      subject 'Welcome to Wash Crus!'
      body    message
    end
    mail.delivery_method(dlvcfg['type'],
                         address:        dlvcfg['address'],
                         port:           dlvcfg['port'],
                         domain:         dlvcfg['domain'],
                         authentication: dlvcfg['authentication'],
                         user_name:      dlvcfg['user_name'],
                         password:       dlvcfg['password'])
    # p mail
    mail.deliver
  end
end
