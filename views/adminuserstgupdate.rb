# -*- encoding: utf-8 -*-

require 'rubygems'
require 'mail'
require 'unindent'

require './file/userinfofile.rb'
require './util/mailmgr.rb'
require './util/settings.rb'
require './views/common_ui.rb'

#
# User情報更新画面
#
class AdminUserStgUpdateScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  attr_reader :uid, :newem, :newnm, :header, :admin, :ntfmail

  # エラー画面の表示
  #
  # @param errmsg エラーメッセージ
  def put_err_sreen(errmsg)
    CommonUI.html_head(@header)
    CommonUI.html_menu
    puts errmsg
    CommonUI.html_foot
  end

  # 登録メール
  def send_mail
    addr = newem
    username = newnm

    msg = <<-MAIL_MSG.unindent
      Dear #{username}

      Your account information was updated by an administrator.

      User name: #{username}
      Password: ****(no change)
      E-mail address: #{addr}

    MAIL_MSG

    stg = Settings.instance
    subject = "Updating account information for #{stg.value['title']}!"

    mailmgr = MailManager.new
    mailmgr.send_mail_withfooter(addr, subject, msg)
  end

  def readparam(params, key, defval)
    tmp = params[key] || [defval]
    tmp[0]
  end

  # メールアドレスの読み取り
  #
  # @param params パラメータハッシュオブジェクト
  def read_name_email(params)
    # @paramss = params
    @uid = readparam(params, 'uid', '0')
    @admin = readparam(params, 'adminusr', nil)
    @newnm = readparam(params, 'name', '1').strip
    @newem = readparam(params, 'email', '2').strip
    @ntfmail = readparam(params, 'notification', nil)
  end

  # すでに登録されてないかなどパラメータのチェック
  #
  # @param userdata ユーザー情報
  #
  # @return nil:success, otherwise:some message
  def checkindb(userdata)
    return '<span class="err">user information error...</span>' unless userdata

    return '<span class="err">name is already used ...</span>' \
      if userdata[0] != newnm && userdb.content.exist_name(newnm)

    return '<span class="err">e-mail address is already registered ...</span>' \
      if userdata[2] != newem && userdb.content.exist_email(newem)
  end

  # userdbの更新
  #
  # @return nil:success, otherwise:some message
  def update_userdb
    # UserIDの確認
    userdb = UserInfoFile.new
    userdb.read

    # [@names[id], @passwords[id], @emails[id]]
    userdata = userdb.content.findid(@uid)
    msg = checkindb(userdata)
    return msg if msg

    userdb.update_name(uid, newnm)
    # EmailAddressの再設定
    userdb.update_email(uid, newem)
    nil
  end

  def checkparam
    # 新EmailAddressの確認
    return '<span class="err">the name is too short!</span>' \
      if newnm.length < 4
    return '<span class="err">the e-mail address is too short!</span>' \
      if newem.length < 4
    return '<span class="err">the e-mail address does not have "@"!</span>' \
      if /.@.+\../ !~ newem
  end

  # パラメータのチェックと表示メッセージ作成
  #
  # @param userinfo ユーザー情報
  #
  # @return 表示用メッセージ
  def check_and_mkmsg
    msg = checkparam
    return msg if msg

    msg = update_userdb
    return msg if msg

    # メールの送信
    send_mail if ntfmail

    msg = <<-SUCCMSG.unindent
      a user(#{uid}) account was updated with information below.<br> \
      <table border='1'>
      <tr><td>uid</td><td>#{uid}</td></tr>
      <tr><td>admin?</td><td>#{admin}</td></tr>
      <tr><td>new name</td><td>#{newnm}</td></tr>
      <tr><td>new e-mail</td><td>#{newem}</td></tr>
      <tr><td>notification mail</td><td>#{ntfmail}</td></tr>
      </table>
    SUCCMSG
    msg
    # "<BR>debug: sessioneml:#{sessioneml} -> #{userinfo.user_email}"
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    read_name_email(params)
    msg = check_and_mkmsg(userinfo)

    CommonUI.html_head(header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    puts msg

    CommonUI.html_foot
  end
end
