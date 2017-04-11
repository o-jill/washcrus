#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './common_ui.rb'
require "./userinfo.rb"

#
# 入り口画面
#
def entrance_screen(header, title, name, userinfo)
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)
  # @params.each_value{|val|
  #   p val
  # }

  #CommonUI::HTMLinputqna(@qna, @qna2)
  #CommonUI::HTMLhelp();
# testing
=begin
    CommonUI::test();
    CommonUI::testCGI(@params);
    #print "@action=",@action,"<BR>\n";
=end
  # print "<HR>",ENV['HTTP_COOKIE'],"<HR>\n";
# testing
=begin
    print "<TABLE bgcolor='#cc9933' align='center' bordercolor='black' border='0' frame='void' rules='all'>\n",
      " <TR><TD><span style='font-size:3em'>&nbsp;&nbsp;&nbsp;</span></TD><TD></TD><TD></TD><TD><span style='font-size:3em'>&nbsp;&nbsp;&nbsp;</span></TD></TR>\n",
      " <TR><TD></TD><TD><strong><span style='font-size:12em'>角</span></strong></TD><TD></TD><TD></TD></TR>\n",
      " <TR><TD></TD><TD><strong><span style='font-size:12em'>銀</span></strong></TD><TD><strong><span style='font-size:12em'>飛</span></strong></TD><TD></TD></TR>\n",
      " <TR><TD><span style='font-size:2em'>&nbsp;</span></TD><TD></TD><TD></TD><TD><span style='font-size:2em'>&nbsp;</span></TD></TR>\n",
    "</TABLE>\n"
=end
  if (userinfo.user_id != nil && userinfo.user_id != "")
    print "<HR><div align=center>", userinfo.user_name, "さん", userinfo.visitcount, "回目の訪問ですね。</div><HR>\n"
  else
    print "<HR><div align=center>どなたか存じ上げませんが", userinfo.visitcount, "回目の訪問ですね。</div><HR>\n"
  end
  print "<A href='", File.basename($0), "?signup'>signup</a><BR>"
  print "<A href='washcrus.rb?anywhere'>anywhere</a>"
  CommonUI::HTMLfoot()
end
