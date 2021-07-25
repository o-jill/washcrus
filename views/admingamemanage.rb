# -*- encoding: utf-8 -*-
# frozen_string_literal: true

# require 'rubygems'
require 'unindent'
# require 'redcarpet'

require './file/pathlist.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './views/common_ui.rb'

#
# 対局編集画面
#
class AdminGameManageScreen
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
  #
  # @param uid User ID
  def check_admin(uid)
    ac = AdminConfigFile.new
    ac.read
    ac.exist?(uid)
  end

  # 編集欄の出力
  def put_edit_game
    scriptname = File.basename($PROGRAM_NAME)
    puts <<-EDITFORM.unindent
      <script type='text/javascript' src='./js/admingamemanage.js'></script>
      <form action='#{scriptname}?admingamemanageupdate' method=post name='admingamectrl'>
      <table align='center'>
      <tr><td class='inpform'>Game ID</td>
       <td><input class='inpform' id='gameid' name='gameid'></td>
       <td rows='3' id='matchinfo'>match information will be here.</td></tr>
      <tr><td class='inpform'>Result</td><td class='inpform'>
       <select name='result' class='inpform'><option value='d'>引き分け</option>
        <option value='fb'>先手勝ち</option>
        <option value='fw'>後手勝ち</option></select>
       <button class='inpform' onclick='return retrieveGame();'>確認--&gt;</button>
      </td></tr>
      <tr><td colspan='2'><input class='inpform' type=submit></td></tr>
      </table>
      </form>
    EDITFORM
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  def show(userinfo)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    put_edit_game

    CommonUI.html_foot
  end
end

#
# ハッシュ無しはユーザの選択
# ハッシュアリはデータの編集。
# 更新は別の画面で。
#
