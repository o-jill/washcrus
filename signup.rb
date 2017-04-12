#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './common_ui.rb'
require "./userinfo.rb"

#
# 登録画面
#
def signup_screen(header, title, name, userinfo)
  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)

  print <<-STYLESHEET
<style type="text/css">
<!--
  table { font-size: 2rem; }
  input { font-size: 2rem; }
-->
</style>
STYLESHEET

  print <<-JAVASCRIPT
<script type='text/javascript'>
<!--
function check_form()
{
  var nmismatch = 0;
  var alertmsg = '';

  var name;
  name = document.getElementById('rname');
  if (name.value.length < 4) {
    document.getElementById('trname').style.backgroundColor = 'red';
    alertmsg += 'name is too short!\\n';
    ++nmismatch;
  } else {
    document.getElementById('trname').style.backgroundColor = 'transparent';
  }

  var email1, email2;
  email1 = document.getElementById('remail');
  email2 = document.getElementById('remail2');
  if (email1.value != email2.value) {
    document.getElementById('tremail').style.backgroundColor = 'red';
    document.getElementById('tremail2').style.backgroundColor = 'red';
    alertmsg += 'e-mail addresses are not same!\\n';
    ++nmismatch;
  } else {
    document.getElementById('tremail').style.backgroundColor = 'transparent';
    document.getElementById('tremail2').style.backgroundColor = 'transparent';
  }
  if (/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(email1.value)) {
  } else {
    document.getElementById('tremail').style.backgroundColor = 'red';
    document.getElementById('tremail2').style.backgroundColor = 'red';
    alertmsg += 'e-mail addresses is strange!\\n';
    ++nmismatch;
  }

  var password1, password2;
  password1 = document.getElementById('rpassword');
  password2 = document.getElementById('rpassword2');
  if (password1.value != password2.value) {
    document.getElementById('trpassword').style.backgroundColor = 'red';
    document.getElementById('trpassword2').style.backgroundColor = 'red';
    alertmsg += 'passwords are not same!\\n';
    ++nmismatch;
  } else {
    document.getElementById('trpassword').style.backgroundColor = 'transparent';
    document.getElementById('trpassword2').style.backgroundColor = 'transparent';
  }

  if (password1.value.length < 4) {
    document.getElementById('trpassword').style.backgroundColor = 'red';
    document.getElementById('trpassword2').style.backgroundColor = 'red';
    alertmsg += 'password is too short!\\n';
    ++nmismatch;
  }

  if (nmismatch === 0) {
    document.forms['signup'].submit();
  } else {
    window.alert(alertmsg);
  }
}
-->
</script>
JAVASCRIPT

  print "<FORM action='", File.basename($0), "?register' method=post name='signup'>",
    "<TABLE><TR id='trname'><TD>name</TD><TD><INPUT name='rname' id='rname' type=text size=25 required></TD></TR>",
    "<TR id='tremail'><TD>e-mail</TD><TD><INPUT name='remail' id='remail' type=email size=25 required></TD></TR>",
    "<TR id='tremail2'><TD>e-mail(again)</TD><TD><INPUT name='remail2' id='remail2' type=email size=25 required></TD></TR>",
    "<TR id='trpassword'><TD>password</TD><TD><INPUT name='rpassword' id='rpassword' type=password size=25 required></TD></TR>",
    "<TR id='trpassword2'><TD>password(again)</TD><TD><INPUT name='rpassword2' id='rpassword2' type=password size=25 required></TD></TR>",
    "<TR><TD colspan=2><input type='button' value='submit' onClick='check_form();'>&nbsp;<input type='reset'></TD></TR></TABLE></FORM>"

  CommonUI::HTMLfoot()
end
