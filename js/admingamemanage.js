function receiveGame(st, txt)
{
  var elem = document.getElementById('matchinfo');
  elem.innerText = txt;
}

function retrieveGame()
{
  var gid = document.getElementById('gameid');
  var ajax = new XMLHttpRequest();
  if (ajax === null)
    return;
  ajax.open('POST', 'getmatchinfo.rb?' + gid, true);
  ajax.overrideMimeType('text/plain; charset=UTF-8');
  ajax.send('');

  ajax.onreadystatechange = function () {
    switch (ajax.readyState) {
    case 4:
      receiveGame(ajax.status, ajax.responseText, false);
      break;
    }
  };
  return false;
}
