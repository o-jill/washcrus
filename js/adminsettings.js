function use_url() {
  var full_url = location.href;
  var domain = location.host;
  var url = full_url.substring(0, full_url.indexOf('?'));
  var baseurl = url.substring(0, full_url.lastIndexOf('/')+1);

  document.getElementById('domain').value = domain;
  document.getElementById('base_url').value = baseurl;
}
