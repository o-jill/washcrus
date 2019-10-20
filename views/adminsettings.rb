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

  def show_elem_input(name, id, stg)
    puts <<-ROW_TEXT.unindent
      <tr>
       <td>#{name}</td>
       <td><input name='#{id}' id='#{id}' type=text size=50 value='#{stg.value[id]}'></td>
      </tr>
    ROW_TEXT
  end

  def show_elem_radio(name, id, options, stg)
    msg = "<tr>\n <td>#{name}</td>\n <td>\n"
    options.each do |opt|
      msg += "  <label><input name='#{id}' type='radio' value='#{opt}' " \
             "#{stg.value[id] == opt ? 'checked' : ''}>#{opt}</label>\n"
    end
    puts msg + " </td>\n</tr>\n"
  end

  # フォームの出力
  def show_settingsform
    scriptname = File.basename($PROGRAM_NAME)
    stg = Settings.instance
    stg_elem = [
      { title: 'Window title',   eid: 'wintitle', type: 'input'},
      { title: 'Page title',     eid: 'title', type: 'input'},
      { title: 'E-mail address', eid: 'mailaddress', type: 'input'},
      { title: 'E-mail format',  eid: 'mailformat',
        type: 'radio', options: ['plaintext', 'html']},
      { title: 'Domain',         eid: 'domain', type: 'input'},
      { title: 'Base URL',       eid: 'base_url', type: 'input'},
      { title: 'Support URL',    eid: 'support_url', type: 'input'}
    ]
    print <<-FORM_SETTINGS_HEAD.unindent
      <form action='#{scriptname}?adminsavesettings' method=post name='adminsettings'>
      <table align='center' border=1>
    FORM_SETTINGS_HEAD
    stg_elem.each do |elem|
      name = elem[:title]
      id = elem[:eid]
      type = elem[:type]
      if (type == 'radio')
        show_elem_radio(name, id, elem[:options], stg)
      else
        show_elem_input(name, id, stg)
      end
    end
    puts <<-FORM_SETTINGS_TAIL.unindent
      <tr>
       <td colspan=2>
        <input type='submit' value='Save' class='inpform'>
        <input type='button' value='Current URL' class='inpform' onclick="use_url();">
       </td>
      </tr>
      <tr><td colspan='2' id='errmsg'></td></tr>
      </table>
      </form>
      <script type="text/javascript" src="./js/adminsettings.js"></script>
    FORM_SETTINGS_TAIL
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  def show(userinfo)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    CommonUI.html_adminmenu

    show_settingsform

    CommonUI.html_foot
  end
end
