function countbyte(str)
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
}

function check_name()
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
}

function check_identical(a)
{
  var a1 = 'r' + a;
  var a2 = a1 + '2';
  var u1 = 't' + a1;
  var u2 = u1 + '2';

  var em1 = document.getElementById(a1);
  var em2 = document.getElementById(a2);
  var em1ui = document.getElementById(u1).style;
  var em2ui = document.getElementById(u2).style;
  if (em1.value !== em2.value) {
    em1ui.backgroundColor = 'tomato';
    em2ui.backgroundColor = 'tomato';
    return false;
  } else {
    em1ui.backgroundColor = 'transparent';
    em2ui.backgroundColor = 'transparent';
    return true;
  }
}

function check_email_format()
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
}

function check_password_format(a)
{
  var a1 = 'r' + a;
  var u1 = 't' + a1;
  var u2 = u1 + '2';
  var b1 = document.getElementById(u1).style.backgroundColor;
  var b1 = document.getElementById(u2).style.backgroundColor;

  var password1 = document.getElementById(a1);
  if (password1.value.length < 4) {
    b1 = 'tomato';
    b2 = 'tomato';

    return false;
  }
  b1 = 'transparent';
  b2 = 'transparent';

  return true;
}

function check_email()
{
  var alertmsg = '';
  if (!check_identical('email')) {
    alertmsg += 'e-mail addresses are not same!\n';
  }
  if (!check_email_format()) {
    alertmsg += 'e-mail addresses is strange!\n';
  }
  return alertmsg;
}

function check_password()
{
  var alertmsg = '';
  if (!check_identical('password')) {
    alertmsg += 'passwords are not same!\n';
  }
  if (!check_password_format('password')) {
    alertmsg += 'password is too short!\n';
  }
  return alertmsg;
}

function check_form()
{
  var nmismatch = 0;
  var alertmsg = '';

  if (!check_name()) {
    alertmsg += 'name is too short!\n';
    ++nmismatch;
  }

  var ret = check_email();
  if (ret !== '') {
    alertmsg += ret;
    ++nmismatch;
  }

  ret = check_password();
  if (ret !== '') {
    alertmsg += ret;
    ++nmismatch;
  }

  if (nmismatch === 0) {
    document.forms['signup'].submit();
  } else {
    document.getElementById('errmsg').innerText = alertmsg;
  }
}
