# -*- encoding: utf-8 -*-

require 'rubygems'
require 'digest/sha2'
require 'mail'
require 'yaml'
require 'unindent'

require './file/userinfofile.rb'
require './util/mailmgr.rb'
require './views/common_ui.rb'

#
# ユーザー登録完了or登録エラー画面
#
class RegisterScreen
  def initialize(header, title, name)
    @header = header
    @title = title
    @name = name

    @errmsg = ''
  end

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
    @errmsg += 'short username ...<BR>' if usernm.bytesize < 4
    @errmsg += 'wrong username ...<BR>' if /^\s+/ =~ usernm || /\s+$/ =~ usernm
  end

  def check_passwords(pswd1, pswd2)
    @errmsg += 'wrong password ...<BR>' if pswd1 != pswd2
    @errmsg += 'short password ...<BR>' if pswd1.length < 4
  end

  def check_emails(email1, email2)
    @errmsg += 'wrong e-mail address ...<BR>' if email1 != email2
    @errmsg += 'short e-mail address ...<BR>' if email1.length < 4
  end

  def check_register(userdb, params)
    return @errmsg += 'data lost ...<BR>' if check_params(params)

    user = read_params(params)

    check_username(user[:username])

    check_passwords(user[:password1], user[:password2])

    check_emails(user[:email1], user[:email2])

    if userdb.exist_name_or_email(user[:username], user[:email1])
      @errmsg = 'user name or e-mail address is already exists...'
    end

    user
  end

  def send_mail_register(addr, username, pw)
    msg = <<-MAIL_MSG.unindent
      Dear #{username}

      Your information has been registered successfully as below.

      User name: #{username}
      Password: #{pw}
      E-mail address: #{addr}

      MAIL_MSG
    msg += MailManager.footer

    mailmgr = MailManager.new
    mailmgr.send_mail(addr, 'Welcome to Wash Crus!', msg)
  end

  def add(userdb, uname, pswd, email)
    dgpw = Digest::SHA256.hexdigest pswd

    uid = userdb.add(uname, dgpw, email)
    userdb.append(uid)

    # send mail
    send_mail_register(email, uname, pswd)
  end

  def show(params)
    userdb = UserInfoFile.new
    userdb.read

    user = check_register(userdb, params)

    if @errmsg.length.zero?
      # 登録する
      add(userdb, user[:username], user[:password1], user[:email1])

      msg = <<-REG_SUC_MSG.unindent
        Registered successfully.<BR>username:#{user[:username]}<BR>
        password:****<BR>email address:#{user[:email1]}<BR>
        <BR>
        Registration mail has been sent.<BR>
        REG_SUC_MSG
    else
      # エラー
      msg = "<div class='err'>Unfortunately failed ...<BR>#{@errmsg}</div>"
    end

    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(@name)

    print msg
    CommonUI::HTMLfoot()
  end
end
