var popupshow = false;
function pntyou(e) {
  var elem = document.getElementById('menu_popup');
  var elemy = document.getElementById('menu_parent_popup');
  if (popupshow) {
    elem.style.visibility = 'hidden';
    elem.style.display = 'none';
  } else {
    elem.style.visibility = 'visible';
    elem.style.display = 'block';
    var rect = elemy.getBoundingClientRect();
    elem.style.left = rect.left + 'px';
    elem.style.top = rect.top + elemy.clientHeight + 'px';
  }
  popupshow = !popupshow;
}
var popupel = document.getElementById('menu_parent_popup');
if (popupel.onpointerdown) {
  popupel.onpointerdown = pntyou;
} else {
  popupel.onclick = pntyou;
}
