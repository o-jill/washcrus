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

  # 編集欄の出力
  def put_edit_user(userhash)
    usrdata = @udb.findid(userhash) # [name, pw, email]
    unless usrdata
      @errmsg = "user's id is wrong ...<BR>\n"
      msg = @errmsg;
    else
      # userdataa.unshift(userhash) # [id, name, pw, email]
      msg = '<form action="index.rb?adminuserstgupdate" method="post"><table>' \
      "<tr><th>userid</th><td><label><input type='checkbox' id='adminusr' name='adminusr'>[N/A]admin?</label>" \
      "&nbsp;<input id='uid' name='uid' value='#{userhash}' readonly ></td></tr>" \
      "<tr><th>name</th><td><input id='name' name='name' value='#{usrdata[0]}' size='20' class='inpform' required></label></td></tr>" \
      "<tr><th>pw</th><td>#{usrdata[1]}</td></tr>" \
      "<tr><th>e-mail</th><td><input id='email' name='email' value='#{usrdata[2]}' type='email' size='20' class='inpform' required></label></td></tr>" \
      '<tr><td><input type="submit" class="inpform"></td>' \
      '<td><label><input type="checkbox" id="ntfmail" name="notification">notification mail</label></td></tr></table></form>'
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
# ハッシュ無しはゆーサーの選択
#　ハッシュアリはデータの編集。
#　更新は別の画面で。
#
