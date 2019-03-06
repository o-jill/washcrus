# -*- encoding: utf-8 -*-

require 'rubygems'
# require 'unindent'

require './game/userinfo.rb'
require './views/common_ui.rb'

# ログイン画面
class LoginScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # ログインフォームの表示
  def put_login_form
    print <<-TABLE_FORM.unindent
      <FORM action='index.rb?logincheck' method=post name='signin'>
      <TABLE align='center' class='inpform'>
      <CAPTION>Log in</CAPTION>
      <TR id='siemail'>
       <TD>e-mail</TD>
       <TD><INPUT name='siemail' id='siemail' type='email' size='20' class='inpform' required></TD>
      </TR>
      <TR id='sipassword'>
       <TD>password</TD>
       <TD><INPUT name='sipassword' id='sipassword' type='password' size='20' class='inpform' required></TD>
      </TR>
      <TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>
      <TR>
       <TD><input type='reset' class='inpform'></TD>
       <TD><input style='width:100%' type='submit' class='inpform'></TD>
      </TR>
      </TABLE></FORM>
      <style>
      .pwreset {
        width: 40vw;
        height: 1em;
        overflow: hidden;
        border: solid 1px black;
      }
      .pwreset:hover {
        height: 6em;
      }
      </style>
      <div align='center'>
      <div align='center' class=pwreset>
      パスワードを忘れた？<br><br>パスワードのリセット<br>
      <form action='index.rb?resetpw' method=post name='pwreset'>
      <input name='premail' id='premail' type='email' size='20' required placeholder='登録済みメールアドレス'>
      <input type='submit'>
      </form>
      </div>
      </div>
    TABLE_FORM
  end

  # ログイン済みの表示
  def put_login_form_err
    print "<div class='err'>you already logged in!</div>"
  end

  #
  # ログイン画面
  #
  # @param userinfo ユーザ情報
  def show(userinfo)
    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    if userinfo.invalid?
      put_login_form
    else
      put_login_form_err
    end

    CommonUI.html_foot
  end
end
