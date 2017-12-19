function reloadlater()
{
  setTimeout(function() {location.reload(true);}, 3000);
}

function buildF2LMsg()
{
  return 'action=file&f2lcmt='
    + encodeURIComponent(document.getElementById('cmt').value);
}

function file2lounge_resp(status, resp)
{
  var msg = document.getElementById('msg_l2f');
  if (status === 0) {  // XHR 通信失敗
    msg.innerHTML += '[XHR 通信失敗]' + resp + '自動的にリロードします。';
    reloadlater();
    return;
  }
  // XHR 通信成功
  if ((200 <= status && status < 300) || status === 304) {
    // リクエスト成功
    msg.innerHTML = '[通信完了。] ' + resp + ' 自動的にリロードします。';
  } else {  // リクエスト失敗
    msg.innerHTML += '[その他の応答:" + status + "]' + resp + '自動的にリロードします。';
  }
  reloadlater();
}

function file2lounge()
{
  document.getElementById('btn_f2l').disabled = true;
  document.getElementById('cmt').disabled = true;

  var ajax = new XMLHttpRequest();
  if (ajax === null)
    return;
  ajax.open('POST', 'washcrus.rb?file2lounge', true);
  ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  ajax.send(buildF2LMsg());
  ajax.onreadystatechange = function() {
    switch (ajax.readyState) {
    case 4:
      file2lounge_resp(ajax.status, ajax.responseText);
      break;
    }
  };
}

function cancelfromlounge_resp(status, resp)
{
  var msg = document.getElementById('msg_cfl');
  if (status === 0) {  // XHR 通信失敗
    msg.innerHTML += '[XHR 通信失敗]' + resp + '自動的にリロードします。';
    reloadlater();
    return;
  }
  // XHR 通信成功
  if ((200 <= status && status < 300) || status === 304) {
    // リクエスト成功
    msg.innerHTML = '[通信完了。] ' + resp + ' 自動的にリロードします。';
  } else {  // リクエスト失敗
    msg.innerHTML += '[その他の応答:' + status + ']' + resp + '自動的にリロードします。';
  }
  reloadlater();
}

function cancelfromlounge()
{
  document.getElementById('btn_cfl').disabled = true;

  var ajax = new XMLHttpRequest();
  if (ajax === null)
    return;
  ajax.open('POST', 'washcrus.rb?file2lounge', true);
  ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  ajax.send('action=cancel&f2lcmt=');
  ajax.onreadystatechange = function() {
    switch (ajax.readyState) {
    case 4:
      cancelfromlounge_resp(ajax.status, ajax.responseText);
      break;
    }
  };
}

function onclick_radiobtn(e)
{
  var name = e.target.parentElement.innerText.trim();
  document.getElementById('opponentname').innerText = name;
  document.getElementById('btn_gen').disabled = false;
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

  document.getElementById('btn_gen').disabled = true;
  document.getElementById('furigoma').value = "";

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
    document.forms['gennewgame'].submit();
  }
}

function onstart()
{
  var sengo = document.getElementById('sengo').selectedIndex;

  if (sengo == 0) {
    document.getElementById('furigoma').value = 'FFFFF';
    return true;
  } else if (sengo == 1) {
    document.getElementById('furigoma').value = 'TTTTT';
    return true;
  } else if (sengo == 2) {
    lets_furigoma();
    return false;
  } else {
    return false;
  }
}
