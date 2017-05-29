function bytes2(str) {
    return encodeURIComponent(str).replace(/%../g, "x").length;
}

function validatemail(str) {
    return /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(str);
}

function check_form()
{
  var nmismatch = 0;
  var alertmsg = '';

  var name;
  name = document.getElementById('rname');
  if (bytes2(name.value) < 4) {
    document.getElementById('player1').style.backgroundColor = 'red';
    document.getElementById('tremail').style.backgroundColor = 'red';
    alertmsg += 'name is too short in player1!\\n';
    ++nmismatch;
  } else {
    document.getElementById('player1').style.backgroundColor = 'transparent';
    document.getElementById('tremail').style.backgroundColor = 'transparent';
  }

  name = document.getElementById('rname2');
  if (bytes2(name.value) < 4) {
    document.getElementById('player2').style.backgroundColor = 'red';
    document.getElementById('tremail2').style.backgroundColor = 'red';
    alertmsg += 'name is too short  in player2!\\n';
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
    alertmsg += 'e-mail addresses is strange in player1!\\n';
    ++nmismatch;
  }

  email = document.getElementById('remail2');
  if (validatemail(email.value)) {
  } else {
    document.getElementById('player2').style.backgroundColor = 'red';
    document.getElementById('tremail2').style.backgroundColor = 'red';
    alertmsg += 'e-mail addresses is strange in player2!\\n';
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
  if (ajax != null) {
    var komanim = document.getElementById('komanim');
    komanim.style.display = 'inline';
    var btn = document.getElementById('precheck')
    btn.disabled = true;

    ajax.open('POST', 'checknewgame.rb', true);
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
    	if (status == 0) {  // XHR 通信失敗
    	  alert("XHR 通信失敗");
    	} else {  // XHR 通信成功
    	  if ((200 <= status && status < 300) || status == 304) {
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
  if (komame == 0) {
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
  } else if (komame == 1) {
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
  } else if (komame == 2) {
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
  } else if (komame == 3) {
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
  } else if (komame == 4) {
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

function furifusen() {
  var name = document.getElementById('rname').value;
  var btn = document.getElementById('btnfurigoma')
  btn.value = name + 'の振り歩先で振り駒';
}
