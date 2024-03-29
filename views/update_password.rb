# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'erb'
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

  # @!attribute [r] newpw
  #   @return 新しいパスワード
  # @!attribute [r] newpwagain
  #   @return 新しいパスワード再
  # @!attribute [r] passwd
  #   @return 現在のパスワード
  attr_reader :newpw, :newpwagain, :passwd

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

    msg = ERB.new(
      File.read('./mail/updatepassword.erb', encoding: 'utf-8')
    ).result(binding)

    stg = Settings.instance
    subject = "Updating password for #{stg.value['title']}!"

    mailmgr = MailManager.new
    mailmgr.send_mail_withfooter(addr, subject, msg)
  end

  # paramsから値を取り出す。
  # keyが無いときはdefaultを使う。
  def safer_params(params, key, default)
    val = params[key] || default
    val[0]
  end

  # パスワードの読み取り
  #
  # @param params パラメータハッシュオブジェクト
  def readpwd(params)
    @passwd = safer_params(params, 'sipassword', [''])

    @newpw = safer_params(params, 'rnewpassword', ['1'])
    @newpwagain = safer_params(params, 'rnewpassword2', ['2'])
  end

  # 新パスワードの確認
  def check_newpw
    # 新パスワードの確認
    return '<span class="err">new passwords are not same!</span>' \
      if newpw != newpwagain
    return '<span class="err">the new password is too short!</span>' \
      if newpw.length < 4
  end

  # 古いパスワードの確認
  def check_curpw(userdb, uid)
    userdata = userdb.content.findid(uid) # [names:, pw:, email:]
    return '<span class="err">user information error...</span>' unless userdata

    dgpw = Digest::SHA256.hexdigest passwd
    return '<span class="err">old password is not correct!</span>' \
      if dgpw != userdata[:pw]
  end

  # パラメータのチェックと表示メッセージ作成
  #
  # @param userinfo ユーザー情報
  #
  # @return 表示用メッセージ
  def check_and_mkmsg(userinfo)
    # 新パスワードの確認
    ret = check_newpw
    return ret if ret

    uid = userinfo.user_id

    # 古いパスワードの確認
    userdb = UserInfoFile.new
    userdb.read

    ret = check_curpw(userdb, uid)
    return ret if ret

    # パスワードの再設定
    userdb.update_password_byid(uid, newpw)

    # メールの送信
    send_mail(userinfo, newpw)

    'Your password was updated.<br>The new password has been sent to you.'
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return put_err_sreen("your log-in information is wrong ...\n") \
      if userinfo.invalid?

    readpwd(params)
    msg = check_and_mkmsg(userinfo)

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    puts msg

    CommonUI.html_foot
  end
end
