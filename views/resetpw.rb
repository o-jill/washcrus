# -*- encoding: utf-8 -*-

require 'rubygems'
require 'erb'
require 'mail'
require 'securerandom'
require 'unindent'

require './file/userinfofile.rb'
require './util/mailmgr.rb'
require './util/settings.rb'
require './views/common_ui.rb'

#
# パスワードリセット画面
#
class ResetPasswordScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  attr_reader :newpw, :email

  # 登録情報の確認
  #
  # @param userdb UserInfoFileContentオブジェクト
  # @return nil or 登録情報{:username, :password1, :password2, :email1, :email2}
  def check_register(userdb, params)
    user = read_params(params)
    name = user[:username]
    check_username(name)

    check_passwords(user[:password1], user[:password2])
    email = user[:email1]
    check_emails(email, user[:email2])

    # if userdb.exist_name_or_email(name, email)
    if userdb.exist_name(name) || userdb.exist_email(email)
      @errmsg = 'user name or e-mail address is already exists...'
    end

    user
  end

  # 登録完了メールの送信
  #
  # @param addr メールアドレス
  # @param username ユーザー名
  # @param pwd パスワード
  def send_mail_resetpwd(addr, username, pwd)
    erbtxt = File.read('./mail/resetpwd.erb', encoding: 'utf-8')
    msg = ERB.new(erbtxt).result(binding)

    msg + "\n"

    stg = Settings.instance
    subject = "Resetting password for #{stg.value['title']}!"

    mailmgr = MailManager.new
    mailmgr.send_mail_withfooter(addr, subject, msg)
  end

  # パラメータのチェックと表示メッセージ作成
  #
  # @param params パラメータハッシュオブジェクト
  #
  # @return 表示用メッセージ
  def check_and_mkmsg(params)
    # emailアドレスの読み取り
    @email = params['premail'] || ['wrong_email']
    @email = email[0]

    # パスワードの生成
    @newpw = SecureRandom.base64(6)

    # userdbにあるかどうかの確認
    # パスワードの再設定
    userdb = UserInfoFile.new
    userdata = userdb.update_password(email, newpw)

    # メールの送信
    send_mail_resetpwd(email, userdata[:name], newpw) if userdata
  end

  # 画面の表示
  #
  # @param params パラメータハッシュオブジェクト
  def show(params)
    check_and_mkmsg(params)

    CommonUI.html_head(@header)
    CommonUI.html_menu

    puts <<-RESET_PW_MSG.unindent
      password for "#{email}" was reset.<br>
      a new password has been sent to #{email}.<br>
      (we don't check if the address is correct or not.)
    RESET_PW_MSG
    # @newpw:#{@newpw}<br>

    CommonUI.html_foot
  end
end
