# -*- encoding: utf-8 -*-

require 'rubygems'
# require 'unindent'

require './util/settings.rb'

#
# UI parts used in common
#
module CommonUI
  # HTMLヘッダ出力
  def self.HTMLHead(header, title)
    print header
    print <<-HEADER_TAG.unindent
      <HTML lang=ja>
      <HEAD>
       <TITLE>#{title}</TITLE>
       <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >
       <META name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
       <link rel='shortcut icon' href='./image/favicon.ico' />
       <link rel='stylesheet' type='text/css' href='./css/washcrus.css'>
      </HEAD>
      <BODY>
      HEADER_TAG
  end

  # HTMLヘッダ出力(no cookie)
  def self.HTMLHead2(title)
    print <<-HEADER2_TAG.unindent
      Content-Type: text/html; charset=UTF-8
      Set-Cookie: _washcrus_session=; expires=Thu, 01 Jan 1970 00:00:00 GMT
      Pragma: no-cache
      Cache-Control: no-cache
      Expires: Thu, 01 Jan 1970 00:00:00 GMT

      <HTML lang=ja>
      <HEAD>
       <TITLE>#{title}</TITLE>
       <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >
       <META name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
       <link rel='shortcut icon' href='./image/favicon.ico' />
       <link rel='stylesheet' type='text/css' href='./css/washcrus.css'>
      </HEAD>
      <BODY>
      HEADER2_TAG
  end

  # メニュー部分の出力
  #
  # @param title ページタイトル
  # @param userinfo ユーザ情報
  def self.HTMLmenu(title, userinfo = nil)
    index = File.basename($PROGRAM_NAME)
    sup = $stg.value['support_url']

    bsignup = userinfo.nil? || userinfo.invalid?
    return HTMLmenuSignUp(title, index, sup) if bsignup

    return HTMLmenuAdmin(title, index, sup) if userinfo.admin

    HTMLmenuLogIn(title, index, sup)
  end

  # メニュー部分の出力 ログイン前
  #
  # @param title ページタイトル
  # @param index CGI本体
  # @param sup   サポートページのURL
  def self.HTMLmenuSignUp(title, index, sup)
    print <<-MENU.unindent
      <div align='center' class='menubase'>
      <a class='menu' href='#{index}'> Entrance </a>
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
  def self.HTMLmenuLogIn(title, index, sup)
    print <<-MENU_LOGGEDIN.unindent
      <div align='center' class='menubase'>
      <a class='menu' href='#{index}'> Entrance </a>
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
  def self.HTMLmenuAdmin(title, index, sup)
    print <<-MENU_LOGGEDIN.unindent
      <div align='center' class='menubase'>
      <a class='menu' href='#{index}'> Entrance </a>
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

  def self.HTMLAdminMenu
    index = File.basename($PROGRAM_NAME)
    puts <<-ADMINMENU.unindent
      <div align='center' class='menubase'>
      <a class='menu' href='#{index}?adminsettings'> Settings </a>
      <a class='menu' href='#{index}?adminnews'> News </a>
      <a class='menu' href='#{index}?userlist'> Users </a>
      <a class='menu' href='#{index}?newgame'> New Game </a>
      <a class='menu' href='#{index}?adminmenu'> Version </a>
      </div><hr>
      ADMINMENU
  end

  # フッターの出力
  def self.HTMLfoot
    print "<HR><div align=right>&copy;ぢるっち 2017 with Ruby v#{RUBY_VERSION}" \
          '</div></BODY></HTML>'
  end
end
