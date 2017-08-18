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

function check_form()
{
  var nmismatch = 0;
  var alertmsg = '';

  var name;
  name = document.getElementById('rname');
  if (countbyte(name.value) < 4) {
    document.getElementById('trname').style.backgroundColor = 'red';
    alertmsg += 'name is too short!\n';
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
    alertmsg += 'e-mail addresses are not same!\n';
    ++nmismatch;
  } else {
    document.getElementById('tremail').style.backgroundColor = 'transparent';
    document.getElementById('tremail2').style.backgroundColor = 'transparent';
  }
  if (/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(email1.value)) {
  } else {
    document.getElementById('tremail').style.backgroundColor = 'red';
    document.getElementById('tremail2').style.backgroundColor = 'red';
    alertmsg += 'e-mail addresses is strange!\n';
    ++nmismatch;
  }

  var password1, password2;
  password1 = document.getElementById('rpassword');
  password2 = document.getElementById('rpassword2');
  if (password1.value != password2.value) {
    document.getElementById('trpassword').style.backgroundColor = 'red';
    document.getElementById('trpassword2').style.backgroundColor = 'red';
    alertmsg += 'passwords are not same!\n';
    ++nmismatch;
  } else {
    document.getElementById('trpassword').style.backgroundColor = 'transparent';
    document.getElementById('trpassword2').style.backgroundColor = 'transparent';
  }

  if (password1.value.length < 4) {
    document.getElementById('trpassword').style.backgroundColor = 'red';
    document.getElementById('trpassword2').style.backgroundColor = 'red';
    alertmsg += 'password is too short!\n';
    ++nmismatch;
  }

  if (nmismatch === 0) {
    document.forms['signup'].submit();
  } else {
    window.alert(alertmsg);
  }
}
