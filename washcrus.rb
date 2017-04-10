#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require "cgi"

# ウインドウタイトル
$pagetitle = %Q{Wash Crus}

# ページタイトル
$titlename = %{洗足池}

#
# CGI本体
#
class WashCrus
  def initialize(cgi)
    @cgi = cgi;
    @params = cgi.params;
#    if @params.length>0
#      @params.each_value{|val|
#        val.gsub!(',','&#44;');
#      p val
#    }
#    end
    @action = cgi.query_string
  end

  # class methods

  #
  # cgi実行本体。
  # QUERY_STRINGによる分岐
  #
  def perform
    entrance_screen
  end

  #
  # デフォルトの入力画面
  #
  def entrance_screen
    WashCrus::HTMLHead($pagetitle)
    WashCrus::HTMLmenu($titlename)
    # @params.each_value{|val|
    #   p val
    # }

    #WashCrus::HTMLinputqna(@qna, @qna2)
    #WashCrus::HTMLhelp();
# testing
=begin
    WashCrus::test();
    WashCrus::testCGI(@params);
    #print "@action=",@action,"<BR>\n";
=end
# testing

    print "<TABLE bgcolor='#cc9933' align='center' bordercolor='black'  border='0' frame='void' rules='all'>\n",
      " <TR><TD><span style='font-size:3em'>&nbsp;&nbsp;&nbsp;</span></TD><TD></TD><TD></TD><TD><span style='font-size:3em'>&nbsp;&nbsp;&nbsp;</span></TD></TR>\n",
      " <TR><TD></TD><TD><strong><span style='font-size:12em'>角</span></strong></TD><TD></TD><TD></TD></TR>\n",
      " <TR><TD></TD><TD><strong><span style='font-size:12em'>銀</span></strong></TD><TD><strong><span style='font-size:12em'>飛</span></strong></TD><TD></TD></TR>\n",
      " <TR><TD><span style='font-size:2em'>&nbsp;</span></TD><TD></TD><TD></TD><TD><span style='font-size:2em'>&nbsp;</span></TD></TR>\n",
    "</TABLE>\n"

    WashCrus::HTMLfoot()
  end

  # class methods

  # HTMLヘッダ出力
  def self.HTMLHead(title)
    print "Content-Type: text/html\n\n",
      "<HTML lang=ja>\n<HEAD>\n <TITLE>",title,"</TITLE>\n",
      " <META http-equiv='Content-Type' content='text/html; charset=utf-8' >\n",
      #"<link rel='stylesheet' type='text/css' href='qinoacnv.css'>\n",
      " <STYLE type=text/css>\n<!--\n",
      "-->\n </STYLE>\n",
      " <SCRIPT type='text/javascript'>\n",
      "<!--\n\nfunction show_help_text()\n{\n",
      "  document.all.help_text.style.display='block';\n",
      "  document.all.btn_help_text_show.style.display='none';\n",
      "  document.all.btn_help_text_hide.style.display='inline';\n}\n\n",
      "function hide_help_text()\n{\n",
      "  document.all.help_text.style.display='none';\n",
      "  document.all.btn_help_text_show.style.display='inline';\n",
      "  document.all.btn_help_text_hide.style.display='none';\n}\n",
      "-->\n </SCRIPT>\n</HEAD>\n<BODY>\n";
  end

  # メニュー部分の出力
  def self.HTMLmenu(title)
    print "<div align='center'>",title,"</div><HR/>\n";
=begin
    print "<div align='center' class='menubase'>&nbsp;",
      "<a class='menu' href='qinoacnv.rb'> 検索 </a>&nbsp;",
      "<a class='menu' href='qinoacnv.rb?add'> 追加 </a>&nbsp;",
      "<a class='menu' href=\"javascript:window.open('qinoacnv.rb?tag','TAG','statusbar=yes,height=400,width=400');\"> タグ一覧 </a>&nbsp;",
      "</div><HR/>\n";
=end
  end

  # フッターの出力
  def self.HTMLfoot
    print "<HR/><div align=right>&copy;ぢるっち 2017</div></BODY></HTML>";
  end
end

# -----------------------------------
#   main
#

cgi = CGI.new;
qnacnv = WashCrus.new(cgi);
qnacnv.perform();

# -----------------------------------
#   testing
#
