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
    # print "Content-Type: text/html; charset=UTF-8\n",
    #       "Set-Cookie: _rarirurero_id=0123; path=; expires=Mon, 10 Apr 2017 10:00:00\n\n"
    print "<HTML lang=ja>\n<HEAD>\n <TITLE>#{title}</TITLE>\n",
          " <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >\n",
          " <link rel='shortcut icon' href='./image/favicon.ico' />\n",
          " <link rel='stylesheet' type='text/css' href='./css/washcrus.css'>\n",
          "</HEAD>\n<BODY>\n"
      # print header
  end

  # HTMLヘッダ出力(no cookie)
  def self.HTMLHead2(title)
    print "Content-Type: text/html; charset=UTF-8\n\n",
          "<HTML lang=ja>\n<HEAD>\n <TITLE>#{title}</TITLE>\n",
          " <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >\n",
          " <link rel='shortcut icon' href='./image/favicon.ico' />\n",
          " <link rel='stylesheet' type='text/css' href='./css/washcrus.css'>\n",
          "</HEAD>\n<BODY>\n"
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
    unless blogin
      return HTMLmenu(title)
    end

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
