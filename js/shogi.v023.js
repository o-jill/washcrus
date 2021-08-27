/** 盤面 */
var ban = genban();
function genban() {
  var res = new Array(9);
  for (var i = 0 ; i < 9 ; ++i) {
    res[i] = new Array(9);
    for (var j = 0 ; j < 9 ; ++j)
      res[i][j] = new Object;
  }
  return res;
}

/** 先手手持ち、擬似マス情報 */
var sentegoma = gentegoma();

/** 後手手持ち、擬似マス情報 */
var gotegoma = gentegoma();

function gentegoma() {
  var res = [];
  for (var i = 0 ; i < 7 ; ++i) {
    res.push([[], {}]);
  }
  return res;
}

/*
[7][0]:持ち駒配列
[7][1]:駒情報

{list:[], koma:{}}

var tegomaitem = function () {
 this.list = [];
 this.koma = {};
 this.x = -1;
 this.y = -1;
 this.el = null:
}
*/

/** 現在の手番 */
var activeteban = Koma.SENTEBAN;

/** 先手玉 */
var sentegyoku;
/** 後手玉 */
var gotegyoku;

/** 取った駒 */
var tottakoma;

/* 直近の指手 */
var movecsa = '%0000OU__P';

function populate_tegoma() {
  for (var i = 0; i < 7; ++i) {
    sentegoma[i][0] = [];
    sentegoma[i][1].x = -1;
    sentegoma[i][1].y = -1;
    // sentegoma[i][1].el = null;

    gotegoma[i][0] = [];
    gotegoma[i][1].x = -1;
    gotegoma[i][1].y = -1;
    // gotegoma[i][1].el = null;
  }
  sentegoma[0][1].koma = new Fu(Koma.SENTEBAN, -1, -1);
  sentegoma[1][1].koma = new Kyosha(Koma.SENTEBAN, -1, -1);
  sentegoma[2][1].koma = new Keima(Koma.SENTEBAN, -1, -1);
  sentegoma[3][1].koma = new Gin(Koma.SENTEBAN, -1, -1);
  sentegoma[4][1].koma = new Kin(Koma.SENTEBAN, -1, -1);
  sentegoma[5][1].koma = new Kaku(Koma.SENTEBAN, -1, -1);
  sentegoma[6][1].koma = new Hisha(Koma.SENTEBAN, -1, -1);
  gotegoma[0][1].koma = new Fu(Koma.GOTEBAN, -1, -1);
  gotegoma[1][1].koma = new Kyosha(Koma.GOTEBAN, -1, -1);
  gotegoma[2][1].koma = new Keima(Koma.GOTEBAN, -1, -1);
  gotegoma[3][1].koma = new Gin(Koma.GOTEBAN, -1, -1);
  gotegoma[4][1].koma = new Kin(Koma.GOTEBAN, -1, -1);
  gotegoma[5][1].koma = new Kaku(Koma.GOTEBAN, -1, -1);
  gotegoma[6][1].koma = new Hisha(Koma.GOTEBAN, -1, -1);
}

function clear_ban()
{
  var akigoma = new Koma();
  for (var i = 0; i < 9; ++i) {
    for (var j = 0; j < 9; ++j) {
      ban[i][j].x = i;
      ban[i][j].y = j;
      ban[i][j].koma = akigoma;
    }
  }
}

function populate_koma() {
  var komabako = [
    new Kin(Koma.GOTEBAN, 3, 0), new Kin(Koma.GOTEBAN, 5, 0),
    new Kin(Koma.SENTEBAN, 3, 8), new Kin(Koma.SENTEBAN, 5, 8),
    new Gin(Koma.GOTEBAN, 2, 0), new Gin(Koma.GOTEBAN, 6, 0),
    new Gin(Koma.SENTEBAN, 2, 8), new Gin(Koma.SENTEBAN, 6, 8),
    new Keima(Koma.GOTEBAN, 1, 0), new Keima(Koma.GOTEBAN, 7, 0),
    new Keima(Koma.SENTEBAN, 1, 8), new Keima(Koma.SENTEBAN, 7, 8),
    new Kyosha(Koma.GOTEBAN, 0, 0), new Kyosha(Koma.GOTEBAN, 8, 0),
    new Kyosha(Koma.SENTEBAN, 0, 8), new Kyosha(Koma.SENTEBAN, 8, 8),
    new Kaku(Koma.GOTEBAN, 1, 1), new Kaku(Koma.SENTEBAN, 7, 7),
    new Hisha(Koma.GOTEBAN, 7, 1), new Hisha(Koma.SENTEBAN, 1, 7),
  ];
  for (var k in komabako) {
    ban[k.x][k.y] = k;
  }

  // FU
  for (var i = 0; i < 9; ++i) {
    ban[i][2].koma = new Fu(Koma.GOTEBAN, i, 2);
    ban[i][6].koma = new Fu(Koma. SENTEBAN, i, 6);
  }

  gotegyoku = new Gyoku(Koma.GOTEBAN, 4, 0);
  sentegyoku = new Gyoku(Koma.SENTEBAN, 4, 8);
  ban[4][0].koma = gotegyoku;
  ban[4][8].koma = sentegyoku;
}

