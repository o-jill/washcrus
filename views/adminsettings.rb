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
    stg_elem = [
      ['Window title', 'wintitle'],
      ['Page title',   'title'],
      ['Domain',       'domain'],
      ['Base URL',     'base_url'],
      ['Support URL',  'support_url']
    ]
    print <<-FORM_SETTINGS_HEAD.unindent
      <form action='#{scriptname}?adminsavesettings' method=post name='adminsettings'>
      <table align='center' border=1>
      FORM_SETTINGS_HEAD
    stg_elem.each do |elem|
      name = elem[0]
      id = elem[1]
      puts <<-ROW_TEXT.unindent
        <tr>
         <td>#{name}</td>
         <td><input name='#{id}' id='#{id}' type=text size=50 value='#{stg.value[id]}'></td>
        </tr>
       ROW_TEXT
    end
    puts <<-FORM_SETTINGS_TAIL.unindent
      <tr>
       <td colspan=2>
        <input type='submit' value='Save' class='inpform'>
       </td>
      </tr>
      <tr><td colspan='2' id='errmsg'></td></tr>
      </table>
      </form>
      FORM_SETTINGS_TAIL
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  def show(userinfo)
    CommonUI::html_head(@header)
    CommonUI::html_menu(userinfo)

    CommonUI::html_adminmenu()

    show_settingsform

    CommonUI::html_foot()
  end
end
