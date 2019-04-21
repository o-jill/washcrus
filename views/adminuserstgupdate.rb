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

  # エラー画面の表示
  #
  # @param errmsg エラーメッセージ
  def put_err_sreen(errmsg)
    CommonUI.html_head(@header)
    CommonUI.html_menu
    puts errmsg
    CommonUI.html_foot
  end

  # 登録  #
  # @param userinfo ユーザー情報
  def send_mail(userinfo)
    addr = @newem
    username = @newnm

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

  # メールアドレスの読み取り
  #
  # @param params パラメータハッシュオブジェクト
  def read_name_email(params)
    @paramss = params
    @uid = params['uid'] || ['0']
    @uid = @uid[0]
    @admin = params['adminusr']
    @admin = @admin[0]
    @newnm = params['name'] || ['1']
    @newnm = @newnm[0].strip
    @newem = params['email'] || ['2']
    @newem = @newem[0].strip
    @ntfmail = params['notification']
    @ntfmail = @ntfmail[0]
  end

  # userdbの更新
  #
  # @param uid ユーザーID
  #
  # @return nil:success, otherwise:some message
  def update_userdb
    # UserIDの確認
    userdb = UserInfoFile.new
    userdb.read

    # [@names[id], @passwords[id], @emails[id]]
    userdata = userdb.content.findid(@uid)
    return '<span class="err">user information error...</span>' unless userdata

    return '<span class="err">name is already used ...</span>' \
      if userdata[0] != @newnm && userdb.content.exist_name(@newnm)

    return '<span class="err">e-mail address is already registered ...</span>' \
      if userdata[2] != @newem && userdb.content.exist_email(@newem)

    userdb.update_name(@uid, @newnm)
    # EmailAddressの再設定
    userdb.update_email(@uid, @newem)
    nil
  end

  # パラメータのチェックと表示メッセージ作成
  #
  # @param userinfo ユーザー情報
  #
  # @return 表示用メッセージ
  def check_and_mkmsg(userinfo)
    # 新EmailAddressの確認
    return '<span class="err">the name is too short!</span>' \
      if @newnm.length < 4
    return '<span class="err">the e-mail address is too short!</span>' \
      if @newem.length < 4
    return '<span class="err">the e-mail address does not have "@"!</span>' \
      if /.@.+\../ !~ @newem

    # uid = userinfo.user_id

    msg = update_userdb
    return msg if msg

    # メールの送信
    send_mail(userinfo) if @ntfmail

    msg = <<-SUCCMSG
      a user(#{@uid}) account was updated with information below.<br> \
      <table border='1'>
      <tr><td>uid</td><td>#{@uid}</td></tr>
      <tr><td>admin?</td><td>#{@admin}</td></tr>
      <tr><td>new name</td><td>#{@newnm}</td></tr>
      <tr><td>new e-mail</td><td>#{@newem}</td></tr>
      <tr><td>notification mail</td><td>#{@ntfmail}</td></tr>
      </table>
      SUCCMSG
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

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    puts msg

    CommonUI.html_foot
  end
end
