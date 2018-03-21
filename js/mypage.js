
/* * !include 'signup.js' * */

/*function countbyte(str)
{
  var sz = 0;
  var len = str.length;
  for (var i = 0 ; i < len ; ++i) {
    if (escape(str.charAt(i)).length < 4) {
      ++sz;
    } else {
      sz += 2;
    }
  }
  return sz;
}*/

/*function check_name()
{
  var name = document.getElementById('rname');
  var nameui = document.getElementById('trname').style;
  if (countbyte(name.value) < 4) {
    nameui.backgroundColor = 'tomato';
    return false;
  } else {
    nameui.backgroundColor = 'transparent';
    return true;
  }
}*/

/*function check_email_format()
{
  var email1 = document.getElementById('remail').value;
  var email1ui = document.getElementById('tremail').style;
  var email2ui = document.getElementById('tremail2').style;
  if (/^[\w.!#$%&'*+/=?^`{|}~-]+@\w+(?:\.\w+)*$/.test(email1)) {
    return true;
  } else {
    email1ui.backgroundColor = 'tomato';
    email2ui.backgroundColor = 'tomato';
    return false;
  }
}*/

/*function check_email()
{
  var alertmsg = '';
  if (!check_identical('email')) {
    alertmsg += 'e-mail addresses are not same!\n';
  }
  if (!check_email_format()) {
    alertmsg += 'e-mail addresses is strange!\n';
  }
  return alertmsg;
}*/

function check_form_mypagepswd()
{
  var nmismatch = 0;
  var alertmsg = '';

  if (!check_identical('newpassword')) {
    alertmsg += 'passwords are not same!\n';
    ++nmismatch;
  }
  if (!check_password_format('newpassword')) {
    alertmsg += 'password is too short!\n';
    ++nmismatch;
  }

  if (nmismatch === 0) {
    document.forms['update_password'].submit();
  } else {
    // document.getElementById('errmsg').innerText = alertmsg;
  }
}
