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

  # メニュー部分の出力 ログイン前
  def self.HTMLmenu(title)
    index = File.basename($PROGRAM_NAME)
    sup = $stg.value['support_url']
    print <<-MENU.unindent
      <div align='center'>#{title}</div><HR>
      <div align='center' class='menubase'>&nbsp;
      <a class='menu' href='#{index}'> Entrance </a>&nbsp;
      <a class='menu' href='#{index}?signup'> Sign Up </a>&nbsp;
      <a class='menu' href='#{index}?login'> Log In </a>&nbsp;
      <a class='menu' href='#{sup}' target='_blank'> Support </a>&nbsp;
      </div><HR/>
      MENU
  end

  # メニュー部分の出力
  #
  # blogin ログイン中かどうか
  def self.HTMLmenuLogIn(title, blogin = true)
    return HTMLmenu(title) unless blogin

    index = File.basename($PROGRAM_NAME)
    sup = $stg.value['support_url']
    print <<-MENU_LOGGEDIN.unindent
      <div align='center'>#{title}</div><HR>
      <div align='center' class='menubase'>&nbsp;
      <a class='menu' href='#{index}'> Entrance </a>&nbsp;
      <a class='menu' href='#{index}?mypage'> My Page </a>&nbsp;
      <a class='menu' href='#{index}?searchform'> Search </a>&nbsp;
      <a class='menu' href='#{sup}' target='_blank'> Support </a>&nbsp;
      <a class='menu' href='#{index}?logout'> Log Out </a>&nbsp;
      </div><HR/>
      MENU_LOGGEDIN
  end

  # フッターの出力
  def self.HTMLfoot
    print "<HR><div align=right>&copy;ぢるっち 2017 with Ruby v#{RUBY_VERSION}" \
          '</div></BODY></HTML>'
  end
end
