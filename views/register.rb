# -*- encoding: utf-8 -*-

require 'rubygems'
require 'digest/sha2'
require 'mail'
require 'yaml'
require 'unindent'

require './file/userinfofile.rb'
require './util/mailmgr.rb'
require './util/settings.rb'
require './views/common_ui.rb'

#
# ユーザー登録完了or登録エラー画面
#
class RegisterScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header

    @errmsg = ''
  end

  # パラメータの確認
  #
  # @param params パラメータハッシュオブジェクト
  # @return すべて値が入っていればtrue
  def check_params(params)
    params['rname'] && params['rpassword'] && params['rpassword2'] \
      && params['remail'] && params['remail2']
  end

  # パラメータの読み込み。ハッシュで返す
  #
  # @param params パラメータハッシュオブジェクト
  # @return 登録情報{:username, :password1, :password2, :email1, :email2}
  def read_params(params)
    {
      username: (params['rname'][0] || '').strip,
      password1: params['rpassword'][0] || '',
      password2: params['rpassword2'][0] || '',
      email1: (params['remail'][0] || '').strip,
      email2: (params['remail2'][0] || '').strip
    }
  end

  # ユーザー名の確認。エラーメッセージ転記。
  #
  # @param usernm ユーザー名
  def check_username(usernm)
    @errmsg += 'short username ...<BR>' if usernm.bytesize < 4
    @errmsg += 'wrong username ...<BR>' \
      if /^\s+/ =~ usernm || /\s+$/ =~ usernm || /https?:/ =~ usernm
  end

  # パスワードの確認。エラーメッセージ転記。
  #
  # @param pswd  パスワード
  # @param pswdv パスワード2回目
  def check_passwords(pswd, pswdv)
    @errmsg += 'wrong password ...<BR>' if pswd != pswdv
    @errmsg += 'short password ...<BR>' if pswd.length < 4
  end

  # メールアドレスの確認。エラーメッセージ転記。
  #
  # @param email  メールアドレス
  # @param emailv メールアドレス2回目
  def check_emails(email, emailv)
    @errmsg += 'wrong e-mail address ...<BR>' if email != emailv
    @errmsg += 'short e-mail address ...<BR>' if email.length < 4
  end

  # 登録情報の確認
  #
  # @param userdb UserInfoFileContentオブジェクト
  # @param params パラメータハッシュオブジェクト
  # @return nil or 登録情報{:username, :password1, :password2, :email1, :email2}
  def check_register(userdb, params)
    return @errmsg += 'data lost ...<BR>' unless check_params(params)

    user = read_params(params)

    check_username(user[:username])

    check_passwords(user[:password1], user[:password2])

    check_emails(user[:email1], user[:email2])

    # if userdb.exist_name_or_email(user[:username], user[:email1])
    if userdb.exist_name(user[:username]) || userdb.exist_email(user[:email1])
      @errmsg = 'user name or e-mail address already exists...'
    end

    user
  end

  # 登録完了メールの送信
  #
  # @param addr メールアドレス
  # @param username ユーザー名
  # @param pwd パスワード
  def send_mail_register(addr, username, pwd)
    msg = <<-MAIL_MSG.unindent
      Dear #{username}

      Your information has been registered successfully as below.

      User name: #{username}
      Password: #{pwd}
      E-mail address: #{addr}

    MAIL_MSG

    stg = Settings.instance
    subject = "Welcome to #{stg.value['title']}!"

    mailmgr = MailManager.new
    mailmgr.send_mail_withfooter(addr, subject, msg)
  end

  # ユーザーの追加
  #
  # @param userdb ユーザーデータベース
  # @param uname  ユーザー名
  # @param pswd   パスワード
  # @param email  メールアドレス
  def add(userdb, uname, pswd, email)
    dgpw = Digest::SHA256.hexdigest pswd

    userdb.add(uname, dgpw, email)

    # send mail
    send_mail_register(email, uname, pswd)
  end

  # パラメータのチェックと表示メッセージ作成
  #
  # @param params パラメータハッシュオブジェクト
  #
  # @return 表示用メッセージ
  def check_and_mkmsg(params)
    userdb = UserInfoFile.new
    userdb.read

    user = check_register(userdb.content, params)
    name = user[:username]
    email = user[:email1]
    # エラー
    return "<div class='err'>Unfortunately failed ...<BR>#{@errmsg}</div>" \
        unless @errmsg.empty?

    # 登録する
    add(userdb, name, user[:password1], email)

    msg = <<-REG_SUC_MSG.unindent
      Registered successfully.<BR>username:#{name}<BR>
      password:****<BR>email address:#{email}<BR>
      <BR>
      Registration mail has been sent.<BR>
    REG_SUC_MSG

    msg
  end

  # 画面の表示
  #
  # @param params パラメータハッシュオブジェクト
  def show(params)
    msg = check_and_mkmsg(params)

    CommonUI.html_head(@header)
    CommonUI.html_menu

    print msg
    CommonUI.html_foot
  end
end