/**
 * 手駒と盤上の駒の初期化。
 */
function initKoma() {
  populate_tegoma();
  clear_ban();
  populate_koma();

  activeteban = Koma.SENTEBAN;
}

/**
 * 手駒と盤上の駒の初期化。駒は置かない。
 */
function initKomaEx() {
  populate_tegoma();
  clear_ban();
}

/**
 * コマの移動。
 *
 * @param {Object} koma 移動するコマ
 * @param {Number} toxy 移動先
 * @param {Number} nari 成る(Koma.NARI)か成らない(Koma.Narazu)か
 *                      成る場合は駒を裏返す(=成った駒を元に戻せる)
 */
function move(koma, toxy, nari) {
  var from_x = koma.x, from_y = koma.y;
  /* どうもkomaのxyの値を参照してしまうのでダメっぽい */
  /* var fromxy = {x: koma.x, y: koma.y}; */

  koma.kaesu(nari);

  var tottaid = mykifu.totta_id;

  mykifu.genKifu(koma, {x: from_x, y: from_y}, toxy, nari);
  /* console.log(mykifu.genKifu(masu.koma, fromxy, toxy, nari));
  console.log(masu.koma.CSA(fromxy.x, fromxy.y, toxy.x, toxy.y));
  console.log(masu.koma.KIF(fromxy.x, fromxy.y, toxy.x, toxy.y, nari));*/

  koma.x = toxy.x;
  koma.y = toxy.y;

  ban[from_x][from_y].koma = ban[toxy.x][toxy.y].koma;
  ban[toxy.x][toxy.y].koma = koma;

  activeteban = (activeteban === Koma.SENTEBAN) ? Koma.GOTEBAN : Koma.SENTEBAN;

  movecsa = build_movecsa(koma, {x: from_x, y: from_y}, toxy, tottaid, nari);
}

/**
 * ban[x][y]にある駒を取る。
 *
 * @param {Number} xy 取る駒がある座標
 */
function toru(xy) {
  var koma = ban[xy.x][xy.y].koma;
  if (koma.nari === Koma.NARI) {
    // 成り駒を取った時は+1000してIDを覚えておく
    mykifu.totta_id = 1000;
  } else {
    mykifu.totta_id = 0;
  }
  if (koma.teban === Koma.SENTEBAN) {
    koma.reset(Koma.GOTEBAN);
    komadai_add(gotegoma, koma);
  } else if (koma.teban === Koma.GOTEBAN) {
    koma.reset(Koma.SENTEBAN);
    komadai_add(sentegoma, koma);
  } else {
    mykifu.totta_id = Koma.NoID;
    // console.log('toremasen!!');
    return;
  }
  ban[xy.x][xy.y].koma = new Koma();
  tottakoma = koma;
  mykifu.totta_id += koma.id;
}

/**
 * 駒台にコマを置く
 *
 * @param {Object} tegoma 手駒リスト
 * @param {Object} koma 駒
 */
function komadai_add(tegoma, koma) {
  if (koma.id < Koma.GyokuID) tegoma[koma.id][0].push(koma);
}

/**
 * 駒台から駒を取り出す
 *
 * @param {Object} tegoma 手駒リスト
 * @param {Object} id 駒ID
 *
 * @return {Object} 駒
 */
function komadai_del(tegoma, id) {
  if (id < Koma.GyokuID) {
    /* console.assert(tegoma[id][0].length > 0,
      'no koma on komadai@komadai_del(' + tegoma + ',' + id + ');'); */
    return tegoma[id][0].pop();
  }
}

/**
 * 駒を打つ。
 *
 * @param {Object} tegoma 手駒リスト
 * @param {Object} koma 打つ駒
 * @param {Number} toxy 移動先
 */
function uchi(tegoma, koma, toxy) {
  /* console.log(koma.CSA(-1, -1, toxy.x, toxy.y));
  console.log(koma.KIF(-1, -1, toxy.x, toxy.y, Koma.Narazu));
  console.log(mykifu.genKifu(koma, {x: -1, y: -1}, toxy, Koma.Narazu));*/
  mykifu.genKifu(koma, {x: -1, y: -1}, toxy, Koma.Narazu, koma.id);

  var k = komadai_del(tegoma, koma.id);

  ban[toxy.x][toxy.y].koma = k;

  k.x = toxy.x;
  k.y = toxy.y;

  activeteban = (activeteban === Koma.SENTEBAN) ? Koma.GOTEBAN : Koma.SENTEBAN;

  movecsa = '';

  movecsa += k.getTebanStrUtil(Koma.UtilStr.csa);

  movecsa += ('00' + (toxy.x + 1)) + (toxy.y + 1);
  movecsa += k.strtype.csa[0] + '__';
}

