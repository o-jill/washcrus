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
    var img = elem.getElementsByTagName('img')[0];
    if (img.alt.indexOf(gid) >= 0) {
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

function scrollToAnchor(id)
{
  location.hash = '#' + id;
}

function onnavchat()
{
  /* 既読処理 */

  /* 未読に飛ぶ */
  /* scrollToAnchor('cvnew'); */
}

var target;
function clicknav(strid) {
  if (target) {
    target.style.display = 'none';
  }
  target = document.getElementById(strid);
  target.style.display = 'block';
}

document.addEventListener('DOMContentLoaded', (event) => {
  target = document.getElementById('mypage_stats');

  var navitems = ["stats", "chat", "rireki", "pswd", "email", "unsubscribe"];
  for (var item of navitems) {
    document.getElementById("navbtn_" + item).addEventListener('click',
      function() {
        res = this.id.match(/navbtn_(.+)/);
        clicknav('mypage_' + res[1]);
        var fn = window['onnav' + res[1]];
        if (typeof fn == 'function') fn()
      }
    );
  }
});
