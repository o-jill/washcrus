/** 将棋盤の色(画像の時はtransparentにする) */
var banColor = 'transparent';
// var banColor = '#FDA';
/** マス目にカーソルが乗った時の色 */
var hoverColor = 'yellow';
/** 選択中のマス目の色 */
var activeColor = 'green';
/** 選択中の駒が指せるマス目の色 */
var movableColor = 'pink';

// var testKoma = new Fu(Koma.SENTEBAN);
// var testKoma = new Kaku(Koma.SENTEBAN);
// var testKoma = new Koma();

/** マウスの座標 */
var mouseposx;
/** マウスの座標 */
var mouseposy;

/** 成りメニュー要素 */
var narimenu;
/** 成りメニュー成り */
var narimenu_nari;
/** 成りメニュー不成り */
var narimenu_funari;
/** 成りメニュークリック待ち */
var wait_narimenu;
/** 成るマスの座標 */
var narimenu_tox;
/** 成るマスの座標 */
var narimenu_toy;

/** 着手確認ダイアログ */
var cfrmdlg;
var CFRM_UTSU = 0;  // 打つ
var CFRM_MOVE = 1;  // 動かす
var CFRM_MVCAP = 2;  // 動かして取る
var CFRM_RESIGN = 3;  // 投了

/** 棋譜情報出力欄 */
// var kifuArea;
/** 棋譜形式選択欄 */
// var kifuType;
/** 解析結果出力欄 */
// var analysisArea;
/** 先手の名前 */
var nameSente;
/** 後手の名前 */
var nameGote;

/** 対局中かどうか */
var taikyokuchu = false;

/** 選択中のマス目 */
var activemasu = null;

/** 選択中のマス目の見た目 */
var activemasui = null;

/** 選択中の駒 */
var activekoma = null;
/** 選択中の手駒欄 */
var activetegoma = null;
/** カーソルが乗っているマス目 */
var hovermasui = null;
/** アクティブな駒が指せるマス目のリスト */
var activemovable = [];

/** ひふみんアイ */
var hifumin_eye = false;

/** 最終手 筋 */
var last_mx = -1;
/** 最終手 段 */
var last_my = -1;

/** 対局終了 */
var isfinished = false;

function update_banindex_row(strtbl) {
  for (var i = 0 ; i < 9 ; ++i) {
    var row = document.getElementById('banrow'+(i+1));
    row.innerHTML = strtbl[i];
  }
}

function update_banindex() {
  var column = document.getElementById('bancolumn');
  var text = '';
  var numbersc = ['９', '８', '７', '６', '５', '４', '３', '２', '１'];
  /* var numbersc = Koma.ZenkakuNum;
  numbersc.reverse(); */
  numbersc.forEach(function(c) {
    text += '<th class="ban_suji_num">' + c + '</th>';
  });
  column.innerHTML = text + '<th>&nbsp;</th>';

  /* var numbersr = ['一', '二', '三', '四', '五', '六', '七', '八', '九'];*/
  update_banindex_row(Koma.KanjiNum);
}

function update_banindex_rotate() {
  var column = document.getElementById('bancolumn');
  /* var numbersc = ['１', '２', '３', '４', '５', '６', '７', '８', '９']; */
  var numbersc = Koma.ZenkakuNum;
  var text = '';
  numbersc.forEach(function(c) {
    text += '<th class="ban_suji_num">' + c + '</th>';
  });
  column.innerHTML = text + '<th>&nbsp;</th>';

  var numbersr = ['九', '八', '七', '六', '五', '四', '三', '二', '一'];
  /* var numbersr = Koma.KanjiNum;
  numbersr.reverse(); */
  update_banindex_row(numbersr);
}

function Naraberu_tegoma(tegoma, tegomaui)
{
  var sz = tegoma.length;
  for (var idx = 0; idx < sz; ++idx) {
    if (tegoma[idx][0].length === 0) {
      tegomaui[idx][1].el.style.visibility = 'hidden';
      tegomaui[idx][1].el2.style.visibility = 'hidden';
    } else {
      tegomaui[idx][1].el.style.visibility = 'visible';
      tegomaui[idx][1].el2.style.visibility = 'visible';
      tegomaui[idx][1].el2.innerHTML = tegoma[idx][0].length.toString();
    }
  }
}

/**
 * 最後に指したところに印をつける
 */
function Naraberu_lastmove(x, y)
{
  /* if (x < 0 || x > 8 || y < 0 || y > 9) */
  if (!Koma.onTheBan(x) || !Koma.onTheBan(y)) return;

  var el = ban[x][y].el;
  if (el === null) return;
  var text = '<div style="position:relative;">' + el.innerHTML;
  text += '<div style="position:absolute;left:0;top:0;">';
  text += '<img src="./image/dot16.png" class="lmmark"></div></div>';
  el.innerHTML = text;
}

