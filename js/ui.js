/**
 * ban: 将棋盤の色(画像の時はtransparentにする)
 * hover: マス目にカーソルが乗った時の色
 * active: 選択中のマス目の色
 * movable: 選択中の駒が指せるマス目の色
 */
var banColor = {
  ban: 'transparent', hover: 'yellow', active: 'green', movable: 'pink'
};
// var banColor = '#FDA';

// var testKoma = new Fu(Koma.SENTEBAN);
// var testKoma = new Kaku(Koma.SENTEBAN);
// var testKoma = new Koma();

/** マウスの座標 */
var mousepos = {x: 0, y: 0};

/**
 * menu: 成りメニュー要素
 * nari: 成りメニュー成り
 * funari: 成りメニュー不成り
 * wait: 成りメニュークリック待ち
 * toxy: 成るマスの座標
 */
var narimenu = {menu: null, nari: null, funari: null, toxy: null, wait: false};

/** 棋譜情報出力欄 */
// var kifuArea;
/** 棋譜形式選択欄 */
// var kifuType;
/** 解析結果出力欄 */
// var analysisArea;
/** 先手の名前 後手の名前 のエレメント*/
var namee = {sen: '', go: ''};

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
var last_mxy = {x: -1, y: -1};

/** 対局終了 */
var isfinished = false;

function update_banindex_row(strtbl) {
  for (var i = 0 ; i < 9 ; ++i) {
    var row = document.getElementById('banrow'+(i+1));
    row.innerHTML = strtbl[i];
  }
}

function update_banindex_col(numbersc)
{
  var column = document.getElementById('bancolumn');
  var list = numbersc.map(function(c) {
    return '<th class="ban_suji_num">' + c + '</th>';
  });
  column.innerHTML = list.join('') + '<th>&nbsp;</th>';
}

function update_banindex() {
  //  var numbersc = ['９', '８', '７', '６', '５', '４', '３', '２', '１'];
  update_banindex_col(Koma.ZenkakuNum.slice().reverse());
  /* var numbersr = ['一', '二', '三', '四', '五', '六', '七', '八', '九'];*/
  update_banindex_row(Koma.KanjiNum);
}

function update_banindex_rotate() {
  /* var numbersc = ['１', '２', '３', '４', '５', '６', '７', '８', '９']; */
  update_banindex_col(Koma.ZenkakuNum);
  //var numbersr = ['九', '八', '七', '六', '五', '四', '三', '二', '一'];
  update_banindex_row(Koma.KanjiNum.slice().reverse());
}

function Naraberu_tegoma(tegoma, tegomaui)
{
  tegoma.forEach(function(elem, idx){
    var visi = (elem[0].length !== 0) ? 'visible' : 'hidden';
    tegomaui[idx][1].el.style.visibility = visi;
    tegomaui[idx][1].el2.style.visibility = visi;
    if (elem[0].length !== 0) {
      tegomaui[idx][1].el2.innerHTML = elem[0].length.toString();
    }
  });
}

/**
 * 最後に指したところに印をつける
 */
