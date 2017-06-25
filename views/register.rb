# -*- encoding: utf-8 -*-

require 'rubygems'
require 'yaml'
require 'digest/sha2'
# require 'mail'

require './file/userinfofile.rb'
require './views/common_ui.rb'

def check_params(params)
  params['rname'].nil? || params['rpassword'].nil? \
      || params['rpassword2'].nil? || params['remail'].nil? \
      || params['remail2'].nil?
end

def read_params(params)
  {
    username: (params['rname'][0] || '').strip,
    password1: params['rpassword'][0] || '',
    password2: params['rpassword2'][0] || '',
    email1: (params['remail'][0] || '').strip,
    email2: (params['remail2'][0] || '').strip
  }
end

def check_username(usernm)
  errmsg = ''
  errmsg += 'short username ...<BR>' if usernm.bytesize < 4
  errmsg += 'wrong username ...<BR>' if /^\s+/ =~ usernm || /\s+$/ =~ usernm
  errmsg
end

def check_passwords(pswd1, pswd2)
  errmsg = ''
  errmsg += 'wrong password ...<BR>' if pswd1 != pswd2
  errmsg += 'short password ...<BR>' if pswd1.length < 4
  errmsg
end

def check_emails(email1, email2)
  errmsg = ''
  errmsg += 'wrong e-mail address ...<BR>' if email1 != email2
  errmsg += 'short e-mail address ...<BR>' if email1.length < 4
  errmsg
end

def check_register(params)
  return 'data lost ...<BR>' if check_params(params)

  user = read_params(params)

  errmsg = ''

  errmsg += check_username(user[:username])

  errmsg += check_passwords(user[:password1], user[:password2])

  errmsg += check_emails(user[:email1], user[:email2])

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
    username = params['rname'][0].strip
    password1 = params['rpassword'][0]
    email1 = params['remail'][0].strip

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
