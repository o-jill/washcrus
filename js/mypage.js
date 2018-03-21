
/* * !include 'signup.js' * */

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
    return true;
  } else {
    // document.getElementById('errmsg').innerText = alertmsg;
    return false;
  }
}

function check_form_mypageemail()
{
  var nmismatch = 0;
  var alertmsg = '';

  if (!check_identical('newemail')) {
    alertmsg += 'e-mail addresses are not same!\n';
    ++nmismatch;
  }
  if (!check_email_format('newemail')) {
    alertmsg += 'the e-mail address is strange!\n';
    ++nmismatch;
  }

  if (nmismatch === 0) {
    return true;
  } else {
    // document.getElementById('errmsg').innerText = alertmsg;
    return false;
  }
}
