#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './common_ui.rb'
require './userinfo.rb'

#
# 入り口画面
#
def entrance_screen(header, title, name, userinfo)
  blogin = (!userinfo.user_id.nil? && userinfo.user_id != '')

  CommonUI::HTMLHead(header, title)

  if blogin
    CommonUI::HTMLmenuLogIn(name)
  else
    CommonUI::HTMLmenu(name)
  end

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

    # # LOGO
    # print "<TABLE bgcolor='#cc9933' align='center' bordercolor='black' border='0' frame='void' rules='all'>\n",
    #   "<TR><TD><span style='font-size:3em'>&nbsp;&nbsp;&nbsp;</span></TD><TD></TD><TD></TD><TD><span style='font-size:3em'>&nbsp;&nbsp;&nbsp;</span></TD></TR>\n",
    #   "<TR><TD></TD><TD><strong><span style='font-size:12em'>角</span></strong></TD><TD></TD><TD></TD></TR>\n",
    #   "<TR><TD></TD><TD><strong><span style='font-size:12em'>銀</span></strong></TD><TD><strong><span style='font-size:12em'>飛</span></strong></TD><TD></TD></TR>\n",
    #   "<TR><TD><span style='font-size:2em'>&nbsp;</span></TD><TD></TD><TD></TD><TD><span style='font-size:2em'>&nbsp;</span></TD></TR>\n",
    # "</TABLE>\n"

  if blogin
    print '<HR><div align=center>', userinfo.user_name, 'さん',
          userinfo.visitcount, "回目の訪問ですね。</div><HR>\n",
          '<input type=hidden id=isloggedin value=1/>'
  else
    print '<HR><div align=center>どなたか存じ上げませんが',
          userinfo.visitcount, "回目の訪問ですね。</div><HR>\n",
          '<input type=hidden id=isloggedin value=0/>'
  end
  # test
  print "<span id=signup><A href='", File.basename($PROGRAM_NAME),
        "?signup'>signup</a></span><BR>",
        "<span id=signin><A href='", File.basename($PROGRAM_NAME),
        "?login'>signin</a></span><BR>",
        "<span id=users><A href='", File.basename($PROGRAM_NAME),
        "?userlist'>users</a></span><BR>",
        "<span id=matchs><A href='", File.basename($PROGRAM_NAME),
        "?matchlist'>matchs</a></span><BR>",
        "<span id=signout><A href='", File.basename($PROGRAM_NAME),
        "?logout'>signout</a></span><BR>",
        "<span id=create><A href='", File.basename($PROGRAM_NAME),
        "?newgame'>newgame</a></span><BR>",
        "<A href='washcrus.rb?anywhere'>anywhere</a>"
  # test
  CommonUI::HTMLfoot()
end
