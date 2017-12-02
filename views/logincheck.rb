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
    @errmsg += 'wrong password ...<BR>' if pswd.nil? || pswd.length < 4
  end

  # メールアドレスのチェック
  #
  # @param email メールアドレス
  def check_email(email)
    @errmsg += 'wrong e-mail address ...<BR>' if email.nil? || email.length < 4
  end

  # データの存在確認
  #
  # @param pswd パスワード
  # @param email メールアドレス
  # @return パスワードかメールアドレスが空ならtrue
  def check_datalost(pswd, email)
    pswd.nil? || pswd.length.zero? || email.nil? || email.length.zero?
  end

  # メールアドレスとパスワードからユーザー情報の確認
  #
  # @param email メールアドレス
  # @param pswd パスワード
  # @return メールアドレスとパスワードが正しければtrue
  def correct_pswd?(email, pswd)
    userdb = UserInfoFile.new
    userdb.read
    @userdata = userdb.findemail(email) # [id, @names[id], @passwords[id]]

    return false if @userdata.nil?

    dgpw = Digest::SHA256.hexdigest pswd

    if @errmsg.length.zero? && dgpw == @userdata[2]
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

    return @errmsg = 'data lost ...<BR>' if check_datalost(pswd, email)

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

    @userinfo.hashsession.each { |k, v| session[k] = v }

    session['session_expires'] = expire

    session.update
  end

  # セッション情報の確認(二重ログイン防止)
  #
  # @param session セッション情報
  # @param cgi CGIオブジェクト
  # @return ログイン出来てるときtrue
  def check_session_params(session, cgi)
    if session.nil?
      check_login(cgi.params)
      if @errmsg.length.zero?
        gen_new_session(cgi)

        return true
      end
    else
      @errmsg = 'you already logged in!'

      return true
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

    if @userinfo.nil?
      # エラー
      puts "<div class='err'>Unfortunately failed ...<BR>#{@errmsg}</div>"
    else
      print <<-LOGINMSG.unindent
        <div align='center'>
        Logged in successfully.<BR>
        username:#{@userinfo.user_name}<BR>
        password:****<BR>
        email address:#{@userinfo.user_email}<BR>
        </div>
        LOGINMSG
    end

    CommonUI.html_foot
  end
end
