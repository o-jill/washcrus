var idx_mn = 1;
var newscontent;
var ajax = new XMLHttpRequest();
ajax.open('GET', './config/mqnews.js', true);
ajax.onreadystatechange = function() {
  if (ajax.readyState == 4 && ajax.status == 200) {
    newscontent = ajax.responseText.split("\n");
    newscontent = newscontent.filter(item => item);
    document.getElementById('mqnews').innerHTML = newscontent[0];
    setInterval(
      function() {
        document.getElementById('mqnews').innerHTML = newscontent[idx_mn];
        ++idx_mn;
        idx_mn %= newscontent.length;
        },
      30000
    );
  }
}
ajax.send(null);
