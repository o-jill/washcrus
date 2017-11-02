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
  # @return 値が入っていればtrue
  def check_params(params)
    params['rname'].nil? || params['rpassword'].nil? \
        || params['rpassword2'].nil? || params['remail'].nil? \
        || params['remail2'].nil?
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
    @errmsg += 'wrong username ...<BR>' if /^\s+/ =~ usernm || /\s+$/ =~ usernm
  end

  # パスワードの確認。エラーメッセージ転記。
  #
  # @param pswd1 パスワード1
  # @param pswd2 パスワード2
  def check_passwords(pswd1, pswd2)
    @errmsg += 'wrong password ...<BR>' if pswd1 != pswd2
    @errmsg += 'short password ...<BR>' if pswd1.length < 4
  end

  # メールアドレスの確認。エラーメッセージ転記。
  #
  # @param email1 メールアドレス1
  # @param email2 メールアドレス2
  def check_emails(email1, email2)
    @errmsg += 'wrong e-mail address ...<BR>' if email1 != email2
    @errmsg += 'short e-mail address ...<BR>' if email1.length < 4
  end

  # 登録情報の確認
  #
  # @param userdb ユーザーデータベース
  # @param params パラメータハッシュオブジェクト
  # @return nil or 登録情報{:username, :password1, :password2, :email1, :email2}
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

  # 登録完了メールの送信
  #
  # @param addr メールアドレス
  # @param username ユーザー名
  # @param pw パスワード
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

  # ユーザーの追加
  #
  # @param userdb ユーザーデータベース
  # @param uname  ユーザー名
  # @param pswd   パスワード
  # @param email  メールアドレス
  def add(userdb, uname, pswd, email)
    dgpw = Digest::SHA256.hexdigest pswd

    uid = userdb.add(uname, dgpw, email)
    userdb.append(uid)

    # send mail
    send_mail_register(email, uname, pswd)
  end

  def check_and_mkmsg(params)
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

    msg
  end

  # 画面の表示
  #
  # @param params パラメータハッシュオブジェクト
  def show(params)
    msg = check_and_mkmsg(params)

    CommonUI.html_head(@header)
    CommonUI.html_menu()

    print msg
    CommonUI.html_foot
  end
end