function Naraberu_putkoma(el, koma, n123)
{
  var fn = koma.getImgStr(n123);
  el.innerHTML
    = (fn.length === 0) ? '&nbsp;' : '<img src="./image/' + fn + '.svg">';
}

function Naraberu_ban(i) {
  for (var j = 0; j < 9; ++j) {
    var koma = ban[i][j].koma;
    if (koma === null) continue;
    var el = ban[i][j].el;
    Naraberu_putkoma(el, koma, 0);
  }
}

/**
 * コマを並べる。
 */
function Naraberu() {
  for (var i = 0; i < 9; ++i) Naraberu_ban(i);

  // 最後に指したところに印をつける
  Naraberu_lastmove(last_mx, last_my);

  Naraberu_tegoma(sentegoma, sentegoma);
  Naraberu_tegoma(gotegoma, gotegoma);
}

function Naraberu_banr(i) {
  for (var j = 0; j < 9; ++j) {
    var koma = ban[8 - i][8 - j].koma;
    if (koma === null) continue;
    var el = ban[i][j].el;
    Naraberu_putkoma(el, koma, 1);
  }
}

/**
 * 逆さまにコマを並べる。
 */
function Naraberu_rotate() {
  for (var i = 0; i < 9; ++i) Naraberu_banr(i);

  // 最後に指したところに印をつける
  Naraberu_lastmove(8 - last_mx, 8 - last_my);

  Naraberu_tegoma(sentegoma, gotegoma);
  Naraberu_tegoma(gotegoma, sentegoma);
}

/**
 * 画面の更新
 */
function update_screen() {
  var sname = document.getElementById('sg_pname');
  var gname = document.getElementById('gg_pname');
  if (hifumin_eye) {
    update_banindex_rotate();
    Naraberu_rotate();

    sname.innerHTML = mykifu.gotename;
    gname.innerHTML = mykifu.sentename;
  } else {
    update_banindex();
    Naraberu();

    sname.innerHTML = mykifu.sentename;
    gname.innerHTML = mykifu.gotename;
  }
  // kifuArea.innerText = mykifu.kifuText;
}

/**
 * マウスの移動
 *
 * @param {Event} e マウスイベント
 */
function mousemove(e) {
  mouseposx = e.clientX;
  mouseposy = e.clientY;
}

function gethtmlelement_ban() {
  for (var i = 0 ; i < 9 ; ++i) {
    for (var j = 0 ; j < 9 ; ++j) {
      var strid = 'b' + (i+1) + (j+1);
      ban[i][j].el = document.getElementById(strid);
      ban[i][j].el.onclick = absclick;
      ban[i][j].el.onmouseover = abshoverin;
      ban[i][j].el.onmouseout = abshoverout;
    }
  }
}

function gethtmlelement_tegoma() {
  var kmtbl = ['fu', 'kyo', 'kei', 'gin', 'kin', 'kaku', 'hisha'];

  for (var i = 0 ; i < 7 ; ++i) {
    sentegoma[i][1].el = document.getElementById('sg_' + kmtbl[i] + '_img');
    sentegoma[i][1].el2 = document.getElementById('sg_' + kmtbl[i] + '_num');
    gotegoma[i][1].el = document.getElementById('gg_' + kmtbl[i] + '_img');
    gotegoma[i][1].el2 = document.getElementById('gg_' + kmtbl[i] + '_num');
  }
}

function ontegomaclick(event) {
  if (taikyokuchu === false) return;
  if (wait_narimenu) return;

  absclick_tegoma_ui(event.currentTarget.id);
}

function gethtmlelement_tegomaclick() {
  for (var i = 0 ; i < 7 ; ++i) {
    sentegoma[i][1].el.onclick = sentegoma[i][1].el2.onclick
      = gotegoma[i][1].el.onclick = gotegoma[i][1].el2.onclick
       = ontegomaclick;
  }
}

/**
 * ページ読み込み時に最初に呼ばれる
 */
