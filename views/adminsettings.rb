# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require './game/userinfo.rb'
require './util/settings.rb'
require './views/common_ui.rb'

#
# 設定変更画面
#
class AdminSettingsScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # フォームの出力
  def show_settingsform
    scriptname = File.basename($PROGRAM_NAME)
    stg = Settings.instance
    print <<-FORM_SETTINGS.unindent
      <form action='#{scriptname}?adminsavesettings' method=post name='adminsettings'>
      <table align='center'>
       <tr>
        <td>Title</td>
        <td><input name='title' id='title' type=text size=50 value='#{stg.value['title']}'></td>
       </tr>
       <tr>
        <td>Domain</td>
        <td><input name='domain' id='domain' type=text size=50 value='#{stg.value['domain']}'></td>
       </tr>
       <tr>
        <td>Base URL</td>
        <td><input name='base_url' id='base_url' type=text size=50 value='#{stg.value['base_url']}'></td>
       </tr>
       <tr>
        <td>Support URL</td>
        <td><input name='support_url' id='support_url' type=text size=50 value='#{stg.value['support_url']}'></td>
       </tr>
       <tr>
        <td colspan=2>
         <input type='button' value='Save' class='inpform' onclick='check__form();'>&nbsp;
        </td>
       </tr>
       <tr><td colspan='2' id='errmsg'></td></tr>
      </table>
      </form>
      FORM_SETTINGS
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  def show(userinfo)
    CommonUI::HTMLHead(@header)
    CommonUI::HTMLmenu(userinfo)

    CommonUI::HTMLAdminMenu()

    show_settingsform

    CommonUI::HTMLfoot()
  end
end
