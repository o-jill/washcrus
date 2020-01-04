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
