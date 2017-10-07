var elem_id = document.getElementById('gameid');
var id = elem_id.value;

var elem_log = document.getElementById('chatlog');
var elem_nm = document.getElementById('chatname');
var elem_msg = document.getElementById('chatmsg');
var btn = document.getElementById('chatbtn');

function onChatUpdate() {
  var ajax = new XMLHttpRequest();
  if (ajax !== null) {
    ajax.open('POST', 'chat.rb?'+id, true);
    ajax.overrideMimeType('text/plain; charset=UTF-8');
    ajax.send('');

    ajax.onreadystatechange = function () {
      switch (ajax.readyState) {
      case 4:
        var status = ajax.status;
    	if (status === 0) {  // XHR 通信失敗
    	  elem_log.innerHTML = "XHR 通信失敗";
    	} else {  // XHR 通信成功
          if ((200 <= status && status < 300) || status === 304) {
            // リクエスト成功
            elem_log.innerHTML = ajax.responseText
    	  } else {  // リクエスト失敗
    		elem_log.innerHTML = "その他の応答:" + status;
    	  }
    	}
        setTimeout("onChatUpdate()", 60000);
    	break;
      }
    };
    ajax.onload = function(e) {
      utf8text = ajax.responseText;
    };
  }
}

onChatUpdate();

function buildMsg()
{
    ret = 'action=say&'
    ret += 'chatname=' + encodeURIComponent(elem_nm.value);
    ret += '&chatmsg=' + encodeURIComponent(elem_msg.value);
    return ret;
}

function onChatSay() {
  var ajax = new XMLHttpRequest();
  if (ajax !== null) {
    ajax.open('POST', 'chat.rb?'+id, true);
    ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    ajax.send(buildMsg());
    btn.disabled = true;
    elem_msg.disabled = true;

    ajax.onreadystatechange = function () {
      switch (ajax.readyState) {
      case 4:
        var status = ajax.status;
    	if (status === 0) {  // XHR 通信失敗
    	  elem_log.innerHTML = "XHR 通信失敗";
    	} else {  // XHR 通信成功
          if ((200 <= status && status < 300) || status === 304) {
            // リクエスト成功
            elem_log.innerHTML = ajax.responseText
            elem_msg.value = '';
    	  } else {  // リクエスト失敗
    		elem_log.innerHTML = "その他の応答:" + status;
    	  }
    	}
        btn.disabled = false;
        elem_msg.disabled = false;
        // setTimeout("onChatUpdate()", 60000);
    	break;
      }
    };
    ajax.onload = function(e) {
      utf8text = ajax.responseText;
    };
  }
}
