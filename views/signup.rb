# -*- encoding: utf-8 -*-

require 'rubygems'
# require 'unindent'
# require './game/userinfo.rb'
require './views/common_ui.rb'

#
# 登録画面
#
class SignupScreen
  # 初期化
  #
  # @param header htmlヘッダ
  # @param title  ページタイトル
  # @param name   ページヘッダタイトル
  def initialize(header, title, name)
    @header = header
    @title = title
    @name = name
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
     <TD colspan=2><input type='button' value='submit' onClick='check_form();' class='inpform'>&nbsp;<input type='reset' class='inpform'></TD>
    </TR>
    <TR>
     <TD colspan=2 id='errmsg'></TD>
    </TR>
    </TABLE></FORM>
    TABLE_FORM
  end

  # 画面の表示
  def show
    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(@name)

    puts "<script type='text/javascript' src='./js/signup.js' defer></script>"

    show_tableform

    CommonUI::HTMLfoot()
  end
end