function gethtmlelement() {
  document.onmousemove = mousemove;

  // 盤の設定
  gethtmlelement_ban();

  // 手駒の設定
  gethtmlelement_tegoma();
  gethtmlelement_tegomaclick();

  // 成り不成メニューの設定
  narimenu = document.getElementById('narimenu');
  narimenu_nari = document.getElementById('naru');
  narimenu_funari = document.getElementById('narazu');
  narimenu_nari.onclick = clicknari;
  narimenu_funari.onclick = clicknarazu;
  wait_narimenu = false;

  nameSente = document.getElementById('sentename');
  nameGote = document.getElementById('gotename');

  // confirm
  cfrmdlg = document.getElementById('movecfrm');
  var cfrmdlg_ok = document.getElementById('mvcfm_ok');
  cfrmdlg_ok.onclick = clickcfrm_ok;
  var cfrmdlg_cancel = document.getElementById('mvcfm_cancel');
  cfrmdlg_cancel.onclick = clickcfrm_cancel;

  // initKoma();
  // update_screen();
}

/**
 * カーソルが乗っているマスを強調する。
 * masuがnullなら元に戻す。
 *
 * @param {Object} masui 強調するマス目
 */
function hovercell(masui)
{
  if (masui === null) {
    if (hovermasui !== null) {
      hovermasui.style.backgroundColor = banColor;
    }
  } else {
    masui.style.backgroundColor = hoverColor;
  }
  hovermasui = masui;
}

/**
 * マスからカーソルが出た時に呼ばれる
 *
 * @param {Event} event マウスイベント
 */
function abshoverout(event) {
  /* var clickid = event.currentTarget.id;
  var x = +clickid.substring(1, 2)-1;
  var y = +clickid.substring(2, 3)-1; */

  // var masu = ban[x][y];
  hovercell(null);
  activatemovable(true);
}

/**
 * マスにカーソルが入った時に呼ばれる
 *
 * @param {Event} event マウスイベント
 */
function abshoverin(event) {
  var clickid = event.currentTarget.id;
  var x = +clickid.substring(1, 2)-1;
  var y = +clickid.substring(2, 3)-1;

  var masui = ban[x][y].el;

  hovercell(masui);
}

function fillactivemasu(x, y, c)
{
  var masui = ban[x][y].el;
  if (masui !== null) masui.style.backgroundColor = c;
}

/**
 * 移動可能なマスのハイライト制御
 *
 * @param {Boolean} b true:ハイライトする, false:ハイライトしない
 */
function activatemovable(b) {
  var c, sz, idx, x, y;

  c = b ? movableColor : banColor;

  sz = activemovable.length;
  for (idx = 0; idx < sz; ++idx) {
    x = activemovable[idx][0];
    y = activemovable[idx][1];
    if (hifumin_eye) {
      x = 8 - x;
      y = 8 - y;
    }
    fillactivemasu(x, y, c);
  }
}

/**
 * マスを選択状態表示にする。
 *
 * @param {Object} masui 対象のマス
 * @param {Boolean} b true:選択状態にする,false:選択状態を解除する
 */
function setactivecell(masui, b) {
  setborderstyle(masui, b, '2px solid ' + activeColor, '2px solid black');
}

function release_activemasu(masu) {
  if (activemasu === null) return;
  setactivecell(activemasui, false);
  if (activemasu !== masu) activatemovable(false);
}

/**
 * マスを選択状態にする。
 * masuがnullなら選択解除。
 *
 * @param {Object} koma  対象の駒
 * @param {Object} masu  対象のマス
 * @param {Object} masui 対象のマス目の見た目
 */
function activecell(koma, masu, masui) {
  release_activemasu(masu);

  if (masu === null) {
    activetegoma = null;
    activemasu = null;
    activemasui = null;
    activemovable = [];
    return;
  }

  activemasu = masu;
  activemasui = masui;
  activekoma = koma;

  setactivecell(masui, true);
  if (hifumin_eye) {
    activemovable = koma.getMovable(8 - masu.x, 8 - masu.y);
  } else {
    activemovable = koma.getMovable(masu.x, masu.y);
  }
  activatemovable(true);
}

function absclick_wo_active(koma, masu, masui) {
  // アクティブなマスはないので
  if ((koma.teban !== Koma.AKI) && (koma.teban === activeteban)) {
    // 自分の駒をクリックしたならアクティブにする。
    activecell(koma, masu, masui);
    // } else {
    // nothing to do
  }
}

function absclick_on_mypiece(koma, masu, masui) {
  // 自分の駒をクリックしたので非アクティブにする。
  if (activetegoma !== null) activeuchi(null, null, null);
  activecell(koma, masu, masui);
}

function deactivate_activecell() {
  if (activetegoma !== null) activeuchi(null, null, null);
  else activecell(null, null, null);
}

function check_activemovablemasu(hx, hy) {
  var sz = activemovable.length;
  for (var idx = 0; idx < sz; ++idx) {
    if (activemovable[idx][0] === hx && activemovable[idx][1] === hy)
      return true;
  }
  return false;
}

