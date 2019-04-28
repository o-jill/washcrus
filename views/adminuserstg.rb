# -*- encoding: utf-8 -*-

# require 'rubygems'
require 'unindent'
require 'redcarpet'

require './file/pathlist.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './views/common_ui.rb'

#
# User編集画面
#
class AdminUserStgScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header

    userdb = UserInfoFile.new
    userdb.read
    @udb = userdb.content
  end

  # check and set if administrator.
  def check_admin(uid)
    ac = AdminConfigFile.new
    ac.read
    ac.exist?(uid)
  end

  # 編集欄の出力
  def put_edit_user(userhash)
    usrdata = @udb.findid(userhash) # [name:, pw:, email:]
    if usrdata
      msg = <<-EDITFORM.unindent
      <form action="index.rb?adminuserstgupdate" method="post"><table>
      <tr><th>userid</th>
       <td><label><input type='checkbox' id='adminusr' name='adminusr' #{check_admin(userhash) ? 'checked' : ''}>admin?</label>
      &nbsp;<input id='uid' name='uid' value='#{userhash}' readonly ></td></tr>
      <tr><th>name</th>
      <td><input id='name' name='name' value='#{usrdata[:name]}' size='20' class='inpform' required></label></td></tr>
      <tr><th>pw</th><td>#{usrdata[:pw]}</td></tr>
      <tr><th>e-mail</th>
      <td><input id='email' name='email' value='#{usrdata[:email]}' type='email' size='20' class='inpform' required></label></td></tr>
      <tr><td><input type="submit" class="inpform"></td>
      <td><label><input type="checkbox" id="ntfmail" name="notification">notification mail</label></td></tr>
      </table></form>
      EDITFORM
    else
      @errmsg = "user's id is wrong ...<BR>\n"
      msg = @errmsg
    end

    puts "<div align='center'>#{msg}</div>"
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  def show(userhash, userinfo)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    puts <<-ADMIN_SEL_USR.unindent
      <script>
      function admin_sel_usr() {
        var elm = document.getElementById('suserid');
        var url = 'index.rb?adminuserstg/' + elm.value;
        window.location.href = url;
      }
      </script>
    ADMIN_SEL_USR

    puts "<div align='center'>Users(#{userhash}):"
    puts @udb.to_select_id_name('suserid', 'suserid', 'inpform', '')
    puts '<button onclick="admin_sel_usr();" class="inpform">edit</button>' \
         '</div><hr>'

    put_edit_user(userhash)

    CommonUI.html_foot
  end
end

#
# ハッシュ無しはユーザの選択
# ハッシュアリはデータの編集。
# 更新は別の画面で。
#
