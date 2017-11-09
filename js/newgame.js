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
  if (bOK) {
    document.getElementById(id_ply).style.backgroundColor = 'transparent';
    document.getElementById(id_eml).style.backgroundColor = 'transparent';
  } else {
    document.getElementById(id_ply).style.backgroundColor = 'red';
    document.getElementById(id_eml).style.backgroundColor = 'red';
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

  if (nmismatch === 0) {
    document.forms['gennewgame'].submit();
  } else {
    document.getElementById('errmsg').innerText = alertmsg;
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
  if (ajax !== null) {
    var komanim = document.getElementById('komanim');
    komanim.style.display = 'inline';
    var btn = document.getElementById('precheck')
    btn.disabled = true;

    ajax.open('POST', './washcrus.rb?checknewgame', true);
    ajax.overrideMimeType('text/plain; charset=UTF-8');
    ajax.send(postmsg);

    ajax.onreadystatechange = function () {
      switch (ajax.readyState) {
      case 4:
        var komanim = document.getElementById('komanim');
        komanim.style.display = 'none';
        var btn = document.getElementById('precheck')
        btn.disabled = false;
        var status = ajax.status;
        if (status === 0) {  // XHR 通信失敗
          document.getElementById('errmsg').innerText = "XHR 通信失敗";
        } else {  // XHR 通信成功
          if ((200 <= status && status < 300) || status === 304) {
            // リクエスト成功
            document.getElementById('errmsg').innerText = ajax.responseText;
          } else {  // リクエスト失敗
            document.getElementById('errmsg').innerText = "その他の応答:" + status;
          }
        }
        break;
      }
    };
    /* ajax.onload = function(e) {
      utf8text = ajax.responseText;
    }; */
  }
}

function lets_furigoma() {
  var koma, id;
  for (var i = 1; i <= 5; ++i) {
    id = 'furikomanim'+i;
    koma = document.getElementById(id);
    koma.style.display = 'inline';
    id = 'furikomafu'+i;
    koma = document.getElementById(id);
    koma.style.display = 'none';
    id = 'furikomato'+i;
    koma = document.getElementById(id);
    koma.style.display = 'none';
  }

  var btn = document.getElementById('btnfurigoma')
  btn.disabled = true;
  koma = document.getElementById('furigoma');
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
  var komame = furikoma.value.length
  if (komame <= 4) {
    var idanim = 'furikomanim' + (komame+1);
    var idfu = 'furikomafu' + (komame+1);
    var idto = 'furikomato' + (komame+1);
    furikoma.value += randomchoose(idanim, idfu, idto);
  }
  if (komame <= 3) {
    setTimeout(function() {
      ontimer_furigoma()
    }, 1000);
  } else {
    var btn = document.getElementById('btnfurigoma');
    btn.disabled = false;
  }
}

/* - - - - - - - - */
/* - new game 2  - */
/* - - - - - - - - */

function check_form2()
{
  var nmismatch = 0;
  var alertmsg = '';

  var index1 = document.getElementById('rid').selectedIndex;
  var index2 = document.getElementById('rid2').selectedIndex;

  if (index1 < 1) {
    document.getElementById('player21').style.backgroundColor = 'red';
    alertmsg += 'please select player1!\n';
    ++nmismatch;
  } else {
    document.getElementById('player21').style.backgroundColor = 'transparent';
  }
  if (index2 < 1) {
    document.getElementById('player22').style.backgroundColor = 'red';
    alertmsg += 'please select player2!\n';
    ++nmismatch;
  } else {
    document.getElementById('player22').style.backgroundColor = 'transparent';
  }

  if (nmismatch === 0) {
    document.forms['gennewgame2'].submit();
  } else {
    document.getElementById('errmsg2').innerText = alertmsg;
  }
}

function lets_furigoma2() {
  var koma, id;
  for (var i = 1; i <= 5; ++i) {
    id = 'furikomanim2'+i;
    koma = document.getElementById(id);
    koma.style.display = 'inline';
    id = 'furikomafu2'+i;
    koma = document.getElementById(id);
    koma.style.display = 'none';
    id = 'furikomato2'+i;
    koma = document.getElementById(id);
    koma.style.display = 'none';
  }

  var btn = document.getElementById('btnfurigoma2');
  btn.disabled = true;
  koma = document.getElementById('furigoma2');
  koma.value = "";
  setTimeout(function() {
    ontimer_furigoma2()
  }, 1000);
}

function ontimer_furigoma2() {
  var furikoma = document.getElementById('furigoma2');
  var komame = furikoma.value.length
  if (komame <= 4) {
    var idanim = 'furikomanim2' + (komame+1);
    var idfu = 'furikomafu2' + (komame+1);
    var idto = 'furikomato2' + (komame+1);
    furikoma.value += randomchoose(idanim, idfu, idto);
  }
  if (komame <= 3) {
    setTimeout(function() {
      ontimer_furigoma2()
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
