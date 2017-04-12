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

  print <<-JAVASCRIPT
<script type='text/javascript'>
<!--
function check_loggedin()
{
  var loggedin = document.getElementById('isloggedin').value;
  var signup = document.getElementById('signup');
  var signin = document.getElementById('signin');
  if (loggedin == 1) {
    signup.style.backgroundColor = 'transparent';
    signin.style.backgroundColor = 'transparent';
  } else {
    signup.style.backgroundColor = 'green';
    signin.style.backgroundColor = 'blue';
  }
}
check_loggedin();
-->
</script>
JAVASCRIPT

=begin
    # LOGO
    print "<TABLE bgcolor='#cc9933' align='center' bordercolor='black' border='0' frame='void' rules='all'>\n",
      " <TR><TD><span style='font-size:3em'>&nbsp;&nbsp;&nbsp;</span></TD><TD></TD><TD></TD><TD><span style='font-size:3em'>&nbsp;&nbsp;&nbsp;</span></TD></TR>\n",
      " <TR><TD></TD><TD><strong><span style='font-size:12em'>角</span></strong></TD><TD></TD><TD></TD></TR>\n",
      " <TR><TD></TD><TD><strong><span style='font-size:12em'>銀</span></strong></TD><TD><strong><span style='font-size:12em'>飛</span></strong></TD><TD></TD></TR>\n",
      " <TR><TD><span style='font-size:2em'>&nbsp;</span></TD><TD></TD><TD></TD><TD><span style='font-size:2em'>&nbsp;</span></TD></TR>\n",
    "</TABLE>\n"
=end
  if (userinfo.user_id != nil && userinfo.user_id != "")
    print "<HR><div align=center>", userinfo.user_name, "さん", userinfo.visitcount, "回目の訪問ですね。</div><HR>\n"
    print "<input type=hidden id=isloggedin value=1/>"
  else
    print "<HR><div align=center>どなたか存じ上げませんが", userinfo.visitcount, "回目の訪問ですね。</div><HR>\n"
    print "<input type=hidden id=isloggedin value=1/>"
  end
  print "<span id=signup><A href='", File.basename($0), "?signup'>signup</a></span><BR>"
  print "<span id=signin><A href='", File.basename($0), "?login'>signin</a></span><BR>"
  print "<span id=signout><A href='", File.basename($0), "?logout'>signout</a></span><BR>"
  print "<A href='washcrus.rb?anywhere'>anywhere</a>"
  CommonUI::HTMLfoot()
end