/**
 * 空きスペースをクリックした。
 *
 * @param {Number} hx 1~９筋(0~8)
 * @param {Number} hy 一~九段(0~8)
 */
function absclick_aki(hx, hy)
{
  var ismovable = check_activemovablemasu(hx, hy);
  if (ismovable === false) {
    // 選択キャンセル
    deactivate_activecell();
  } else {
    var msg = activekoma.movemsg(hx, hy);
    var md = (activemasu.x === -1) ? CFRM_UTSU : CFRM_MOVE;
    myconfirm(msg, md, hx, hy);
  }
}

/**
 * 相手の駒をクリックした。
 *
 * @param {Number} hx 1~９筋(0~8)
 * @param {Number} hy 一~九段(0~8)
 */
function absclick_opponent(hx, hy)
{
  var ismovable = check_activemovablemasu(hx, hy);
  if (ismovable === false) {
    // 選択キャンセル
    deactivate_activecell();
  } else {
    var msg = activekoma.movemsg(hx, hy);
    myconfirm(msg, CFRM_MVCAP, hx, hy);
  }
}

/**
 * マスをクリックした時に呼ばれる。
 *
 * @param {Event} event クリックイベント
 */
function absclick(event) {
  if (taikyokuchu === false) return;
  if (wait_narimenu) return;

  var clickid = event.currentTarget.id;
  var x = +clickid.substring(1, 2)-1;
  var y = +clickid.substring(2, 3)-1;

  var hx = x;  // 1~９筋(0~8)
  var hy = y;  // 一~九段(0~8)
  if (hifumin_eye) {
    hx = 8 - hx;
    hy = 8 - hy;
    // } else {
  }
  var koma = ban[hx][hy].koma;
  var masu = ban[x][y];

  absclick_ban(hx, hy, koma, masu);
}

/**
 * 盤をクリックした時に呼ばれる。
 *
 * @param  {Number} hx   1~９筋(0~8)
 * @param  {Number} hy   一~九段(0~8)
 * @param  {Object} koma Komaオブジェクト
 * @param  {Object} masu Masuオブジェクト
 */
function absclick_ban(hx, hy, koma, masu) {
  var masui = masu.el;
  if (activemasu === null) {
    // アクティブなマスはないので
    // 自分の駒をクリックしたならアクティブにする。
    absclick_wo_active(koma, masu, masui);
  } else if (activemasu === masu) {
    // アクティブなマスをクリックしたので非アクティブにする。
    activecell(null, null, null);
  } else if (activekoma.teban === koma.teban) {
    // 自分の駒をクリックしたので非アクティブにする。
    absclick_on_mypiece(koma, masu, masui);
  } else if (koma.teban === Koma.AKI) {
    // 空きマスをクリックした
    absclick_aki(hx, hy);
  } else {
    // 相手の駒をクリックした
    absclick_opponent(hx, hy);
  }
}

function setborderstyle(masui, b, stlt, stlf) {
  masui.style.border = b ? stlt : stlf;
}

/**
 * 手駒のマスを選択状態表示にする。
 *
 * @param {Object} masui 対象のマス
 * @param {Boolean} b true:選択状態にする,false:選択状態を解除する
 */
function setactivecelluchi(masui, b) {
  setborderstyle(masui, b, '2px solid ' + activeColor, '0px solid black');
}

function release_uchi(tegoma, i)
{
  let result = tegoma === null || (activekoma !== null && activekoma.id === i);
  if (result) {
    activetegoma = null;
    activemasu = null;
    activemovable = [];
    activekoma = null;
  }
  return result;
}

/**
 * 打ちたい手駒をアクティブ表現にする。
 * tegomaがnullの時はアクティブを消す。
 *
 * @param {Koma} koma 先手/後手の駒
 * @param {Array} tegoma 先手/後手の手駒
 * @param {Array} tegomasu 先手/後手の手駒エリア
 * @param {Number} i 駒のID
 */
function activeuchi(koma, tegoma, tegomasu, i) {
  if (activetegoma !== null) {
    if (activemasu !== null) setactivecelluchi(activemasui, false);
    activatemovable(false);
  }
  if (release_uchi(tegoma, i)) return;

  var masu = tegomasu[i][1];
  var masui = tegomasu[i][1].el;
  // var koma = tegoma[i][0][tegoma[i][0].length - 1];

  activetegoma = tegoma;
  activemasu = masu;
  activemasui = masui;
  activekoma = koma;

  setactivecelluchi(masui, true);
  activemovable = koma.getUchable(ban);
  activatemovable(true);
}

