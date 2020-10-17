function receiveGame(st, txt)
{
  var elem = document.getElementById('matchinfo');
  elem.innerText = txt;
}

function retrieveGame()
{
  var gid = document.getElementById('gameid').value;
  var ajax = new XMLHttpRequest();
  if (ajax === null)
    return;
  ajax.open('POST', 'getmatchinfo.rb?' + gid, true);
  ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  // ajax.send('');  // gets error with webrick
  ajax.send('dum=my');

  ajax.onreadystatechange = function () {
    switch (ajax.readyState) {
    case 4:
      receiveGame(ajax.status, ajax.responseText, false);
      break;
    }
  };
  return false;
}
