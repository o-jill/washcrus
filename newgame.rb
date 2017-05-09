#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require './common_ui.rb'
require "./userinfo.rb"

#
# 対局登録画面
#
def newgame_screen(header, title, name, userinfo)
  scriptname = File.basename($0)

  blogin = (userinfo.user_id != nil && userinfo.user_id != "")

  CommonUI::HTMLHead(header, title)

  if blogin
    CommonUI::HTMLmenuLogIn(name)
  else
    CommonUI::HTMLmenu(name)
  end

  print <<-STYLESHEET
<style type="text/css">
<!--
  table { font-size: 2rem; }
  input { font-size: 2rem; }
  button { font-size: 2rem; }
-->
</style>
STYLESHEET

  print <<-JAVASCRIPT
<script type='text/javascript'>
<!--
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
-->
function furifusen() {
  var name = document.getElementById('rname').value;
  var btn = document.getElementById('btnfurigoma')
  btn.value = name + 'の振り歩先で振り駒';
}
</script>
JAVASCRIPT

  print <<-FORM_NEW_GAME
<FORM action='#{scriptname}?gennewgame' method=post name='gennewgame'>
<TABLE>
 <TR id='player1'>
  <TD rowspan=2>Player 1</TD><TD>name</TD><TD><INPUT name='rname' id='rname' type=text size=25 required onKeyup="furifusen()"></TD>
 </TR>
 <TR id='tremail'>
  <TD>e-mail</TD><TD><INPUT name='remail' id='remail' type=email size=25 required></TD>
 </TR>
 <TR id='player2'>
  <TD rowspan=2>Player 2</TD><TD>name</TD><TD><INPUT name='rname2' id='rname2' type=text size=25 required></TD>
 </TR>
 <TR id='tremail2'>
  <TD>e-mail</TD><TD><INPUT name='remail2' id='remail2' type=email size=25 required></TD>
 </TR>
 <TR>
  <TD colspan=3>
  <input type='button' value='submit' onClick='check_form();'>&nbsp;
  <input type='reset'>&nbsp;
  <input type='button' id='precheck' value='pre-check' onClick='pre_check();'>
  <img id='komanim' src='image/komanim.gif' style='display:none'></TD>
 </TR>
 <TR>
  <TD colspan=3>
   <input type="button" id='btnfurigoma' onClick='lets_furigoma();' value='Player1の振り歩先で振り駒'>
   <input type="hidden" id="furigoma" name="furigoma" value="FTFTF">
   <img id='furikomanim1' src='image/komanim.gif' style='display:none' width='32' height='32'>
   <img id='furikomafu1' src='image/komafu.png' style='display:none' width='32' height='32'>
   <img id='furikomato1' src='image/komato.png' style='display:none' width='32' height='32'>
   <img id='furikomanim2' src='image/komanim.gif' style='display:none' width='32' height='32'>
   <img id='furikomafu2' src='image/komafu.png' style='display:none' width='32' height='32'>
   <img id='furikomato2' src='image/komato.png' style='display:none' width='32' height='32'>
   <img id='furikomanim3' src='image/komanim.gif' style='display:none' width='32' height='32'>
   <img id='furikomafu3' src='image/komafu.png' style='display:none' width='32' height='32'>
   <img id='furikomato3' src='image/komato.png' style='display:none' width='32' height='32'>
   <img id='furikomanim4' src='image/komanim.gif' style='display:none' width='32' height='32'>
   <img id='furikomafu4' src='image/komafu.png' style='display:none' width='32' height='32'>
   <img id='furikomato4' src='image/komato.png' style='display:none' width='32' height='32'>
   <img id='furikomanim5' src='image/komanim.gif' style='display:none' width='32' height='32'>
   <img id='furikomafu5' src='image/komafu.png' style='display:none' width='32' height='32'>
   <img id='furikomato5' src='image/komato.png' style='display:none' width='32' height='32'>
  </TD>
 </TR>
</TABLE>
</FORM>
FORM_NEW_GAME
  CommonUI::HTMLfoot()
end
