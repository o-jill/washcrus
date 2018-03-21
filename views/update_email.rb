# -*- encoding: utf-8 -*-

require 'rubygems'
require 'mail'
require 'unindent'

require './file/userinfofile.rb'
require './util/mailmgr.rb'
require './util/settings.rb'
require './views/common_ui.rb'

#
# EmailAddress変更画面
#
class UpdateEmailScreen
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
    addr = userinfo.user_email
    username = userinfo.user_name

    msg = <<-MAIL_MSG.unindent
      Dear #{username}

      Your E-mail address was updated.

      User name: #{username}
      Password: ****
      E-mail address: #{addr}

      MAIL_MSG
    msg += MailManager.footer

    stg = Settings.instance
    subject = "Updating e-mail address for #{stg.value['title']}!"

    mailmgr = MailManager.new
    mailmgr.send_mail(addr, subject, msg)
  end

  # パラメータのチェックと表示メッセージ作成
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  #
  # @return 表示用メッセージ
  def check_and_mkmsg(session, userinfo, params)
    newem1 = params['rnewemail'] || ['1']
    newem1 = newem1[0].strip
    newem2 = params['rnewemail2'] || ['2']
    newem2 = newem2[0].strip

    # 新EmailAddressの確認
    return '<span class="err">e-mail addresses are not same!</span>' \
      if newem1 != newem2
    return '<span class="err">the e-mail address is too short!</span>' \
      if newem1.length < 4

    uid = userinfo.user_id

    # UserIDの確認
    userdb = UserInfoFile.new
    userdb.read

    # [@names[id], @passwords[id], @emails[id]]
    userdata = userdb.content.findid(uid)
    return '<span class="err">user information error...</span>' unless userdata

    return '<span class="err">e-mail address is already registered ...</span>' \
      if userdb.content.exist_email(newem1)

    # EmailAddressの再設定
    userdb.update_email(uid, newem1)

    # sessioneml = userinfo.user_email
    userinfo.user_email = newem1
    # sessionデータ更新
    userinfo.hashsession.each { |ky, vl| session[ky] = vl }
    session.update

    # メールの送信
    send_mail(userinfo)

    'Your e-mail address was updated.<br>' \
    'a e-mail has been sent to your new address.'
    # "<BR>debug: sessioneml:#{sessioneml} -> #{userinfo.user_email}"
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(cgi, session, userinfo, params)
    return put_err_sreen("your log-in information is wrong ...\n") \
      if userinfo.invalid?

    msg = check_and_mkmsg(session, userinfo, params)

    header = cgi.header('charset' => 'UTF-8',
                        'Pragma' => 'no-cache',
                        'Cache-Control' => 'no-cache')

    header = header.gsub("\r\n", "\n")

    CommonUI.html_head(header)
    CommonUI.html_menu(userinfo)

    puts msg

    CommonUI.html_foot
  end
end
