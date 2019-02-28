function checkname(id)
{
  var name;
  name = document.getElementById(id);
  if (name.value.length < 4) {
    return 1;
  }
  return 0;
}

function checkdate(id)
{
  var date;
  date = document.getElementById(id);
  if (!date.value.match(/\d{4}[/-](0[1-9]|1[0-2])[/-](0[1-9]|1\d|3[0-1])/)) {
    return 1;
  }
  return 0;
}

function check_form()
{
  var nmismatch = 0;

  nmismatch += checkname('player1');
  nmismatch += checkname('player2');

  nmismatch += checkdate('time_frame_from');
  nmismatch += checkdate('time_frame_to');

  if (nmismatch === 4) {
    document.getElementById('errmsg').innerText = 'please put some information!!';
  } else {
    document.forms['searchform'].submit();
  }
}
