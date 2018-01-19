# -*- encoding: utf-8 -*-

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
    @userdata = []
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

    if @errmsg.empty? && dgpw == @userdata[2]
      @userinfo = UserInfo.new(1, @userdata[0], @userdata[1], email)
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
    expire = Time.now + 2_592_000 # 30days
    session = CGI::Session.new(cgi,
                               'new_session' => true,
                               'session_key' => '_washcrus_session',
                               'tmpdir' => './tmp',
                               'session_expires' => expire)

    @userinfo.hashsession.each { |ky, vl| session[ky] = vl }

    session['session_expires'] = expire

    session.update
  end

  # セッション情報の確認(二重ログイン防止)
  #
  # @param session セッション情報
  # @param cgi CGIオブジェクト
  # @return ログイン出来てるときtrue
  def check_session_params(session, cgi)
    if session
      @errmsg = 'you already logged in!'

      return true
    else
      check_login(cgi.params)
      if @errmsg.empty?
        gen_new_session(cgi)

        return true
      end
    end

    false
  end

  # 画面の表示
  #
  # @param session セッション情報
  # @param cgi CGIオブジェクト
  def show(session, cgi)
    check_session_params(session, cgi)

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

    CommonUI.html_foot
  end
end