function Naraberu_lastmove(xy)
{
  /* if (x < 0 || x > 8 || y < 0 || y > 9) */
  if (!Koma.onTheBan(xy.x) || !Koma.onTheBan(xy.y)) return;

  var el = ban[xy.x][xy.y].el;
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

/**
 * コマを並べる。
 */
function Naraberu() {
  for (var i = 0; i < 9; ++i) {
    ban[i].forEach(function(elem) {
      var koma = elem.koma, el = elem.el;
      if (koma !== null) Naraberu_putkoma(el, koma, false);
    });
  }

  /* 最後に指したところに印をつける */
  Naraberu_lastmove(last_mxy);

  Naraberu_tegoma(sentegoma, sentegoma);
  Naraberu_tegoma(gotegoma, gotegoma);
}

/**
 * 逆さまにコマを並べる。
 */
function Naraberu_rotate() {
  for (var i = 0; i < 9; ++i) {
    ban[8 - i].slice().reverse().forEach(function(elem, idx) {
      var koma = elem.koma, el = ban[i][idx].el;
      if (koma !== null) Naraberu_putkoma(el, koma, true);
    });
  }

  /* 最後に指したところに印をつける */
  Naraberu_lastmove({x: 8 - last_mxy.x, y: 8 - last_mxy.y});

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
  /* kifuArea.innerText = mykifu.kifuText; */
}

/**
 * マウスの移動
 *
 * @param {Event} e マウスイベント
 */
function mousemove(e) {
  mousepos = {x: e.clientX, y: e.clientY};
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
  if (narimenu.wait) return;

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

  /* 盤の設定 */
  gethtmlelement_ban();

  /* 手駒の設定 */
  gethtmlelement_tegoma();
  gethtmlelement_tegomaclick();

  /* 成り不成メニューの設定 */
  narimenu.menu = document.getElementById('narimenu');
  narimenu.nari = document.getElementById('naru');
  narimenu.funari = document.getElementById('narazu');
  narimenu.nari.onclick = clicknari;
  narimenu.funari.onclick = clicknarazu;
  narimenu.wait = false;

  namee.sen = document.getElementById('sentename');
  namee.go = document.getElementById('gotename');

  /* confirm */
  confirmdlginit();

  /* initKoma(); */
  /* update_screen(); */
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
      hovermasui.style.backgroundColor = banColor.ban;
    }
  } else {
    masui.style.backgroundColor = banColor.hover;
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

  /* var masu = ban[x][y]; */
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
  var c = b ? banColor.movable : banColor.ban;
  for (const elem of activemovable) {
    var x = elem.x, y = elem.y;
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
  setborderstyle(masui, b, '2px solid ' + banColor.active, '2px solid black');
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
    activetegoma = activemasu = activemasui = null;
    return activemovable = [];
  }

  activemasu = masu;
  activemasui = masui;
  activekoma = koma;

  setactivecell(masui, true);

  activemovable = hifumin_eye ? koma.getMovable(8 - masu.x, 8 - masu.y)
    : activemovable = koma.getMovable(masu.x, masu.y);

  activatemovable(true);
}

function absclick_wo_active(koma, masu, masui) {
  /* アクティブなマスはないので */
  if ((koma.teban !== Koma.AKI) && (koma.teban === activeteban)) {
    /* 自分の駒をクリックしたならアクティブにする。 */
    activecell(koma, masu, masui);
    /* } else { */
    /* nothing to do */
  }
}

function absclick_on_mypiece(koma, masu, masui) {
  /* 自分の駒をクリックしたので非アクティブにする。 */
  if (activetegoma !== null) activeuchi(null, null, null);
  activecell(koma, masu, masui);
}

function deactivate_activecell() {
  if (activetegoma !== null) activeuchi(null, null, null);
  else activecell(null, null, null);
}

function check_activemovablemasu(hx, hy) {
  for (const elem of activemovable) {
    if (elem.x === hx && elem.y === hy) return true;
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
    /* 選択キャンセル */
    deactivate_activecell();
  } else {
    var md = (activemasu.x === -1) ? CFRM_UTSU : CFRM_MOVE;
    myconfirm(activekoma.movemsg(hx, hy), md, hx, hy);
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
    /* 選択キャンセル */
    deactivate_activecell();
  } else {
    myconfirm(activekoma.movemsg(hx, hy), CFRM_MOVE, hx, hy);
  }
}

/**
 * マスをクリックした時に呼ばれる。
 *
 * @param {Event} event クリックイベント
 */
