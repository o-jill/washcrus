/** 着手確認ダイアログ */
var cfrmdlg;
var CFRM_UTSU = 0;  // 打つ
var CFRM_MOVE = 1;  // 動かす
/* var CFRM_MVCAP = 2;  // 動かして取る */
var CFRM_RESIGN = 3;  // 投了
var CFRM_SUGDRAW = 4;  // 引き分け提案

function confirmdlginit()
{
  cfrmdlg = document.getElementById('movecfrm');
  var cfrmdlg_ok = document.getElementById('mvcfm_ok');
  cfrmdlg_ok.onclick = clickcfrm_ok;
  var cfrmdlg_cancel = document.getElementById('mvcfm_cancel');
  cfrmdlg_cancel.onclick = clickcfrm_cancel;
}

/**
 * 着手確認ダイアログの表示
 * @param  {String} msg  メッセージ
 * @param  {[type]} type 0:打つとき, 1:動かすだけの時, 2:駒をとって動かすとき
 */
function myconfirm(msg, type, hx, hy) {
  var msgui = document.getElementById('msg_movecfrm');
  msgui.innerText = msg;
  cfrmdlg.md = type;
  cfrmdlg.hx = hx;
  cfrmdlg.hy = hy;
  cfrmdlg.style.visibility = 'visible';
}

/**
 * 着手確認ダイアログのOKを押した
 */
function clickcfrm_ok() {
  var hx = cfrmdlg.hx;
  var hy = cfrmdlg.hy;

  cfrmdlg.style.visibility = 'hidden';

  if (cfrmdlg.md === CFRM_UTSU) {
    uchi(activetegoma, activekoma, {x: hx, y: hy});
    activeuchi(null, null, -1);
    update_screen();
    record_your_move();
  } else if (cfrmdlg.md === CFRM_MOVE) {
    clickcfrm_move(hx, hy);
  } else if (cfrmdlg.md === CFRM_RESIGN) {
    /* 投了 */
    movecsa = '%TORYO';
    send_csamove();
  } else if (cfrmdlg.md === CFRM_SUGDRAW) {
    send_drawsuggestion('YES');
  }
}

/**
 * 着手確認ダイアログのCancelを押した
 */
function clickcfrm_cancel() {
  if (cfrmdlg.md === CFRM_UTSU) {
    /* 駒打ちをやめる */
    activeuchi(null, null, null);
  } else if (cfrmdlg.md === CFRM_MOVE) {
    /* 駒の移動をやめる */
    activecell(null, null, null);
    /* } else if (cfrmdlg.md === CFRM_RESIGN) { */
  } else if (cfrmdlg.md === CFRM_SUGDRAW) {
    send_drawsuggestion('NO');
  }

  cfrmdlg.style.visibility = 'hidden';
}
