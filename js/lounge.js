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