/**
 * 手駒をアクティブ表示にしたりする
 *
 * @param  {[type]} i        駒番号0:歩~6:飛車
 * @param  {[type]} tegoma   手駒
 * @param  {[type]} tegomaui 手駒UI
 */
function absclick_tegoma(i, tegoma, tegomaui) {
  if (activemasu !== null) {
    if (activetegoma === null) activecell(null, null, null);
  }
  var koma = tegoma[i][0][tegoma[i][0].length - 1];
  if (koma === undefined) return;

  activeuchi(koma, tegoma, tegomaui, i);
}

/**
 * 手駒をクリックした
 *
 * @param {Number} i 駒ID
 * @param {Boolean} bgote 後手ならtrue
 * @param {Object} ui 手駒のUI element
 */
function absclick_tegoma_sg(i, bgote, ui) {
  var mytegoma, myteban;
  var ui_sen = hifumin_eye ^ bgote;
  if (ui_sen) {
    myteban = Koma.GOTEBAN;
    mytegoma = gotegoma;
  } else {
    myteban = Koma.SENTEBAN;
    mytegoma = sentegoma;
  }

  if (activeteban !== myteban) return;

  absclick_tegoma(i, mytegoma, ui);
}

/**
 * 手駒をクリックした
 *
 * @param  {[type]} id html element ID
 */
function absclick_tegoma_ui(id) {
  var kmtbl = ['fu', 'kyo', 'kei', 'gin', 'kin', 'kaku', 'hisha'];

  var id_sub = id.substring(0, id.length-4);
  for (var i = 0 ; i < 7 ; ++i) {
    var str = 'sg_' + kmtbl[i];
    if (str === id_sub) {
      absclick_tegoma_sg(i, false, sentegoma);
      return;
    }
    str = 'gg_' + kmtbl[i];
    if (str === id_sub) {
      absclick_tegoma_sg(i, true, gotegoma);
      return;
    }
  }
}

/**
 * 成り選択メニューを出す
 *
 * @param {Number} x 座標[ピクセル]
 * @param {Number} y 座標[ピクセル]
 */
function popupnari(x, y) {
  narimenu.style.visibility = 'visible';
  wait_narimenu = true;
}

function move_byclick_narinarazu(nari)
{
  move(activekoma, {x: narimenu_tox, y: narimenu_toy}, nari);
  activecell(null, null);

  wait_narimenu = false;
  narimenu.style.visibility = 'hidden';
  update_screen();
  record_your_move();
}

/**
 * 駒を成る
 */
function clicknari() {
  move_byclick_narinarazu(Koma.NARI);
}

/**
 * 駒を成らない
 */
function clicknarazu() {
  move_byclick_narinarazu(Koma.NARAZU);
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

function clickcfrm_ok_move(hx, hy)
{
  hxy = {x: hx, y: hy};
  // toru(取らないけど)
  toru(hxy);

  // move
  var nareru = activekoma.checkNari(activekoma.y, hy);
  if (nareru === Koma.NARENAI /*|| nareru === Koma.NATTA*/) {
    move(activekoma, hxy, Koma.NARAZU);
    activecell(null, null, null);
    update_screen();
    record_your_move();
  } else if (nareru === Koma.NARU) {
    move(activekoma, hxy, Koma.NARI);
    activecell(null, null);
    update_screen();
    record_your_move();
  } else if (nareru === Koma.NARERU) {
    // ユーザに聞く
    narimenu_tox = hx;
    narimenu_toy = hy;
    popupnari(mouseposx, mouseposy);
  }
}

function clickcfrm_ok_capmove(hx, hy)
{
  hxy = {x: hx, y: hy};
  // toru and move
  // toru
  toru(hxy);

  // move
  var nareru = activekoma.checkNari(activekoma.y, hy);
  if (nareru === Koma.NARENAI /*|| nareru === Koma.NATTA*/) {
    move(activekoma, hxy, Koma.NARAZU);
    activecell(null, null, null);
    update_screen();
    record_your_move();
  } else if (nareru === Koma.NARU) {
    move(activekoma, hxy, Koma.NARI);
    activecell(null, null, null);
    update_screen();
    record_your_move();
  } else if (nareru === Koma.NARERU) {
    // ユーザに聞く
    narimenu_tox = hx;
    narimenu_toy = hy;
    popupnari(mouseposx, mouseposy);
  }
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
    clickcfrm_ok_move(hx, hy);
  } else if (cfrmdlg.md === CFRM_MVCAP) {
    clickcfrm_ok_capmove(hx, hy);
  } else if (cfrmdlg.md === CFRM_RESIGN) {
    // 投了
    movecsa = '%TORYO';
    send_csamove();
  }
}