/**
 * 駒を打つ。
 *
 * @param {Object} tegoma 手駒リスト
 * @param {Number} koma_id 打つ駒のID
 * @param {Number} toxy 移動先
 */
function uchi2(tegoma, koma_id, toxy) {
  var k = komadai_del(tegoma, koma_id);

  ban[toxy.x][toxy.y].koma = k;

  k.x = toxy.x;
  k.y = toxy.y;

  activeteban = (activeteban === Koma.SENTEBAN) ? Koma.GOTEBAN : Koma.SENTEBAN;

  movecsa = '';

  movecsa += k.getTebanStrUtil(Koma.UtilStr.csa);

  movecsa += ('00' + (toxy.x + 1)) + (toxy.y + 1);
  movecsa += k.strtype.csa[0] + '__';
}

/**
 * コマの移動。(感想戦用)
 *
 * @param {Object} koma 移動するコマ
 * @param {Number} toxy 移動先
 * @param {Number} nari 成る(Koma.NARI)か成らない(Koma.Narazu)か
 *                      成る場合は駒を裏返す(=成った駒を元に戻せる)
 */
function move2(koma, toxy, nari) {
  var from_x = koma.x, from_y = koma.y;

  koma.kaesu(nari);

  /* mykifu.genKifu(masu.koma, {x: from_x, y: from_y}, toxy, nari); */
  /* console.log(mykifu.genKifu(masu.koma, fromxy, toxy, nari));
  console.log(masu.koma.CSA(fromxy.x, fromxy.y, toxy.x, toxy.y));
  console.log(masu.koma.KIF(fromxy.x, fromxy.y, toxy.x, toxy.y, nari));*/

  koma.x = toxy.x;
  koma.y = toxy.y;

  ban[from_x][from_y].koma = ban[toxy.x][toxy.y].koma;
  ban[toxy.x][toxy.y].koma = koma;

  activeteban = (activeteban === Koma.SENTEBAN) ? Koma.GOTEBAN : Koma.SENTEBAN;

  var tottaid = mykifu.totta_id;
  movecsa = build_movecsa(koma, {x: from_x, y: from_y}, toxy, tottaid, nari);
}

/**
 * 取った駒を盤に戻す。(感想戦用)
 *
 * @param {Object} tegoma 手駒リスト
 * @param {Object} koma_id 戻す駒のID
 * @param {Number} toxy 移動先
 */
function torimodosu(tegoma, koma_id, toxy) {
  var nari = false;
  // 成り駒を取った時は+1000してIDを覚えてある
  if (koma_id >= 1000) {
    koma_id -= 1000;
    nari = true;
  }
  var k = komadai_del(tegoma, koma_id);

  k.teban = (k.teban === Koma.SENTEBAN) ? Koma.GOTEBAN : Koma.SENTEBAN;

  if (nari) k.nari = Koma.NARI;

  ban[toxy.x][toxy.y].koma = k;

  k.x = toxy.x;
  k.y = toxy.y;
}

function build_movecsa(koma, fromxy, toxy, tottaid, nari) {
  var str = koma.getTebanStrUtil(Koma.UtilStr.csa);

  str += ('' + (fromxy.x + 1)) + (fromxy.y + 1);

  str += ('' + (toxy.x + 1)) + (toxy.y + 1);

  str += (nari === Koma.NARI || koma.nari !== Koma.NARI)
    ? koma.strtype.csa[0] : koma.strtype.csa[1];

  if (tottaid === Koma.NoID) str += '__';
  else if (tottaid >= 1000) str += tottakoma.strtype.csa[1];
  else str += tottakoma.strtype.csa[0];

  if (nari === Koma.NARI) str += 'P';

  return str;
}

/**
 * @return a masu if found  or undefined
 */
function checkOHTe_koma(gyoku, koma, i, j) {
  if (koma.teban === Koma.AKI) return false;

  if (koma.teban === gyoku.teban) return false;

  var masulist = koma.getMovable(i, j);
  // var masulist = koma.getMovable(koma.x, koma.y);
  // var masulist = koma.getMovable();
  // for (var idx = 0; idx < masulist.length; ++idx) {
  return masulist.find((elem) => elem.x === gyoku.x && elem.y === gyoku.y)
}

/**
 * 王手かどうか確認する
 *
 * @param {Object} gyoku 玉駒オブジェクト
 *
 * @return {Boolean} true:王手, false:王手ではない
 */
function checkOHTe(gyoku) {
  for (var i = 0; i < 9; ++i) {
    for (var j = 0; j < 9; ++j) {
      var koma = ban[i][j].koma;
      if (checkOHTe_koma(gyoku, koma, i, j)) return true;
    }
  }
  return false;
}
