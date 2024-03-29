# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'unindent'
# require './game/userinfo.rb'
require './util/myhtml.rb'
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
    tags = %w[wintitle title description mailaddress mailformat \
              domain base_url kento_url support_url tweetbtn sfenimage]
    isng = 0
    tags.each do |tg|
      unless params[tg]
        isng = 1
        @errmsg += "#{tg} is nil.<br>"
      end
    end
    if isng.zero?
      tags.each do |tg|
        @stg.value[tg] = params[tg][0]
      end
      write_settings
    else
      @errmsg += 'invalid parameters...<br>'
    end
  end

  # 設定ファイルへの書き込み
  def write_settings
    @stg.write
  rescue StandardError => e
    @errmsg += 'failed to update...<pre>'
    @errmsg += e.to_s
    @errmsg += '</pre>'
  end

  # 編集結果の表示
  def put_settings
    stg_elem = [
      { title: 'Window title',   eid: 'wintitle' },
      { title: 'Page title',     eid: 'title' },
      { title: 'Description',    eid: 'description' },
      { title: 'E-mail address', eid: 'mailaddress' },
      { title: 'E-mail format',  eid: 'mailformat' },
      { title: 'Domain',         eid: 'domain' },
      { title: 'Base URL',       eid: 'base_url' },
      { title: 'Kento URL',      eid: 'kento_url' },
      { title: 'Support URL',    eid: 'support_url' },
      { title: 'Tweet button',   eid: 'tweetbtn' },
      { title: 'sfenimage server', eid: 'sfenimage' }
    ]
    puts "<table align='center' border=1>"
    stg_elem.each do |elem|
      name = elem[:title]
      id = elem[:eid]
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
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    update_settings(params)

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    put_settings

    CommonUI.html_foot
  end
end