function absclick(event) {
  if (taikyokuchu === false) return;
  if (narimenu.wait) return;

  var clickid = event.currentTarget.id;
  var x = +clickid.substring(1, 2)-1;
  var y = +clickid.substring(2, 3)-1;

  var hx = x, hy = y;  /* 1~９筋(0~8) 一~九段(0~8) */
  if (hifumin_eye) {
    hx = 8 - hx;
    hy = 8 - hy;
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
    /* アクティブなマスはないので */
    /* 自分の駒をクリックしたならアクティブにする。 */
    absclick_wo_active(koma, masu, masui);
  } else if (activemasu === masu) {
    /* アクティブなマスをクリックしたので非アクティブにする。 */
    activecell(null, null, null);
  } else if (activekoma.teban === koma.teban) {
    /* 自分の駒をクリックしたので非アクティブにする。 */
    absclick_on_mypiece(koma, masu, masui);
  } else if (koma.teban === Koma.AKI) {
    /* 空きマスをクリックした */
    absclick_aki(hx, hy);
  } else {
    /* 相手の駒をクリックした */
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
  setborderstyle(masui, b, '2px solid ' + banColor.active, '0px solid black');
}

function release_uchi(tegoma, i)
{
  let result = tegoma === null || (activekoma !== null && activekoma.id === i);
  if (result) {
    activetegoma = activemasu = activekoma = null;
    activemovable = [];
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

  var masu = tegomasu[i][1], masui = tegomasu[i][1].el;
  /* var koma = tegoma[i][0][tegoma[i][0].length - 1]; */

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
    var strs = 'sg_' + kmtbl[i], strg = 'gg_' + kmtbl[i];
    if (strs === id_sub) return absclick_tegoma_sg(i, false, sentegoma);
    if (strg === id_sub) return absclick_tegoma_sg(i, true, gotegoma);
  }
}

/**
 * 成り選択メニューを出す
 *
 * @param {Number} x 座標[ピクセル]
 * @param {Number} y 座標[ピクセル]
 */
function popupnari(x, y) {
  narimenu.menu.style.visibility = 'visible';
  narimenu.wait = true;
}

function move_byclick_narinarazu(nari)
{
  narimenu.wait = false;
  narimenu.menu.style.visibility = 'hidden';

  move_and_update(narimenu.toxy, nari);
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

function move_and_update(hxy, nari)
{
  move(activekoma, hxy, nari);
  activecell(null, null, null);
  update_screen();
  record_your_move();
}

function clickcfrm_move(hx, hy)
{
  hxy = {x: hx, y: hy};
  /* toru(取らないかもしれないけど) */
  toru(hxy);

  /* move */
  var nareru = activekoma.checkNari(activekoma.y, hy);
  if (nareru === Koma.NARENAI /*|| nareru === Koma.NATTA*/) {
    move_and_update(hxy, Koma.NARAZU);
  } else if (nareru === Koma.NARU) {
    move_and_update(hxy, Koma.NARI);
  } else if (nareru === Koma.NARERU) {
    /* ユーザに聞く */
    narimenu.toxy = {x: hx, y: hy};
    popupnari(mousepos.x, mousepos.y);
  }
}

function send_drawsuggestion(yesno) {
  var teban = document.getElementById('myteban').value;
  movecsa = '!DRAW' + yesno + teban;
  send_csamove();
}

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
  /* String('true') or String('false') */
  var strfinished = document.getElementById('isfinished').value;
  isfinished = (strfinished !== 'false');  /* convert to boolean */

  if (isfinished) return taikyokuchu = false;

  /* var teban = document.getElementById('myturn').value; */
  /* if (teban !== '0') taikyokuchu = true; */
  var teban = document.getElementById('myteban').value;
  if (teban === 'b' && activeteban === Koma.SENTEBAN) taikyokuchu = true;
  else if (teban === 'w' && activeteban === Koma.GOTEBAN) taikyokuchu = true;
  else taikyokuchu = false;
}

function activateteban()
{
  var strinfo = mykifu.NTeme + '手目です。<BR>';
  if (activeteban === Koma.SENTEBAN) {
    strinfo += '先手の手番です。<BR>'
  } else if (activeteban === Koma.GOTEBAN) {
    strinfo += '後手の手番です。<BR>'
  } else {
    strinfo += '対局は終了/中断しました。<BR>'
  }
  document.getElementById('tebaninfo').innerHTML = strinfo;

  turn_taikyoku_on();

  /* resign button */
  var tarea = document.getElementById('resign_area')
  if (tarea && !taikyokuchu) tarea.innerHTML = '手番時に投了出来ます。';
  /* var btn = document.getElementById('btn_resign')
  if (btn) btn.style.display = (taikyokuchu) ? 'inline' : 'none'; */

  /* draw_suggest button */
  /* btn = document.getElementById('btn_draw_suggest'); */
  /* if (btn) btn.style.display = (taikyokuchu) ? 'inline' : 'none'; */
}

function checkSfenResponse(sfenstr)
{
  /* ERROR */
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
  if ((200 <= status && status < 300) || status === 304) {
    /* XHR 通信成功, リクエスト成功 */
    checkSfenResponse(ajax.responseText);
  } else {    /* XHR 通信失敗, XHR 通信成功+リクエスト失敗 */
    startUpdateTimer();
  }
}

function checkLatestMoveTmout()
{
  var elem_id = document.getElementById('gameid');
  var gid = elem_id.value;

  var ajax = new XMLHttpRequest();
  if (ajax === null) return;
  /* tsushinchu = true; */
  /* activatefogscreen(); */
  ajax.open('POST', 'getsfen.rb?' + gid, true);
  ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  /* ajax.send('');  // gets error with webrick */
  ajax.send('dum=my');

  ajax.onreadystatechange = function() {
    /* tsushinchu = false; */
    /* var msg = document.getElementById('msg_fogscreen'); */
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

  /* e.g. '9' -> 9 */
  /* e.g. '3' -> 3 */
  var x = Number(str.charAt(3)), y = Number(str.charAt(4));

  if (isNaN(x)) x = 0;
  if (isNaN(y)) y = 0;

  last_mxy = {x: x - 1, y: y - 1};
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
  var lmtm = new Date(ellmtm.innerText), now = new Date();
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

/** 対局画面がそれなりに初期化できたらtrue */
var initialized = false;

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

  hifumin_eye = document.getElementById('hifumineye').checked;

  update_screen();

  activateteban();

  if (!isfinished) {
    startUpdateTimer();
    startCurTimer();
  }

  initialized = true;
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

function csvmove_succ(resp)
{
  if (resp.match(/^Moved./)) {
    return '通信完了。<br>自動的にリロードします。<br>response:' + resp;
  } else if (resp.match(/^Draw suggestion./)) {
    return '通信完了。<br>自動的にリロードします。<br>response:' + resp;
  } else {
    return '通信失敗。<br>指し手が反映されなかった可能性があります。<br>'
      + 'お手数ですが、反映されたか確認をお願いします。<br>自動的にリロードします。<br>'
      + 'response:' + resp;
  }
}

function send_csamove_resp(status, resp)
{
  var msg = document.getElementById('msg_fogscreen');
  if (status === 0) {  /* XHR 通信失敗 */
    msg.innerHTML += 'XHR 通信失敗<br>自動的にリロードします。';
    return location.reload(true);
  }
  /* XHR 通信成功 */
  if ((200 <= status && status < 300) || status === 304) {
    /* リクエスト成功 */
    msg.innerHTML = csvmove_succ(resp);
  } else {  /* リクエスト失敗 */
    msg.innerHTML += 'その他の応答:' + status
      + '<br>指し手が反映されなかった可能性があります。<br>'
      + 'お手数ですが、確認をお願いします。<br>自動的にリロードします。<br>'
      + 'response:' + resp;
  }
  location.reload(true);
}

function send_csamove()
{
  var gid = document.getElementById('gameid').value;

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
      send_csamove_resp(ajax.status, ajax.responseText);
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
  var elem = window.location.search.split('/');
  var win = window.open(url + elem[1], '_blank');
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

function onsuggestdraw() {
  myconfirm("引き分けを提案する(OK), しない(Cancel)",
            CFRM_SUGDRAW, -1, -1);
}
