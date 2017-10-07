/* - - - - - - - - - - */
/* common in this file */
/* - - - - - - - - - - */

function bytes2(str) {
    return encodeURIComponent(str).replace(/%../g, "x").length;
}

function validatemail(str) {
    return /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(str);
}

/* - - - - - - */
/* new game 1  */
/* - - - - - - */

function check_form()
{
  var nmismatch = 0;
  var alertmsg = '';

  var name;
  name = document.getElementById('rname');
  if (bytes2(name.value) < 4) {
    document.getElementById('player1').style.backgroundColor = 'red';
    document.getElementById('tremail').style.backgroundColor = 'red';
    alertmsg += 'name is too short in player1!\n';
    ++nmismatch;
  } else {
    document.getElementById('player1').style.backgroundColor = 'transparent';
    document.getElementById('tremail').style.backgroundColor = 'transparent';
  }

  name = document.getElementById('rname2');
  if (bytes2(name.value) < 4) {
    document.getElementById('player2').style.backgroundColor = 'red';
    document.getElementById('tremail2').style.backgroundColor = 'red';
    alertmsg += 'name is too short  in player2!\n';
    ++nmismatch;
  } else {
    document.getElementById('player2').style.backgroundColor = 'transparent';
    document.getElementById('tremail2').style.backgroundColor = 'transparent';
  }

  var email = document.getElementById('remail');
  if (validatemail(email.value)) {
  } else {
    document.getElementById('player1').style.backgroundColor = 'red';
    document.getElementById('tremail').style.backgroundColor = 'red';
    alertmsg += 'e-mail addresses is strange in player1!\n';
    ++nmismatch;
  }

  email = document.getElementById('remail2');
  if (validatemail(email.value)) {
  } else {
    document.getElementById('player2').style.backgroundColor = 'red';
    document.getElementById('tremail2').style.backgroundColor = 'red';
    alertmsg += 'e-mail addresses is strange in player2!\n';
    ++nmismatch;
  }

  if (nmismatch === 0) {
    document.forms['gennewgame'].submit();
  } else {
    window.alert(alertmsg);
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
    	  alert("XHR 通信失敗");
    	} else {  // XHR 通信成功
    	  if ((200 <= status && status < 300) || status === 304) {
            // リクエスト成功
            window.alert(ajax.responseText);
    	  } else {  // リクエスト失敗
    		alert("その他の応答:" + status);
    	  }
    	}
    	break;
      }
    };
    ajax.onload = function(e) {
      utf8text = ajax.responseText;
    };
  }
}

function lets_furigoma() {
  var koma = document.getElementById('furikomanim1');
  koma.style.display = 'inline';
  koma = document.getElementById('furikomafu1');
  koma.style.display = 'none';
  koma = document.getElementById('furikomato1');
  koma.style.display = 'none';
  koma = document.getElementById('furikomanim2');
  koma.style.display = 'inline';
  koma = document.getElementById('furikomafu2');
  koma.style.display = 'none';
  koma = document.getElementById('furikomato2');
  koma.style.display = 'none';
  koma = document.getElementById('furikomanim3');
  koma.style.display = 'inline';
  koma = document.getElementById('furikomafu3');
  koma.style.display = 'none';
  koma = document.getElementById('furikomato3');
  koma.style.display = 'none';
  koma = document.getElementById('furikomanim4');
  koma.style.display = 'inline';
  koma = document.getElementById('furikomafu4');
  koma.style.display = 'none';
  koma = document.getElementById('furikomato4');
  koma.style.display = 'none';
  koma = document.getElementById('furikomanim5');
  koma.style.display = 'inline';
  koma = document.getElementById('furikomafu5');
  koma.style.display = 'none';
  koma = document.getElementById('furikomato5');
  koma.style.display = 'none';

  var btn = document.getElementById('btnfurigoma')
  btn.disabled = true;
  koma = document.getElementById('furigoma');
  koma.value = "";
  setTimeout("ontimer_furigoma()", 1000);
}