/**
 * 着手確認ダイアログのCancelを押した
 */
function clickcfrm_cancel() {
  if (cfrmdlg.md === CFRM_UTSU) {
    // 駒打ちをやめる
    activeuchi(null, null, null);
  } else if (cfrmdlg.md === CFRM_MOVE || cfrmdlg.md === CFRM_MVCAP) {
    // 駒の移動をやめる
    activecell(null, null, null);
    /* } else if (cfrmdlg.md === CFRM_RESIGN) { */
  }

  cfrmdlg.style.visibility = 'hidden';
}

/* *
 * 新規対局
 *
function new_kyoku() {
  mykifu.reset();
  initKoma();
  taikyokuchu = false;
  activeteban = Koma.SENTEBAN;
  update_screen();
}*/

// タイマのID
/*var taikyokuchu_timer;
// タイマが使うデータ
var taikyokuchu_param = 0;

function taikyokuchu_tmout()
{
  ++taikyokuchu_param;
  taikyokuchu_param %= 255;
  var c = 255 - taikyokuchu_param;
  nameSente.style.backgroundColor = 'rgb(255,' + c + ',255)';
  nameGote.style.backgroundColor = 'rgb(' + c + ',255,' + c + ')';
}*/

/* *
 * 対局始め
 *
function start_kyoku() {
  if (taikyokuchu === true) {
    return;
  }
  taikyokuchu = true;
  // activeteban = Koma.SENTEBAN;
  // mykifu.putHeader(nameSente.value, nameGote.value);
  update_screen();
  taikyokuchu_timer = setInterval(function() {taikyokuchu_tmout();}, 500);
}

/* *
 * 対局中断
 *
function stop_kyoku() {
  if (taikyokuchu === false) {
    return;
  }
  taikyokuchu = false;
  update_screen();
  clearInterval(taikyokuchu_timer);
}*/

/* *
 * 投了
 *
function giveup() {
  if (taikyokuchu === false) {
    return;
  }
  taikyokuchu = false;
  mykifu.putFooter(Koma.SENTEBAN);
  update_screen();
  clearInterval(taikyokuchu_timer);
}*/

/**
 * 現局面の出力
 */
// function current_status() {
//  kifuArea.innerText = KyokumenKIF() + KyokumenCSA();
// }

/**
 * 1手進める
 */
// function kanso_next() {
//  if (taikyokuchu === true) {
//   return;
//  }
//  mykifu.next_te();
//  update_screen();
// }

/**
 * 1手戻す
 */
// function kanso_prev() {
//  if (taikyokuchu === true) {
//   return;
//  }
//  mykifu.prev_te();
//  update_screen();
// }

/**
 * 5手進める
 */
// function kanso_next2() {
//  if (taikyokuchu === true) {
//   return;
//  }
//  mykifu.seek_te(mykifu.NTeme + 5);
//  update_screen();
// }

/**
 * 5手戻す
 */
// function kanso_prev2() {
//  if (taikyokuchu === true) {
//   return;
//  }
//  mykifu.seek_te(mykifu.NTeme - 5);
//  update_screen();
// }

/**
 * 初手に戻す
 */
// function kanso_opened() {
//  if (taikyokuchu === true) {
//   return;
//  }
//  mykifu.shote();
//  update_screen();
// }

/**
 * 最新の局面にする。
 */
// function kanso_last() {
//  if (taikyokuchu === true) {
//   return;
//  }
//  mykifu.last_te();
//  update_screen();
// }

/**
 * ひふみんEyeを切り替える
 */
function check_hifumin_eye() {
  // アクティブなやつを解除。
  if (activemasu !== null) {
    if (activemasu.x === -1) {
      // uchi
      activeuchi(null, null, -1);
    } else {
      activecell(null, null, null);
    }
  }
  hifumin_eye = document.getElementById('hifumineye').checked;
  update_screen();
}

function turn_taikyoku_on()
{
  // String('true') or String('false')
  var strfinished = document.getElementById('isfinished').value;
  isfinished = (strfinished !== 'false');  // convert to boolean

  if (isfinished) {
    taikyokuchu = false;
    return;
  }
  // var teban = document.getElementById('myturn').value;
  // if (teban !== '0') taikyokuchu = true;
  var teban = document.getElementById('myteban').value;
  if (teban === 'b' && activeteban === Koma.SENTEBAN) taikyokuchu = true;
  else if (teban === 'w' && activeteban === Koma.GOTEBAN) taikyokuchu = true;
  else taikyokuchu = false;
}

