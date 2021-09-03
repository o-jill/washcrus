var idx_mn = 1;
var newscontent;
var ajax = new XMLHttpRequest();
ajax.open('GET', './config/mqnews.js', true);
ajax.onreadystatechange = function() {
  if (ajax.readyState == 4 && ajax.status == 200) {
    newscontent = ajax.responseText.split("\n");
    newscontent = newscontent.filter(item => item);
    var date = new Date();
    idx_mn = Math.floor(date.getTime() * 0.001 / 30 + .5) % newscontent.length;
    document.getElementById('mqnews').innerHTML = newscontent[idx_mn];
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
