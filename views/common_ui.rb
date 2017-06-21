#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

#
# UI parts used in common
#
module CommonUI
  # HTMLヘッダ出力
  def self.HTMLHead(header, title)
    print header
    print <<-HEADER_TAG
      <HTML lang=ja>
      <HEAD>
       <TITLE>#{title}</TITLE>
       <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >
       <link rel='shortcut icon' href='./image/favicon.ico' />
       <link rel='stylesheet' type='text/css' href='./css/washcrus.css'>
      </HEAD>
      <BODY>
      HEADER_TAG
  end

  # HTMLヘッダ出力(no cookie)
  def self.HTMLHead2(title)
    print <<-HEADER2_TAG
      Content-Type: text/html; charset=UTF-8

      <HTML lang=ja>
      <HEAD>
       <TITLE>#{title}</TITLE>
       <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >
       <link rel='shortcut icon' href='./image/favicon.ico' />
       <link rel='stylesheet' type='text/css' href='./css/washcrus.css'>
      </HEAD>
      <BODY>
      HEADER2_TAG
  end

  # メニュー部分の出力 ログイン前
  def self.HTMLmenu(title)
    index = File.basename($PROGRAM_NAME)
    print "<div align='center'>#{title}</div><HR>\n",
          "<div align='center' class='menubase'>&nbsp;",
          "<a class='menu' href='#{index}'> Entrance </a>&nbsp;",
          "<a class='menu' href='#{index}?signup'> Sign Up </a>&nbsp;",
          "<a class='menu' href='#{index}?login'> Log In </a>&nbsp;",
          # "<a class='menu' href='#{index}?logout'> Log Out </a>&nbsp;",
          "</div><HR/>\n"
  end

  # メニュー部分の出力
  #
  # blogin ログイン中かどうか
  def self.HTMLmenuLogIn(title, blogin = true)
    return HTMLmenu(title) unless blogin

    index = File.basename($PROGRAM_NAME)
    print "<div align='center'>#{title}</div><HR>\n",
          "<div align='center' class='menubase'>&nbsp;",
          "<a class='menu' href='#{index}'> Entrance </a>&nbsp;",
          # "<a class='menu' href='#{index}?signup'> Sign Up </a>&nbsp;",
          # "<a class='menu' href='#{index}?login'> Log In </a>&nbsp;",
          "<a class='menu' href='#{index}?logout'> Log Out </a>&nbsp;",
          "</div><HR/>\n"
  end

  # フッターの出力
  def self.HTMLfoot
    print '<HR><div align=right>&copy;ぢるっち 2017 with Ruby v', RUBY_VERSION,
          '</div></BODY></HTML>'
  end
end
