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

function check_identical(a1, a2, u1, u2)
{
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
  if (/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(email1)) {
    return true;
  } else {
    email1ui.backgroundColor = 'tomato';
    email2ui.backgroundColor = 'tomato';
    return false;
  }
}

function check_password()
{
  var password1 = document.getElementById('rpassword');
  if (password1.value.length < 4) {
    document.getElementById('trpassword').style.backgroundColor = 'tomato';
    document.getElementById('trpassword2').style.backgroundColor = 'tomato';
    return false;
  }
  return true;
}

function check_form()
{
  var nmismatch = 0;
  var alertmsg = '';

  if (!check_name()) {
    alertmsg += 'name is too short!\n';
    ++nmismatch;
  }

  if (!check_identical('remail', 'remail2', 'tremail', 'tremail2')) {
    alertmsg += 'e-mail addresses are not same!\n';
    ++nmismatch;
  }
  if (!check_email_format()) {
    alertmsg += 'e-mail addresses is strange!\n';
    ++nmismatch;
  }

  if (!check_identical('rpassword', 'rpassword2', 'trpassword', 'trpassword2')) {
    alertmsg += 'passwords are not same!\n';
    ++nmismatch;
  }

  if (!check_password()) {
    alertmsg += 'password is too short!\n';
    ++nmismatch;
  }

  if (nmismatch === 0) {
    document.forms['signup'].submit();
  } else {
    document.getElementById('errmsg').innerText = alertmsg;
  }
}
