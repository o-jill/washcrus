# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'erb'
require 'mail'
require 'unindent'

require './file/taikyokufile.rb'
require './file/userinfofile.rb'
require './util/mailmgr.rb'
require './util/settings.rb'
require './views/common_ui.rb'

#
# 退会画面
#
class UnsubscribeScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # @!attribute [r] em
  #   @return 入力メールアドレス
  attr_reader :em

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
    @em = params['unsubscribe'] || ['']
    @em = em[0].strip
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
  # @return '':メールアドレス一致, エラーメッセージ:不一致
  def check(email)
    return '' if em == email

    '<span class="err">e-mail address is not correct!</span>'
  end

  # 対局中かどうかの確認
  #
  # @param uid ユーザーID
  #
  # @return '':対局中なし, エラーメッセージ:対局中あり
  def playing?(uid)
    tkcdb = TaikyokuChuFile.new
    tkcdb.read
    return '' if tkcdb.finduid(uid).empty?

    '<span class="err">Please finish all your games at first.</span>'
  end

  # パラメータのチェックと表示メッセージ作成
  #
  # @param cgi CGIオブジェクト
  # @param userinfo ユーザー情報
  #
  # @return 表示用メッセージ
  def check_and_mkmsg(cgi, userinfo)
    uid = userinfo.user_id
    msg = playing?(uid)
    return msg unless msg.empty?

    msg = check(userinfo.user_email)
    return msg unless msg.empty?

    # msg = update_userdb(uid)
    # return msg if msg
    #
    # begin
    #   session = CGI::Session.new(
    #     cgi,
    #     'new_session' => false,
    #     'session_key' => '_washcrus_session',
    #     'tmpdir' => './tmp'
    #   )
    # rescue ArgumentError
    #   # session = nil
    #   return 'failed to find session.'
    #   # @log.debug("#{ae.message}, (#{ae.class})")
    # end

    # # sessioneml = userinfo.user_email
    # userinfo.user_email = newem
    # # sessionデータ更新
    # userinfo.hashsession.each { |ky, vl| session[ky] = vl }
    # session.update
    # session.close

    # メールの送信
    # send_mail(userinfo)

    'Your e-mail address was updated.<br>' \
    'an e-mail has been sent to your new address.' \
    "from [#{em}]"
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