function ontimer_furigoma() {
  var furikoma = document.getElementById('furigoma');
  var btn = document.getElementById('btnfurigoma')
  var koma;
  var komame = furikoma.value.length
  if (komame === 0) {
    koma = document.getElementById('furikomanim1');
    koma.style.display = 'none';
    if (Math.random() < 0.5) {
      furikoma.value += "F";
      koma = document.getElementById('furikomafu1');
    } else {
      furikoma.value += "T";
      koma = document.getElementById('furikomato1');
    }
    koma.style.display = 'inline';
    setTimeout("ontimer_furigoma()", 1000);
  } else if (komame === 1) {
    koma = document.getElementById('furikomanim2');
    koma.style.display = 'none';
    if (Math.random() < 0.5) {
      furikoma.value += "F";
      koma = document.getElementById('furikomafu2');
    } else {
      furikoma.value += "T";
      koma = document.getElementById('furikomato2');
    }
    koma.style.display = 'inline';
    setTimeout("ontimer_furigoma()", 1000);
  } else if (komame === 2) {
    koma = document.getElementById('furikomanim3');
    koma.style.display = 'none';
    if (Math.random() < 0.5) {
      furikoma.value += "F";
      koma = document.getElementById('furikomafu3');
    } else {
      furikoma.value += "T";
      koma = document.getElementById('furikomato3');
    }
    koma.style.display = 'inline';
    setTimeout("ontimer_furigoma()", 1000);
  } else if (komame === 3) {
    koma = document.getElementById('furikomanim4');
    koma.style.display = 'none';
    if (Math.random() < 0.5) {
      furikoma.value += "F";
      koma = document.getElementById('furikomafu4');
    } else {
      furikoma.value += "T";
      koma = document.getElementById('furikomato4');
    }
    koma.style.display = 'inline';
    setTimeout("ontimer_furigoma()", 1000);
  } else if (komame === 4) {
    koma = document.getElementById('furikomanim5');
    koma.style.display = 'none';
    if (Math.random() < 0.5) {
      furikoma.value += "F";
      koma = document.getElementById('furikomafu5');
    } else {
      furikoma.value += "T";
      koma = document.getElementById('furikomato5');
    }
    koma.style.display = 'inline';
    btn.disabled = false;
  } else {
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
    window.alert(alertmsg);
  }
}

function lets_furigoma2() {
  var koma = document.getElementById('furikomanim21');
  koma.style.display = 'inline';
  koma = document.getElementById('furikomafu21');
  koma.style.display = 'none';
  koma = document.getElementById('furikomato21');
  koma.style.display = 'none';
  koma = document.getElementById('furikomanim22');
  koma.style.display = 'inline';
  koma = document.getElementById('furikomafu22');
  koma.style.display = 'none';
  koma = document.getElementById('furikomato22');
  koma.style.display = 'none';
  koma = document.getElementById('furikomanim23');
  koma.style.display = 'inline';
  koma = document.getElementById('furikomafu23');
  koma.style.display = 'none';
  koma = document.getElementById('furikomato23');
  koma.style.display = 'none';
  koma = document.getElementById('furikomanim24');
  koma.style.display = 'inline';
  koma = document.getElementById('furikomafu24');
  koma.style.display = 'none';
  koma = document.getElementById('furikomato24');
  koma.style.display = 'none';
  koma = document.getElementById('furikomanim25');
  koma.style.display = 'inline';
  koma = document.getElementById('furikomafu25');
  koma.style.display = 'none';
  koma = document.getElementById('furikomato25');
  koma.style.display = 'none';

  var btn = document.getElementById('btnfurigoma2')
  btn.disabled = true;
  koma = document.getElementById('furigoma2');
  koma.value = "";
  setTimeout("ontimer_furigoma2()", 1000);
}

function ontimer_furigoma2() {
  var furikoma = document.getElementById('furigoma2');
  var btn = document.getElementById('btnfurigoma2')
  var koma;
  var komame = furikoma.value.length
  if (komame === 0) {
    koma = document.getElementById('furikomanim21');
    koma.style.display = 'none';
    if (Math.random() < 0.5) {
      furikoma.value += "F";
      koma = document.getElementById('furikomafu21');
    } else {
      furikoma.value += "T";
      koma = document.getElementById('furikomato21');
    }
    koma.style.display = 'inline';
    setTimeout("ontimer_furigoma2()", 1000);
  } else if (komame === 1) {
    koma = document.getElementById('furikomanim22');
    koma.style.display = 'none';
    if (Math.random() < 0.5) {
      furikoma.value += "F";
      koma = document.getElementById('furikomafu22');
    } else {
      furikoma.value += "T";
      koma = document.getElementById('furikomato22');
    }
    koma.style.display = 'inline';
    setTimeout("ontimer_furigoma2()", 1000);
  } else if (komame === 2) {
    koma = document.getElementById('furikomanim23');
    koma.style.display = 'none';
    if (Math.random() < 0.5) {
      furikoma.value += "F";
      koma = document.getElementById('furikomafu23');
    } else {
      furikoma.value += "T";
      koma = document.getElementById('furikomato23');
    }
    koma.style.display = 'inline';
    setTimeout("ontimer_furigoma2()", 1000);
  } else if (komame === 3) {
    koma = document.getElementById('furikomanim24');
    koma.style.display = 'none';
    if (Math.random() < 0.5) {
      furikoma.value += "F";
      koma = document.getElementById('furikomafu24');
    } else {
      furikoma.value += "T";
      koma = document.getElementById('furikomato24');
    }
    koma.style.display = 'inline';
    setTimeout("ontimer_furigoma2()", 1000);
  } else if (komame === 4) {
    koma = document.getElementById('furikomanim25');
    koma.style.display = 'none';
    if (Math.random() < 0.5) {
      furikoma.value += "F";
      koma = document.getElementById('furikomafu25');
    } else {
      furikoma.value += "T";
      koma = document.getElementById('furikomato25');
    }
    koma.style.display = 'inline';
    btn.disabled = false;
  } else {
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
