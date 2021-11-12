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

  // document.getElementById('errmsg').innerText = alertmsg;
  return nmismatch === 0;
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

  // document.getElementById('errmsg').innerText = alertmsg;
  return nmismatch === 0;
}

function confirm_unsubscribe()
{
  return document.getElementById('unsubscribe').value != '';
}

function filterchatmsg(gid)
{
  for (var i = 0 ; i < 200 ; ++i) {
    var elem = document.getElementById('chat' + i);
    if (elem == null) break;

    if (elem.innerText.indexOf(gid) >= 0) {
      elem.getElementsByTagName('input')[0].checked = true;
      elem.style.opacity = 1.0;
    } else {
      elem.getElementsByTagName('input')[0].checked = false;
      elem.style.opacity = .25;
      /* elem.style.display = 'none'; */
    }
  }
}

function releasechatmsg(gid)
{
  for (var i = 0 ; i < 200 ; ++i) {
    var elem = document.getElementById('chat' + i);
    if (elem == null) break;

    elem.getElementsByTagName('input')[0].checked = false;
    elem.style.opacity = 1.0;
    /* elem.style.display = 'block'; */
  }
}

function clickchatmsg(id, gid)
{
  var checked = event.target.checked;
  if (checked) {
    filterchatmsg(gid);
  } else {
    releasechatmsg(gid);
  }
}
