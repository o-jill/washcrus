function check_form()
{
  var nmismatch = 0;

  var name;
  name = document.getElementById('player1');
  if (name.value.length < 4) {
    ++nmismatch;
  }
  name = document.getElementById('player2');
  if (name.value.length < 4) {
    ++nmismatch;
  }

  var date;
  date = document.getElementById('time_frame_from');
  if (!date.value.match(/\d{4}[/-](0[1-9]|1[0-2])[/-](0[1-9]|1\d|3[0-1])/)) {
    ++nmismatch;
  }
  date = document.getElementById('time_frame_to');
  if (!date.value.match(/\d{4}[/-](0[1-9]|1[0-2])[/-](0[1-9]|1\d|3[0-1])/)) {
    ++nmismatch;
  }

  if (nmismatch === 4) {
    document.getElementById('errmsg').innerText = 'please put some information!!';
  } else {
    document.forms['searchform'].submit();
  }
}
