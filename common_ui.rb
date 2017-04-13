#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

class CommonUI
  # HTMLヘッダ出力
  def self.HTMLHead(header, title)
    print header
    # print "Content-Type: text/html; charset=UTF-8\nSet-Cookie: _rarirurero_id=0123; path=; expires=Mon, 10 Apr 2017 10:00:00\n\n"
    print "<HTML lang=ja>\n<HEAD>\n <TITLE>",title,"</TITLE>\n",
      " <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >\n",
      " <link rel='shortcut icon' href='./favicon.ico' />",
      #"<link rel='stylesheet' type='text/css' href='warshcrus.css'>\n",
#      " <STYLE type=text/css>\n<!--\n",
      # "-->\n </STYLE>\n",
      # " <SCRIPT type='text/javascript'>\n",
      # "<!--\nfunction show_help_text()\n{\n",
      # "  document.all.help_text.style.display='block';\n",
      # "  document.all.btn_help_text_show.style.display='none';\n",
      # "  document.all.btn_help_text_hide.style.display='inline';\n}\n",
      # "function hide_help_text()\n{\n",
      # "  document.all.help_text.style.display='none';\n",
      # "  document.all.btn_help_text_show.style.display='inline';\n",
      # "  document.all.btn_help_text_hide.style.display='none';\n}\n",
      # "-->\n </SCRIPT>\n",
      "</HEAD>\n<BODY>\n";
      # print header
  end

  # HTMLヘッダ出力(no cookie)
  def self.HTMLHead2(title)
    print "Content-Type: text/html; charset=UTF-8\n\n"
    print "<HTML lang=ja>\n<HEAD>\n <TITLE>",title,"</TITLE>\n",
      " <META http-equiv='Content-Type' content='text/html; charset=UTF-8' >\n",
      " <link rel='shortcut icon' href='./favicon.ico' />",
      #"<link rel='stylesheet' type='text/css' href='warshcrus.css'>\n",
#      " <STYLE type=text/css>\n<!--\n",
      # "-->\n </STYLE>\n",
      # " <SCRIPT type='text/javascript'>\n",
      # "<!--\nfunction show_help_text()\n{\n",
      # "  document.all.help_text.style.display='block';\n",
      # "  document.all.btn_help_text_show.style.display='none';\n",
      # "  document.all.btn_help_text_hide.style.display='inline';\n}\n",
      # "function hide_help_text()\n{\n",
      # "  document.all.help_text.style.display='none';\n",
      # "  document.all.btn_help_text_show.style.display='inline';\n",
      # "  document.all.btn_help_text_hide.style.display='none';\n}\n",
      # "-->\n </SCRIPT>\n",
      "</HEAD>\n<BODY>\n";
  end

  # メニュー部分の出力 ログイン前
  def self.HTMLmenu(title)
    index = File.basename($0)
    print "<div align='center'>",title,"</div><HR>\n";
    print "<div align='center' class='menubase'>&nbsp;",
      "<a class='menu' href='", index, "'> Entrance </a>&nbsp;",
      "<a class='menu' href='", index, "?signup'> Sign Up </a>&nbsp;",
      "<a class='menu' href='", index, "?login'> Log In </a>&nbsp;",
      # "<a class='menu' href='", index, "?logout'> Log Out </a>&nbsp;",
      "</div><HR/>\n";
  end

  # メニュー部分の出力 ログイン中
  def self.HTMLmenuLogIn(title)
    index = File.basename($0)
    print "<div align='center'>",title,"</div><HR>\n";
    print "<div align='center' class='menubase'>&nbsp;",
      "<a class='menu' href='", index, "'> Entrance </a>&nbsp;",
      # "<a class='menu' href='", index, "?signup'> Sign Up </a>&nbsp;",
      # "<a class='menu' href='", index, "?login'> Log In </a>&nbsp;",
      "<a class='menu' href='", index, "?logout'> Log Out </a>&nbsp;",
      "</div><HR/>\n";
  end

  # フッターの出力
  def self.HTMLfoot
    print "<HR><div align=right>&copy;ぢるっち 2017 with Ruby v",  RUBY_VERSION, "</div></BODY></HTML>";
  end
end