function activateteban()
{
  turn_taikyoku_on();

  var strinfo = mykifu.NTeme + '手目です。<BR>';
  if (activeteban === Koma.SENTEBAN) {
    strinfo += '先手の手番です。<BR>'
  } else if (activeteban === Koma.GOTEBAN) {
    strinfo += '後手の手番です。<BR>'
  } else {
    strinfo += '対局は終了/中断しました。<BR>'
  }
  document.getElementById('tebaninfo').innerHTML = strinfo;

  /* resign button */
  document.getElementById('btn_resign').style.display
      = (taikyokuchu) ? 'inline' : 'none';
}

function checkSfenResponse(sfenstr)
{
  // ERROR
  if (sfenstr.match(/^ERROR:/)) return;

  var oldsfen = document.getElementById('sfen_').innerHTML;
  if (sfenstr !== oldsfen) {
    document.getElementById('notify_area').style.display = 'inline';
  } else {
    startUpdateTimer();
  }
}

function startUpdateTimer()
{
  setTimeout(function() {checkLatestMoveTmout();}, 60000);
}

function checkLatestMoveTmout_recv(ajax)
{
  if (ajax.readyState != 4) return;

  var status = ajax.status;
  if (status === 0) {  // XHR 通信失敗
    //  msg.innerHTML += 'XHR 通信失敗\n自動的にリロードします。';
    //   location.reload(true);
    startUpdateTimer();
  } else if ((200 <= status && status < 300) || status === 304) {
    // XHR 通信成功, リクエスト成功
    var resp = ajax.responseText
    checkSfenResponse(resp);
    // msg.innerHTML = '通信完了。\n自動的にリロードします。';
    // location.reload(true);
  } else {    // XHR 通信成功, リクエスト失敗
    // msg.innerHTML += 'その他の応答:" + status + "\n自動的にリロードします。';
    // location.reload(true);
    startUpdateTimer();
  }
}

function checkLatestMoveTmout()
{
  var elem_id = document.getElementById('gameid');
  var gid = elem_id.value;

  var ajax = new XMLHttpRequest();
  if (ajax === null) return;
  // tsushinchu = true;
  // activatefogscreen();
  ajax.open('POST', 'getsfen.rb?' + gid, true);
  ajax.overrideMimeType('text/plain; charset=UTF-8');
  ajax.send('');
  ajax.onreadystatechange = function() {
    // tsushinchu = false;
    // var msg = document.getElementById('msg_fogscreen');
    checkLatestMoveTmout_recv(ajax);
  };
}

/**
 * 最終着手マスの読み込み
 */
function read_lastmove()
{
  /* e.g. -9300FU */
  var str = document.getElementById('lastmove').value;

  var x = parseInt(str.charAt(3), 10);  /* e.g. '9' -> 9 */
  var y = parseInt(str.charAt(4), 10);  /* e.g. '3' -> 3 */

  if (isNaN(x)) x = 0;
  if (isNaN(y)) y = 0;

  last_mx = x-1;
  last_my = y-1;
}

/**
 * 主にゼロパドした数字の文字列を返す。
 */
var padding = function(n, d, p) {
    p = p || '0';
    return (p.repeat(d) + n).slice(-d);
};

/**
 * 時刻文字列を返す。
 * ex. 9999/12/31 23:59:59
 */
function dateToFormatString(date) {
  var pad = '0';
  return padding(date.getFullYear(), 4, pad) + '/'
    + padding(date.getMonth() + 1, 2, pad) + '/'
    + padding(date.getDate(), 2, pad) + ' '
    + padding(date.getHours(), 2, pad) + ':'
    + padding(date.getMinutes(), 2, pad) + ':'
    + padding(date.getSeconds(), 2, pad);
}

/**
 * ミリ秒をわかりやすい表記に直す。
 * ex. 9d 23:59:59
 */
function msec2DHMS(ms) {
  var days = Math.floor(ms / 3600000 / 24);
  var hours = Math.floor(ms / 3600000) % 24;
  var minutes = Math.floor(ms / 60000) % 60;
  var seconds = Math.floor(ms / 1000) % 60;
  return days + 'd '
    + [padding(hours, 2), padding(minutes, 2), padding(seconds, 2)].join(':');
}

/**
 * 相手が指してからの時間を表示する。
 */
function updatecurtime() {
  var ellmtm = document.getElementById('lmtm');
  var lmtm = new Date(ellmtm.innerText);
  var now = new Date();
  var diff = now - lmtm;
  var nowstr = '(' + msec2DHMS(diff) + ')';
  // var nowstr = '(' + dateToFormatString(new Date()) + ')';
  var st = document.getElementById('sentetime');
  if (st) st.innerHTML = nowstr;
  var gt = document.getElementById('gotetime');
  if (gt) gt.innerHTML = nowstr;
}

