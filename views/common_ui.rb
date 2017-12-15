# -*- encoding: utf-8 -*-

require 'rubygems'
# require 'unindent'

require './util/settings.rb'

#
# UI parts used in common
#
module CommonUI
  # HTMLヘッダ出力
  #
  # @param header HTMLヘッダ
  def self.html_head(header)
    print header
    stg = Settings.instance
    title = stg.value['wintitle']
    print <<-HEADER_TAG.unindent
      <HTML lang=ja>
      <HEAD>
       <title>#{title}</title>
       <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >
       <META name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
       <link rel='shortcut icon' href='./image/favicon.ico' />
       <link rel='stylesheet' type='text/css' href='./css/washcrus.v012.css'>
      </HEAD>
      <BODY>
      HEADER_TAG
  end

  # HTMLヘッダ出力(no cookie)
  def self.html_head2
    stg = Settings.instance
    title = stg.value['wintitle']
    print <<-HEADER2_TAG.unindent
      Content-Type: text/html; charset=UTF-8
      Set-Cookie: _washcrus_session=; expires=Thu, 01 Jan 1970 00:00:00 GMT
      Pragma: no-cache
      Cache-Control: no-cache
      Expires: Thu, 01 Jan 1970 00:00:00 GMT

      <HTML lang=ja>
      <HEAD>
       <title>#{title}</title>
       <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >
       <META name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
       <link rel='shortcut icon' href='./image/favicon.ico' />
       <link rel='stylesheet' type='text/css' href='./css/washcrus.v012.css'>
      </HEAD>
      <BODY>
      HEADER2_TAG
  end

  # メニュー部分の出力
  #
  # @param userinfo ユーザ情報
  def self.html_menu(userinfo = nil)
    index = File.basename($PROGRAM_NAME)
    stg = Settings.instance
    sup = stg.value['support_url']
    title = stg.value['title']

    bsignup = userinfo.nil? || userinfo.invalid?
    return html_menu_signup(title, index, sup) if bsignup

    return html_menu_admin(title, index, sup) if userinfo.admin

    html_menu_login(title, index, sup)
  end

  # メニュー部分の出力 ログイン前
  #
  # @param title ページタイトル
  # @param index CGI本体
  # @param sup   サポートページのURL
  def self.html_menu_signup(title, index, sup)
    print <<-MENU.unindent
      <div align='center' class='menubase'>
      <a class='menu' href='#{index}'> Top </a>
      <a class='menu' href='#{index}?news'> News </a>
      <a class='menu' href='#{index}?signup'> Sign Up </a>
      <a class='menu' href='#{index}?login'> Log In </a>
      <a class='menu' href='#{sup}' target='_blank'> Support </a>
      </div><hr>
      <div align='center'>#{title}</div><hr>
      MENU
  end

  # メニュー部分の出力
  #
  # @param title ページタイトル
  # @param index CGI本体
  # @param sup   サポートページのURL
  def self.html_menu_login(title, index, sup)
    print <<-MENU_LOGGEDIN.unindent
      <div class='menubase'>
      <a class='menu' href='#{index}'> Top </a>
      <a class='menu' href='#{index}?news'> News </a>
      <a class='menu' href='#{index}?mypage'> My Page </a>
      <a class='menu' href='#{index}?matchlist'> Watch </a>
      <a class='menu' href='#{index}?searchform'> Search </a>
      <a class='menu' href='#{sup}' target='_blank'> Support </a>
      <a class='menu' href='#{index}?logout'> Log Out </a>
      </div><hr>
      <div align='center'>#{title}</div><hr>
      MENU_LOGGEDIN
  end

  # メニュー部分の出力
  #
  # @param title ページタイトル
  # @param index CGI本体
  # @param sup   サポートページのURL
  def self.html_menu_admin(title, index, sup)
    print <<-MENU_LOGGEDIN.unindent
      <div class='menubase'>
      <a class='menu' href='#{index}'> Top </a>
      <a class='menu' href='#{index}?news'> News </a>
      <a class='menu' href='#{index}?mypage'> My Page </a>
      <a class='menu' href='#{index}?matchlist'> Watch </a>
      <a class='menu' href='#{index}?searchform'> Search </a>
      <a class='menu' href='#{sup}' target='_blank'> Support </a>
      <a class='menu' href='#{index}?adminmenu'> Administration </a>
      <a class='menu' href='#{index}?logout'> Log Out </a>
      </div><hr>
      <div align='center'>#{title}</div><hr>
      MENU_LOGGEDIN
  end

  # Administrationメニュー
  def self.html_adminmenu
    index = File.basename($PROGRAM_NAME)
    puts <<-ADMINMENU.unindent
      <div class='menubase'>
      <a class='menu' href='#{index}?adminsettings'> Settings </a>
      <a class='menu' href='#{index}?adminnews'> News </a>
      <a class='menu' href='#{index}?adminsignature'> Signature </a>
      <a class='menu' href='#{index}?userlist'> Users </a>
      <a class='menu' href='#{index}?newgame'> New Game </a>
      <a class='menu' href='#{index}?adminmenu'> Version </a>
      </div><hr>
      ADMINMENU
  end

  # フッターの出力
  def self.html_foot
    print "<HR><div align=right>&copy;ぢるっち 2017 with Ruby v#{RUBY_VERSION}" \
          '</div></BODY></HTML>'
  end

  # 手番文字をわかりやすい言葉に変換
  #
  # @param trn 手番文字
  # @return 手番情報文字列
  def self.turn2str(trn)
    tbl = [%w[b 先手番], %w[w 後手番], %w[fb 先手勝ち], %w[fw 後手勝ち], %[d 引き分け]]
    tbl.each do |elem|
      return elem[1] if trn == elem[0]
    end
    'エラー'
  end
end
