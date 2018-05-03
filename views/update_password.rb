# -*- encoding: utf-8 -*-

require 'rubygems'
require 'mail'
require 'unindent'

require './file/userinfofile.rb'
require './util/mailmgr.rb'
require './util/settings.rb'
require './views/common_ui.rb'

#
# パスワード変更画面
#
class UpdatePasswordScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # エラー画面の表示
  #
  # @param errmsg エラーメッセージ
  def put_err_sreen(errmsg)
    CommonUI.html_head(@header)
    CommonUI.html_menu
    puts errmsg
    CommonUI.html_foot
  end

  # 登録完了メールの送信
  #
  # @param userinfo ユーザー情報
  # @param pwd パスワード
  def send_mail(userinfo, pwd)
    addr = userinfo.user_email
    username = userinfo.user_name

    msg = <<-MAIL_MSG.unindent
      Dear #{username}

      Your password was updated as below.

      User name: #{username}
      Password: #{pw}
      E-mail address: #{addr}

      MAIL_MSG
    msg += MailManager.footer

    stg = Settings.instance
    subject = "Updating password for #{stg.value['title']}!"

    mailmgr = MailManager.new
    mailmgr.send_mail(addr, subject, msg)
  end

  # パラメータのチェックと表示メッセージ作成
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  #
  # @return 表示用メッセージ
  def check_and_mkmsg(userinfo, params)
    # パスワードの読み取り
    @passwd = params['sipassword'] || ['']
    @passwd = @passwd[0]

    @newpw1 = params['rnewpassword'] || ['1']
    @newpw1 = @newpw1[0]
    @newpw2 = params['rnewpassword2'] || ['2']
    @newpw2 = @newpw2[0]

    # 新パスワードの確認
    return '<span class="err">new passwords are not same!</span>' \
      if @newpw1 != @newpw2
    return '<span class="err">the new password is too short!</span>' \
      if @newpw1.length < 4

    uid = userinfo.user_id

    # 古いパスワードの確認
    userdb = UserInfoFile.new
    userdb.read

    # [@names[id], @passwords[id], @emails[id]]
    userdata = userdb.content.findid(uid)
    return '<span class="err">user information error...</span>' unless userdata

    dgpw = Digest::SHA256.hexdigest @passwd
    return '<span class="err">old password is not correct!</span>' \
      if dgpw != userdata[1]

    # パスワードの再設定
    userdb.update_password_byid(uid, @newpw1)

    # メールの送信
    send_mail(userinfo, @newpw1)

    'Your password was updated.<br>The new password has been sent to you.'
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return put_err_sreen("your log-in information is wrong ...\n") \
      if userinfo.invalid?

    msg = check_and_mkmsg(userinfo, params)

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    puts msg

    CommonUI.html_foot
  end
end
