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
# EmailAddress変更画面
#
class UpdateEmailScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # @!attribute [r] newem
  #   @return 新しいメールアドレス
  # @!attribute [r] newemagain
  #   @return 新しいメールアドレス再
  attr_reader :newem, :newemagain

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

    msg = ERB.new(
      File.read('./mail/updateemail.erb', encoding: 'utf-8')
    ).result(binding)

    stg = Settings.instance
    subject = "Updating e-mail address for #{stg.value['title']}!"

    mailmgr = MailManager.new
    mailmgr.send_mail_withfooter(addr, subject, msg)
  end

  # メールアドレスの読み取り
  #
  # @param params パラメータハッシュオブジェクト
  def reademail(params)
    @newem = params['rnewemail'] || ['1']
    @newem = newem[0].strip
    @newemagain = params['rnewemail2'] || ['2']
    @newemagain = newemagain[0].strip
  end

  # userdbの更新
  #
  # @param uid ユーザーID
  #
  # @return nil:success, otherwise:some message
  def update_userdb(uid)
    # UserIDの確認
    userdb = UserInfoFile.new

    # EmailAddressの再設定
    userdb.update_email(uid, newem)
  end

  # 新EmailAddressの確認
  #
  # @return '':正常, エラーメッセージ:エラーあり
  def check
    return '<span class="err">e-mail addresses are not same!</span>' \
      if newem != newemagain
    return '<span class="err">the e-mail address is too short!</span>' \
      if newem.length < 4
    return '<span class="err">the e-mail address does not have "@"!</span>' \
      if /.@.+\../ !~ newem
    ''
  end

  # パラメータのチェックと表示メッセージ作成
  #
  # @param cgi CGIオブジェクト
  # @param userinfo ユーザー情報
  #
  # @return 表示用メッセージ
  def check_and_mkmsg(cgi, userinfo)
    msg = check
    return msg unless msg.empty?

    uid = userinfo.user_id

    msg = update_userdb(uid)
    return msg if msg

    begin
      session = CGI::Session.new(
        cgi,
        'new_session' => false,
        'tmpdir' => './tmp'
      )
    rescue ArgumentError
      # session = nil
      return 'failed to find session.'
      # @log.debug("#{ae.message}, (#{ae.class})")
    end

    # sessioneml = userinfo.user_email
    userinfo.user_email = newem
    # sessionデータ更新
    userinfo.hashsession.each { |ky, vl| session[ky] = vl }
    session.update
    session.close

    # メールの送信
    send_mail(userinfo)

    'Your e-mail address was updated.<br>' \
    'an e-mail has been sent to your new address.'
    # "<BR>debug: sessioneml:#{sessioneml} -> #{userinfo.user_email}"
  end

  # 画面の表示
  #
  # @param cgi CGIオブジェクト
  # @param session セッション情報
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(cgi, userinfo, params)
    return put_err_sreen("your log-in information is wrong ...\n") \
      if userinfo.invalid?

    reademail(params)
    msg = check_and_mkmsg(cgi, userinfo)

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
