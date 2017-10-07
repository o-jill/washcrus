function check_loggedin()
{
  var loggedin = document.getElementById('isloggedin').value;
  var signup = document.getElementById('signup');
  var signin = document.getElementById('signin');
  if (loggedin === 1) {
    signup.style.backgroundColor = 'transparent';
    signin.style.backgroundColor = 'transparent';
  } else {
    signup.style.backgroundColor = 'green';
    signin.style.backgroundColor = 'blue';
  }
}
check_loggedin();
