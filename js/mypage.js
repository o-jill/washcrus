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
    if (elem == null) continue;

    var img = elem.getElementsByTagName('img')[0];
    var willbeshown = img.alt.indexOf(gid) >= 0
    elem.getElementsByTagName('input')[0].checked = willbeshown;
    elem.style.opacity = willbeshown ? 1.0 : 0.25;
  }
}

function releasechatmsg(gid)
{
  for (var i = 0 ; i < 200 ; ++i) {
    var elem = document.getElementById('chat' + i);
    if (elem == null) continue;

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

function scrollToTop()
{
  window.scroll({top: 0, behavior: "smooth"})
}

function scrollToBottom()
{
  var elm = document.documentElement;
  window.scroll({top: elm.scrollHeight - elm.clientHeight, behavior: "smooth"});
}

function scrollToNew()
{
  var elm = document.getElementById('cvnew');
  if (elm) {
    elm.scrollIntoView({behavior: "smooth", block: "center"});
  }
}

function onnavchat()
{
  /* 既読処理 */
  var ajax = new XMLHttpRequest();
  if (ajax === null) return;

  ajax.open('POST', 'index.rb?chatview', true);
  ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  ajax.send('dum=my');
  ajax.onreadystatechange = function() {
    switch (ajax.readyState) {
    case 4:
      /* nothing? */
      break;
    }
  };

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