/**
 * 相手が指してからの時間を表示するのを１秒おきに行う。
 */
function startCurTimer()
{
  setTimeout(
    function() {
      updatecurtime();
      startCurTimer();
    },
    1000);
}

/**
 * sfenを読み込んで指せる状態にする。
 */
function init_board() {
  gethtmlelement();
  mykifu.reset();

  var sname = document.getElementById('sg_pname');
  var gname = document.getElementById('gg_pname');
  mykifu.gotename = gname.innerHTML;
  mykifu.sentename = sname.innerHTML;

  var sfentext = document.getElementById('sfen_').innerHTML;
  fromsfen(sfentext);

  read_lastmove();

  activateteban();

  if (!isfinished) {
    startUpdateTimer();
    startCurTimer();
  }

  hifumin_eye = document.getElementById('hifumineye').checked;

  update_screen();
}

document.addEventListener( 'DOMContentLoaded', function() {
  init_board();
}, false );

function buildMoveMsg()
{
  var ret = 'sfen=' + encodeURIComponent(
    document.getElementById('sfen_').innerHTML);
  // ret = 'sfen=' + encodeURIComponent(document.getElementById('sfen').value);
  ret += '&jsonmove=' + encodeURIComponent(movecsa);

  return ret;
}

var tsushinchu = false;

function send_csamove_resp(status)
{
  var msg = document.getElementById('msg_fogscreen');
  if (status === 0) {  // XHR 通信失敗
    msg.innerHTML += 'XHR 通信失敗\n自動的にリロードします。';
    location.reload(true);
    return;
  }
  // XHR 通信成功
  if ((200 <= status && status < 300) || status === 304) {
    // リクエスト成功
    msg.innerHTML = '通信完了。<br>自動的にリロードします。';
    location.reload(true);
  } else {  // リクエスト失敗
    msg.innerHTML += 'その他の応答:' + status + '<br>自動的にリロードします。';
    location.reload(true);
  }
}

function send_csamove()
{
  var elem_id = document.getElementById('gameid');
  var gid = elem_id.value;

  var ajax = new XMLHttpRequest();
  if (ajax === null) return;

  tsushinchu = true;
  activatefogscreen();
  ajax.open('POST', 'move.rb?' + gid, true);
  ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  ajax.send(buildMoveMsg());
  ajax.onreadystatechange = function() {
    tsushinchu = false;
    switch (ajax.readyState) {
    case 4:
      send_csamove_resp(ajax.status);
      break;
    }
  };
}

function record_your_move()
{
  taikyokuchu = false;

  var nteme = mykifu.NTeme;
  // nteme = document.getElementById('nthmove').innerHTML;
  // var sfenarea = document.getElementById('sfen');
  // sfenarea.value = sfentext;
  var sfenarea = document.getElementById('sfen_');
  sfenarea.innerHTML = gensfen(nteme);

  send_csamove();
}

function activatefogscreen()
{
  var block_elem_ban = document.getElementById('block_elem_ban');
  var scr = document.getElementById('fogscreen');
  scr.style.zIndex = 0;
  scr.style.visibility = 'visible';
  scr.style.left = block_elem_ban.style.left;
  scr.style.top = block_elem_ban.style.top;
  scr.style.width = block_elem_ban.style.width;
  scr.style.clientHeight = block_elem_ban.style.clientHeight;

  var msgscr = document.getElementById('msg_fogscreen');
  msgscr.style.zIndex = 0;
  msgscr.style.visibility = 'visible';
}

/**
 * ページから抜ける時に確認
 *
 * @param {Event} e イベント
 *
 * @return {String} ページから抜ける時に表示する文字
 */
window.onbeforeunload = function(e) {
  if (tsushinchu === false) return;
  return '通信中に終了すると指し手が登録されない恐れがあります。\n終了しますか？';
};

function openurlin_blank(url) {
  var win = window.open(url, '_blank');
  win.focus();
}

function openurl_widthhash(url) {
  var cururl = window.location.search;
  var elem = cururl.split('/');
  var tgt = url + elem[1];
  var win = window.open(tgt, '_blank');
  win.focus();
}

function dl_kifu_file() {
  openurl_widthhash("index.rb?dlkifu/");
}

function open_kifu_player() {
  openurl_widthhash("dynamickifu.html?");
}

function onresign() {
  myconfirm("負けを認めますか？", CFRM_RESIGN, -1, -1);
  /* if (!confirm()) return;

  movecsa = '%TORYO';
  send_csamove(); */
}
