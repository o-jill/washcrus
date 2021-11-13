var chat_elem_id = document.getElementById('gameid');
var chat_id = chat_elem_id.value;

var chat_elem_log = document.getElementById('chatlog');
var chat_elem_msg = document.getElementById('chatmsg');
var chat_btn = document.getElementById('chatbtn');

function updateMsg(status, txt)
{
  if (status === 0) {  // XHR 通信失敗
    chat_elem_log.innerHTML = "XHR 通信失敗";
    return;
  }
  // XHR 通信成功
  if ((200 <= status && status < 300) || status === 304) {
    // リクエスト成功
    chat_elem_log.innerHTML = txt;
  } else {  // リクエスト失敗
    chat_elem_log.innerHTML = "その他の応答:" + status;
  }
}

function onChatUpdate() {
  var ajax = new XMLHttpRequest();
  if (ajax === null)
    return;
  ajax.open('POST', 'chat.rb?' + chat_id, true);
  ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  // ajax.send('');  // gets error with webrick
  ajax.send('dum=my');

  ajax.onreadystatechange = function () {
    switch (ajax.readyState) {
    case 4:
      updateMsg(ajax.status, ajax.responseText);
      setTimeout(function() {onChatUpdate();}, 60000);
      break;
    }
  };
}

onChatUpdate();

function buildMsg()
{
  var ret = 'action=say&'
  ret += '&chatmsg=' + encodeURIComponent(chat_elem_msg.value);
  return ret;
}

function onChatSay() {
  var ajax = new XMLHttpRequest();
  if (ajax === null)
    return;
  ajax.open('POST', 'chat.rb?'+chat_id, true);
  ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  ajax.send(buildMsg());
  chat_btn.disabled = true;
  chat_elem_msg.disabled = true;

  ajax.onreadystatechange = function () {
    switch (ajax.readyState) {
    case 4:
      updateMsg(ajax.status, ajax.responseText);
      chat_elem_msg.value = '';
      chat_btn.disabled = false;
      chat_elem_msg.disabled = false;
      break;
    }
  };
}
