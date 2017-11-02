# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
# require './game/userinfo.rb'
require './util/settings.rb'
require './views/common_ui.rb'

#
# settings変更結果画面
#
class AdminSaveSettingsScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
    @errmsg = ''
    @stg = Settings.instance
  end

  # 設定ファイルの更新
  #
  # @param params パラメータハッシュオブジェクト
  def update_settings(params)
    tags = %w[wintitle title domain base_url support_url]
    isng = 0
    tags.each do |t|
      if params[t].nil?
        isng = 1
        @errmsg += "#{t} is nil.<br>"
      end
    end
    if isng.zero?
      tags.each do |t|
        @stg.value[t] = params[t][0]
      end
      write_settings
    else
      @errmsg += 'invalid parameters...<br>'
    end
  end

  # 設定ファイルへの書き込み
  def write_settings
    @stg.write
  rescue => e
    @errmsg += 'failed to update...<pre>'
    @errmsg += e.to_s
    @errmsg += '</pre>'
  end

  # 編集結果の表示
  def put_settings
    stg_elem = [
      ['Window title', 'wintitle'],
      ['Page title',   'title'],
      ['Domain',       'domain'],
      ['Base URL',     'base_url'],
      ['Support URL',  'support_url']
    ]
    puts "<table align='center' border=1>"
    stg_elem.each do |elem|
      name = elem[0]
      id = elem[1]
      puts <<-ROW_TEXT.unindent
        <tr>
         <td>#{name}</td>
         <td><input name='#{id}' id='#{id}' type=text size=50 value='#{@stg.value[id]}'></td>
        </tr>
        ROW_TEXT
    end
    puts <<-SETTINGS_INFO.unindent
       <tr><td colspan='2' id='errmsg'>#{@errmsg}</td></tr>
      </table>
      SETTINGS_INFO
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return puts "Content-Type: text/plain;\n\nERR_NOT_ADMIN" \
        unless userinfo.admin

    update_settings(params)

    CommonUI::html_head(@header)
    CommonUI::html_menu(userinfo)
    CommonUI::html_adminmenu()

    put_settings

    CommonUI::html_foot()
  end
end
