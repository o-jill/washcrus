# -*- encoding: utf-8 -*-

require 'rubygems'
# require 'unindent'
# require './game/userinfo.rb'
require './views/common_ui.rb'
require './util/settings.rb'

#
# 登録画面
#
class SignupScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # 入力フォームの表示
  def show_tableform
    print <<-TABLE_FORM.unindent
    <FORM action='#{File.basename($PROGRAM_NAME)}?register' method=post name='signup'>
    <TABLE align='center' class='inpform'>
    <TR id='trname'>
     <TD>name</TD>
     <TD><INPUT name='rname' id='rname' type='text' size='25' class='inpform' required></TD>
    </TR>
    <TR id='tremail'>
     <TD>e-mail</TD>
     <TD><INPUT name='remail' id='remail' type='email' size='25' class='inpform' required></TD>
    </TR>
    <TR id='tremail2'>
     <TD>e-mail(again)</TD>
     <TD><INPUT name='remail2' id='remail2' type='email' size='25' class='inpform' required></TD>
    </TR>
    <TR id='trpassword'>
     <TD>password</TD>
     <TD><INPUT name='rpassword' id='rpassword' type='password' size='25' class='inpform' required></TD>
    </TR>
    <TR id='trpassword2'>
     <TD>password(again)</TD>
     <TD><INPUT name='rpassword2' id='rpassword2' type='password' size='25' class='inpform' required></TD>
    </TR>
    <TR>
     <TD colspan=2><input type='button' value='Submit' onClick='check_form();' class='inpform'>
       &nbsp;<input type='reset' class='inpform'></TD>
    </TR>
    <TR>
     <TD colspan=2 id='errmsg'></TD>
    </TR>
    </TABLE></FORM>
    TABLE_FORM
  end

  def show_info
    stg = Settings.instance
    mailaddr = stg.value['mailaddress']
    print <<-INFOMSG.unindent
    <div class="signupinfo">
      注意：携帯キャリア(docomo, au, softbankなど)のメールを登録される方へ<BR>
      受信拒否設定をしている方は#{mailaddr}からの受信が出来るようにしてから登録作業をしてください。
    </div>
    INFOMSG
  end

  # 画面の表示
  def show
    CommonUI.html_head(@header)
    CommonUI.html_menu

    show_info

    puts "<script type='text/javascript' src='./js/signup.js' defer></script>"

    show_tableform

    CommonUI.html_foot
  end
end
