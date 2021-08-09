# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'cgi'
require 'cgi/session'
require 'digest/sha2'
require 'unindent'
require './file/userinfofile.rb'
require './views/common_ui.rb'

#
# ログイン完了orログインエラー画面
#
class LoginCheckScreen
  # 初期化
  def initialize
    @errmsg = ''
    @userinfo = nil
    @userdata = {}
  end

  # パスワードのチェック
  #
  # @param pswd パスワード
  def check_pswd(pswd)
    @errmsg += 'wrong password ...<BR>' unless pswd && pswd.length >= 4
  end

  # メールアドレスのチェック
  #
  # @param email メールアドレス
  def check_email(email)
    @errmsg += 'wrong e-mail address ...<BR>' unless email && email.length >= 4
  end

  # データの存在確認
  #
  # @param pswd パスワード
  # @param email メールアドレス
  # @return パスワードかメールアドレスが空ならfalse
  def check_datalost(pswd, email)
    pswd && email
  end

  # メールアドレスとパスワードからユーザー情報の確認
  #
  # @param email メールアドレス
  # @param pswd パスワード
  # @return メールアドレスとパスワードが正しければtrue
  def correct_pswd?(email, pswd)
    userdb = UserInfoFile.new
    userdb.read

    # [id, @names[id], @passwords[id]]
    @userdata = userdb.content.findemail(email)

    return false unless @userdata

    dgpw = Digest::SHA256.hexdigest pswd

    if @errmsg.empty? && dgpw == @userdata[:pw]
      @userinfo = UserInfo.new(1, @userdata[:id], @userdata[:name], email)
      true
    else
      false
    end
  end

  # ログイン情報の確認
  #
  # @param params パラメータハッシュオブジェクト
  def check_login(params)
    pswd = params['sipassword']
    email = params['siemail']

    return @errmsg = 'data lost ...<BR>' unless check_datalost(pswd, email)

    pswd = pswd[0]
    check_pswd(pswd)

    email = email[0]
    check_email(email)

    @errmsg += 'e-mail address or password is wrong ...<BR>' \
      unless correct_pswd?(email, pswd)
  end

  # 新規セッションを張る
  #
  # @param cgi CGIオブジェクト
  def gen_new_session(cgi)
    # delete session if exist.
    begin
      session = CGI::Session.new(
        cgi,
        'new_session' => false,
        'session_key' => '_washcrus_session',
        'tmpdir' => './tmp'
      )
      session.close
      session.delete
    rescue ArgumentError
      session = nil
    end
    expire = Time.now + 2_592_000 # 30days
    session = CGI::Session.new(cgi,
                               'new_session' => true,
                               'session_key' => '_washcrus_session',
                               'tmpdir' => './tmp',
                               'session_expires' => expire)

    @userinfo.hashsession.each { |ky, vl| session[ky] = vl }

    session['session_expires'] = expire

    session.update
    session.close
  end

  # セッション情報の確認(二重ログイン防止)
  #
  # @param userinfo セッション情報
  # @param cgi CGIオブジェクト
  # @return ログイン出来てるときtrue
  def check_session_params(userinfo, cgi)
    unless userinfo.invalid?
      @errmsg = 'you already logged in!'

      return true
    end

    check_login(cgi.params)
    if @errmsg.empty?
      gen_new_session(cgi)

      return true
    end

    false
  end

  # 自動遷移メッセージと同スクリプトの文字列の生成
  #
  # @param gid 対局ID
  #
  # @return 自動遷移メッセージと同スクリプトの文字列
  def automove2agame(gid)
    url = "./index.rb?game/#{gid}"
    '3秒後に自動的に移動します。(移動しない場合は↑をクリック)' \
    "<script type='text/javascript'>" \
    'function automove() {' \
    "setTimeout(function() {location.href = '#{url}';}, 3000);}" \
    'automove();</script>'
  end

  # game画面からの遷移でログインだったらゲーム画面に案内
  #
  # @param params パラメータハッシュオブジェクト
  #
  # @return 案内タグ文字列
  def gotogamepage(params)
    gid = params['gameid'][0]
    return unless gid
    return if gid.empty?
    "<div align='center'>" \
    "<a href='index.rb?game/#{gid}'>対局(#{gid})へ</a><br>" \
    "#{automove2agame(gid)}</div>"
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param cgi CGIオブジェクト
  def show(userinfo, cgi)
    check_session_params(userinfo, cgi)

    header = cgi.header('charset' => 'UTF-8',
                        'Pragma' => 'no-cache',
                        'Cache-Control' => 'no-cache')

    header = header.gsub("\r\n", "\n")

    CommonUI.html_head(header)
    CommonUI.html_menu(@userinfo)

    if @userinfo
      print <<-LOGINMSG.unindent
        <div align='center'>
        Logged in successfully.<BR>
        username:#{@userinfo.user_name}<BR>
        password:****<BR>
        email address:#{@userinfo.user_email}<BR>
        </div>
      LOGINMSG
    else
      # エラー
      puts "<div class='err'>Unfortunately failed ...<BR>#{@errmsg}</div>"
    end

    puts gotogamepage(cgi.params)

    CommonUI.html_foot
  end
end
