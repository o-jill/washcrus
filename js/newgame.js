/* - - - - - - - - - - */
/* common in this file */
/* - - - - - - - - - - */

function bytes2(str) {
  return encodeURIComponent(str).replace(/%../g, "x").length;
}

function validatemail(str) {
  return /^[\w.!#$%&'*+/=?^`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$/.test(str);
}

/* - - - - - - */
/* new game 1  */
/* - - - - - - */

function chgbgcolor(bOK, id_ply, id_eml)
{
  var ply = document.getElementById(id_ply).style;
  var eml = document.getElementById(id_eml).style;
  if (bOK) {
    ply.backgroundColor = 'transparent';
    eml.backgroundColor = 'transparent';
  } else {
    ply.backgroundColor = 'red';
    eml.backgroundColor = 'red';
  }
}

function check_name(id_name, id_ply, id_eml)
{
  var name = document.getElementById(id_name);
  var ret = (bytes2(name.value) >= 4);

  chgbgcolor(ret, id_ply, id_eml);

  return ret;
}

function check_email(id_email, id_ply, id_eml)
{
  var email = document.getElementById(id_email);
  var ret = validatemail(email.value);

  chgbgcolor(ret, id_ply, id_eml);

  return ret;
}

function puterr_or_submit(ng, form, eid, msg)
{
  if (ng === 0) {
    document.forms[form].submit();
  } else {
    document.getElementById(eid).innerText = msg;
  }
}

function check_form()
{
  var nmismatch = 0;
  var alertmsg = '';

  if (!check_name('rname', 'player1', 'tremail')) {
    alertmsg += 'name is too short in player1!\n';
    ++nmismatch;
  }
  if (!check_name('rname2', 'player2', 'tremail2')) {
    alertmsg += 'name is too short in player2!\n';
    ++nmismatch;
  }

  if (!check_email('remail', 'player1', 'tremail')) {
    alertmsg += 'e-mail addresses is strange in player1!\n';
    ++nmismatch;
  }
  if (!check_email('remail2', 'player2', 'tremail2')) {
    alertmsg += 'e-mail addresses is strange in player2!\n';
    ++nmismatch;
  }

  puterr_or_submit(nmismatch, 'gennewgame', 'errmsg', alertmsg);
}

function precheck_result(status, resp)
{
  var komanim = document.getElementById('komanim');
  komanim.style.display = 'none';
  var btn = document.getElementById('precheck');
  btn.disabled = false;
  var errmsg = document.getElementById('errmsg');
  if (status === 0) {  // XHR 通信失敗
    errmsg.innerText = "XHR 通信失敗";
  } else if ((200 <= status && status < 300) || status === 304) {
    // XHR 通信成功, リクエスト成功
    errmsg.innerText = resp;
  } else {
    // XHR 通信成功, リクエスト失敗
    errmsg.innerText = "その他の応答:" + status;
  }
}

function pre_check() {
  var name = document.getElementById('rname');
  var name2 = document.getElementById('rname2');
  var email = document.getElementById('remail');
  var email2 = document.getElementById('remail2');

  var postmsg = "rname="+name.value+"&rname2="+name2.value;
  postmsg += "&remail="+email.value+"&remail2="+email2.value;

  var ajax = new XMLHttpRequest();
  if (ajax === null)
    return;

  var komanim = document.getElementById('komanim');
  komanim.style.display = 'inline';
  var btn = document.getElementById('precheck')
  btn.disabled = true;

  ajax.open('POST', './index.rb?checknewgame', true);
  ajax.overrideMimeType('text/plain; charset=UTF-8');
  ajax.send(postmsg);

  ajax.onreadystatechange = function () {
    switch (ajax.readyState) {
    case 4:
      precheck_result(ajax.status, ajax.responseText);
      break;
    }
  };
}

function init_furigoma(sub)
{
  var koma, id;
  for (var i = 1; i <= 5; ++i) {
    id = 'furikomanim' + sub + i;
    koma = document.getElementById(id);
    koma.style.display = 'inline';
    id = 'furikomafu' + sub + i;
    koma = document.getElementById(id);
    koma.style.display = 'none';
    id = 'furikomato' + sub + i;
    koma = document.getElementById(id);
    koma.style.display = 'none';
  }
}

function lets_furigoma() {
  init_furigoma('')

  var btn = document.getElementById('btnfurigoma')
  btn.disabled = true;
  var koma = document.getElementById('furigoma');
  koma.value = "";
  setTimeout(function() {
    ontimer_furigoma()
  }, 1000);
}

function randomchoose(anim, fu, to) {
  var koma = document.getElementById(anim);
  koma.style.display = 'none';
  var value;
  if (Math.random() < 0.5) {
    value = "F";
    koma = document.getElementById(fu);
  } else {
    value = "T";
    koma = document.getElementById(to);
  }
  koma.style.display = 'inline';
  return value;
}

function ontimer_furigoma() {
  var furikoma = document.getElementById('furigoma');
  var komame = furikoma.value.length+1;
  if (komame <= 5) {
    var idanim = 'furikomanim' + komame;
    var idfu = 'furikomafu' + komame;
    var idto = 'furikomato' + komame;
    furikoma.value += randomchoose(idanim, idfu, idto);
  }
  if (komame <= 4) {
    setTimeout(function() {
      ontimer_furigoma();
    }, 1000);
  } else {
    var btn = document.getElementById('btnfurigoma');
    btn.disabled = false;
  }
}

/* - - - - - - - - */
/* - new game 2  - */
/* - - - - - - - - */

function check_selectindex(rid, eid)
{
  var index = document.getElementById(rid).selectedIndex;
  var ret = (index >= 1);
  if (ret) {
    document.getElementById(eid).style.backgroundColor = 'transparent';
  } else {
    document.getElementById(eid).style.backgroundColor = 'red';
  }
  return ret;
}

function check_form2()
{
  var nmismatch = 0;
  var alertmsg = '';

  if (!check_selectindex('rid', 'player21')) {
    alertmsg += 'please select player1!\n';
    ++nmismatch;
  }
  if (!check_selectindex('rid2', 'player22')) {
    alertmsg += 'please select player2!\n';
    ++nmismatch;
  }

  puterr_or_submit(nmismatch, 'gennewgame2', 'errmsg2', alertmsg);
}

function lets_furigoma2() {
  init_furigoma('2')

  var btn = document.getElementById('btnfurigoma2');
  btn.disabled = true;
  var koma = document.getElementById('furigoma2');
  koma.value = "";
  setTimeout(function() {
    ontimer_furigoma2()
  }, 1000);
}

function ontimer_furigoma2() {
  var furikoma = document.getElementById('furigoma2');
  var komame = furikoma.value.length+1;
  if (komame <= 5) {
    var idanim = 'furikomanim2' + komame;
    var idfu = 'furikomafu2' + komame;
    var idto = 'furikomato2' + komame;
    furikoma.value += randomchoose(idanim, idfu, idto);
  }
  if (komame <= 4) {
    setTimeout(function() {
      ontimer_furigoma2();
    }, 1000);
  } else {
    var btn = document.getElementById('btnfurigoma2');
    btn.disabled = false;
  }
}

function furifusen() {
  var name = document.getElementById('rname').value;
  var btn = document.getElementById('btnfurigoma')
  btn.value = name + 'の振り歩先で振り駒';
}

function furifusen2() {
  var index = document.getElementById('rid').selectedIndex;
  var options = document.getElementById('rid').options;
  var text = options[index].label;
  var cap = /(.+)\(/g.exec(text);
  var btn = document.getElementById('btnfurigoma2')
  btn.value = cap[1] + 'の振り歩先で振り駒';
}
