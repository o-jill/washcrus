/** 盤面 */
var ban = [
  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
  [{}, {}, {}, {}, {}, {}, {}, {}, {}]];

/** 先手手持ち、擬似マス情報 */
var sentegoma = [
  [[], {}], [[], {}], [[], {}], [[], {}],
  [[], {}], [[], {}], [[], {}]];

/** 後手手持ち、擬似マス情報 */
var gotegoma = [
  [[], {}], [[], {}], [[], {}], [[], {}],
  [[], {}], [[], {}], [[], {}]];

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
  // FU
  for (var i = 0; i < 9; ++i) {
    ban[i][2].koma = new Fu(Koma.GOTEBAN, i, 2);
    ban[i][6].koma = new Fu(Koma. SENTEBAN, i, 6);
  }
  ban[1][1].koma = new Kaku(Koma.GOTEBAN, 1, 1);
  ban[7][7].koma = new Kaku(Koma.SENTEBAN, 7, 7);

  ban[7][1].koma = new Hisha(Koma.GOTEBAN, 7, 1);
  ban[1][7].koma = new Hisha(Koma.SENTEBAN, 1, 7);

  gotegyoku = new Gyoku(Koma.GOTEBAN, 4, 0);
  sentegyoku = new Gyoku(Koma.SENTEBAN, 4, 8);
  ban[4][0].koma = gotegyoku;
  ban[4][8].koma = sentegyoku;

  ban[3][0].koma = new Kin(Koma.GOTEBAN, 3, 0);
  ban[5][0].koma = new Kin(Koma.GOTEBAN, 5, 0);
  ban[3][8].koma = new Kin(Koma.SENTEBAN, 3, 8);
  ban[5][8].koma = new Kin(Koma.SENTEBAN, 5, 8);

  ban[2][0].koma = new Gin(Koma.GOTEBAN, 2, 0);
  ban[6][0].koma = new Gin(Koma.GOTEBAN, 6, 0);
  ban[2][8].koma = new Gin(Koma.SENTEBAN, 2, 8);
  ban[6][8].koma = new Gin(Koma.SENTEBAN, 6, 8);

  ban[1][0].koma = new Keima(Koma.GOTEBAN, 1, 0);
  ban[7][0].koma = new Keima(Koma.GOTEBAN, 7, 0);
  ban[1][8].koma = new Keima(Koma.SENTEBAN, 1, 8);
  ban[7][8].koma = new Keima(Koma.SENTEBAN, 7, 8);

  ban[0][0].koma = new Kyosha(Koma.GOTEBAN, 0, 0);
  ban[8][0].koma = new Kyosha(Koma.GOTEBAN, 8, 0);
  ban[0][8].koma = new Kyosha(Koma.SENTEBAN, 0, 8);
  ban[8][8].koma = new Kyosha(Koma.SENTEBAN, 8, 8);
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
 * 汎用駒クラス
 *
 * @class
 * @constructor
 *
 * @param {Number} teban 手番または空きスペース
 * @param {Number} x 座標
 * @param {Number} y 座標
 */
function Koma(teban, x, y) {
  this.teban = teban || Koma.AKI;
  this.strtype = '* ';
  this.strntype = '* ';
  this.strtypeKIF = '* ';
  this.strntypeKIF = '* ';
  this.strtypeKIFU = '* ';
  this.strntypeKIFU = '* ';
  this.strtypeCSA = '* ';
  this.strntypeCSA = '* ';
  this.strtypeIMG = '';
  this.strntypeIMG = '';
  this.nari = Koma.NARAZU;
  this.id = Koma.NoID;
  this.x = x;
  this.y = y;
  this.funariMovable = [];
  this.nariMovable = [];
}

/* -- クラス定数ここから -- */
Koma.SENTEBAN = 1;
Koma.GOTEBAN = 2;
Koma.AKI = 3;

Koma.NARAZU = 1;
Koma.NARI = 2;

Koma.NARENAI = 1;
Koma.NARU = 2;
Koma.NARERU = 3;
Koma.NATTA = 4;

// koma ID
Koma.NoID = -1;
Koma.FuID = 0;
Koma.KyoshaID = 1;
Koma.KeimaID = 2;
Koma.GinID = 3;
Koma.KinID = 4;
Koma.KakuID = 5;
Koma.HishaID = 6;
Koma.GyokuID = 7;

// -- CSA
Koma.FuStr = 'FU';
Koma.KyoshaStr = 'KY';
Koma.KeimaStr = 'KE';
Koma.GinStr = 'GI';
Koma.KinStr = 'KI';
Koma.KakuStr = 'KA';
Koma.HishaStr = 'HI';
Koma.GyokuStr = 'OU';
Koma.NFuStr = 'TO';
Koma.NKyoshaStr = 'NY';
Koma.NKeimaStr = 'NK';
Koma.NGinStr = 'NG';
// Koma.NKinStr = 'KI';
Koma.NKakuStr = 'UM';
Koma.NHishaStr = 'RY';
// Koma.NGyokuStr = 'OU';

// -- KIF
Koma.FuStrKIF = '歩';
Koma.KyoshaStrKIF = '香';
Koma.KeimaStrKIF = '桂';
Koma.GinStrKIF = '銀';
Koma.KinStrKIF = '金';
Koma.KakuStrKIF = '角';
Koma.HishaStrKIF = '飛';
Koma.GyokuStrKIF = '玉';
Koma.NFuStrKIF = 'と';
Koma.NKyoshaStrKIF = '成香';
Koma.NKeimaStrKIF = '成桂';
Koma.NGinStrKIF = '成銀';
// Koma.NKinStrKIF = '成金';
Koma.NKakuStrKIF = '馬';
Koma.NHishaStrKIF = '竜';
// Koma.NGyokuStrKIF = '王';
Koma.NariStrKIF = '成';
Koma.UchiStrKIF = '打';
Koma.DouStrKIF = '同　';
Koma.FunariStr = '不成';

// -- pictures
Koma.FuStrIMG = 'koma_fu';
Koma.KyoshaStrIMG = 'koma_kyo';
Koma.KeimaStrIMG = 'koma_kei';
Koma.GinStrIMG = 'koma_gin';
Koma.KinStrIMG = 'koma_kin';
Koma.KakuStrIMG = 'koma_kaku';
Koma.HishaStrIMG = 'koma_hisha';
Koma.GyokuStrIMG = 'koma_ou';
Koma.NFuStrIMG = 'koma_to';
Koma.NKyoshaStrIMG = 'koma_nkyo';
Koma.NKeimaStrIMG = 'koma_nkei';
Koma.NGinStrIMG = 'koma_ngin';
// Koma.NKinStrIMG = 'koma_nkin';
Koma.NKakuStrIMG = 'koma_uma';
Koma.NHishaStrIMG = 'koma_ryu';
// Koma.NGyokuStrIMG = 'koma_nou';
// Koma.NariStrKIF = '成';
// Koma.UchiStrKIF = '打';
// Koma.DouStrKIF = '同　';
// Koma.FunariStr = '不成';

// -- Long
Koma.FuStrLong = '歩兵';
Koma.KyoshaStrLong = '香車';
Koma.KeimaStrLong = '桂馬';
Koma.GinStrLong = '銀将';
Koma.KinStrLong = '金将';
Koma.KakuStrLong = '角行';
Koma.HishaStrLong = '飛車';
Koma.GyokuStrLong = '玉将';
Koma.OuStrLong = '玉将';
Koma.NFuStrLong = 'と金';
Koma.NKyoshaStrLong = '成香';
Koma.NKeimaStrLong = '成桂';
Koma.NGinStrLong = '成銀';
// Koma.NKinStrLong = '成金';
Koma.NKakuStrLong = '竜馬';
Koma.NHishaStrLong = '竜王';
// Koma.NGyokuStrLong = '王';

// 先手、後手、空き
Koma.SenteStr = '▲';
Koma.GoteStr = '△';
Koma.AkiStr = ' ';
Koma.SenteStrKIF = ' ';
Koma.GoteStrKIF = 'v';
Koma.AkiStrKIF = ' ・';
Koma.SenteStrCSA = '+';
Koma.GoteStrCSA = '-';
Koma.AkiStrCSA = ' * ';
Koma.SenteStrOrg = '先手';
Koma.GoteStrOrg = '後手';

Koma.ToryoStr = '投了';
Koma.ToryoStrCSA = '%TORYO';
Koma.TsumiStrCSA = '%TSUMI';

// x,y,straight
Koma.FuMovable = [[0, 1, false]];
Koma.KyoshaMovable = [[0, 1, true]];
Koma.KeimaMovable = [[1, 2, false], [-1, 2, false]];
Koma.GinMovable = [
  [1, 1, false], [0, 1, false], [-1, 1, false],
  [1, -1, false], [-1, -1, false]];
Koma.KinMovable = [
  [1, 1, false], [0, 1, false], [-1, 1, false],
  [1, 0, false], [-1, 0, false], [0, -1, false]];
Koma.KakuMovable = [[1, 1, true], [-1, -1, true], [-1, 1, true], [1, -1, true]];
Koma.HishaMovable = [[1, 0, true], [-1, 0, true], [0, 1, true], [0, -1, true]];
Koma.UmaMovable = [
  [1, 1, true], [-1, -1, true], [-1, 1, true], [1, -1, true],
  [0, 1, false], [1, 0, false], [-1, 0, false], [0, -1, false]];
Koma.RyuMovable = [
  [1, 0, true], [-1, 0, true], [0, 1, true], [0, -1, true],
  [1, 1, false], [1, -1, false], [-1, 1, false], [-1, -1, false]];
Koma.GyokuMovable = [
  [1, 1, false], [0, 1, false], [-1, 1, false], [1, 0, false],
  [-1, 0, false], [1, -1, false], [0, -1, false], [-1, -1, false]];

Koma.KomaStrTbl = [
  '歩', '香', '桂', '銀', '金', '角', '飛', '玉',
  'と', '成香', '成桂', '成銀', '成金', '馬', '竜', '王'];

Koma.ZenkakuNum = ['１', '２', '３', '４', '５', '６', '７', '８', '９'];
Koma.KanjiNum = ['一', '二', '三', '四', '五', '六', '七', '八', '九'];

/* -- クラス定数ここまで -- */

/**
 * 初期化
 *
 * @param {Number} teban 手番または空きスペース
 */
Koma.prototype.reset = function(teban) {
  this.teban = teban || Koma.AKI;
  this.nari = Koma.NARAZU;
  this.x = -1;
  this.y = -1;
};

/**
 * Komaオブジェクトを複製する。
 *
 * @param {Object} obj 複製したいオブジェクト
 *
 * @return {Object} 複製結果。objが空の時は自分の複製。
 */
Koma.prototype.clone = function(obj)  {
  var f = function() {};
  f.prototype = obj || this;
  return new f();
};

/**
 * 表示用の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getStr = function() {
  var str;
  if (this.teban === Koma.SENTEBAN) {
    str = Koma.SenteStr;
  } else if (this.teban === Koma.GOTEBAN) {
    str = Koma.GoteStr;
  } else {
    str = Koma.AkiStr;
    return str;
  }
  str += this.strntypeKIFU;
  if (this.nari === Koma.NARI) {
    // no prefix
  } else {
    str += this.strtypeKIFU;
  }
  return str;
};
/**
 * HTML表示用の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getHtmlStr = function(hanten) {
  var str;
  if (this.teban === Koma.SENTEBAN) {
    if (hanten) {
      str = '<div class=gotemoji>';
    } else {
      str = '<div class=sentemoji>';
    }
  } else if (this.teban === Koma.GOTEBAN) {
    if (hanten) {
      str = '<div class=sentemoji>';
    } else {
      str = '<div class=gotemoji>';
    }
  } else {
    str = Koma.AkiStr;
    return str;
  }
  if (this.nari === Koma.NARI) {
    str += this.strntypeKIFU;
  } else {
    str += this.strtypeKIFU;
  }
  str += '</div>';
  return str;
};
/**
 * HTML表示用の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getImgStr = function(hanten) {
  var str;
  if (this.teban === Koma.SENTEBAN) {
    str = (hanten) ? 'h' : '';
  } else if (this.teban === Koma.GOTEBAN) {
    str = (hanten) ? '' : 'h';
  } else {
    return '';
  }

  str += (this.nari === Koma.NARI) ? this.strntypeIMG : this.strtypeIMG;

  return str;
};
/**
 * CSA表示用の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getShortStrCSA = function() {
  var str;
  if (this.teban === Koma.SENTEBAN) {
    str = Koma.SenteStrCSA;
  } else if (this.teban === Koma.GOTEBAN) {
    str = Koma.GoteStrCSA;
  } else {
    str = Koma.AkiStrCSA;
    return str;
  }
  if (this.nari === Koma.NARI) {
    str += this.strntypeCSA;
  } else {
    str += this.strtypeCSA;
  }
  return str;
};
/**
 * CSA表示用の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getShortStrKIF = function() {
  var str;
  if (this.teban === Koma.SENTEBAN) {
    str = Koma.SenteStrKIF;
  } else if (this.teban === Koma.GOTEBAN) {
    str = Koma.GoteStrKIF;
  } else {
    str = Koma.AkiStrKIF;
    return str;
  }
  if (this.nari === Koma.NARI) {
    str += Koma.strntypeKIF;
  } else {
    str += this.strtypeKIF;
  }
  return str;
};

/**
 * 駒の種類の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getTypeStr = function() {
  if (this.nari === Koma.NARI)
    return this.strntype;
  else
    return this.strtype;
};

/**
 * 動ける方向のリストを返す。
 *
 * @return {Array} 空のArray
 */
Koma.prototype.movable = function() {
  if (this.nari === Koma.NARI) {
    return this.nariMovable;
  } else {
    return this.funariMovable;
  }
};
/**
 * その他の駒がないとしてこれ以上動けるか
 *
 * @param {Number} oy 現在地
 *
 * @return {Boolean} true:まだ動ける, false:もう無理。
 */
Koma.prototype.checkMovable = function(oy) {
  return true;
};

/**
 * 利いているマスのリストを返す。香車角行飛車の長い効き用
 *
 * @param  {Hash}    list  利いているマスのリスト
 * @param  {Number}  ax    移動方向
 * @param  {Number}  ay    移動方向
 * @param  {Number}  ox    現在地
 * @param  {Number}  oy    現在地
 * @param  {Boolean} bstop  他のコマの影響を考慮
 * @return {Hash}    利いているマスのリスト
 */
Koma.prototype.getStraightKiki = function(list, ax, ay, ox, oy, bstop) {
  var x = ox;
  var y = oy;
  if (this.teban === Koma.SENTEBAN) {
    ay = -ay;
  }
  for ( ; ; ) {
    x += ax;
    y += ay;
    if (x < 0 || x > 8) {
      break;
    }
    if (y < 0 || y > 8) {
      break;
    }
    if (Math.abs(x - ox) <= 1 && Math.abs(y - oy) <= 1) {
      list.rin8.push([x, y]);  // 隣接８マス
    } else {
      list.straight.push([x, y]);
    }
    if (bstop) {
      var koma = ban[x][y].koma;
      if (koma.teban === this.teban) break;
      if (koma.teban !== Koma.AKI) break;
    }
  }
  return list;
};

/**
 * 利いているマスのリストを返す。 ax,ay方向の効き。
 *
 * @param  {Hash}    list  利いているマスのリスト
 * @param  {Number}  ax    移動方向
 * @param  {Number}  ay    移動方向
 * @param  {Number}  ox    現在地
 * @param  {Number}  oy    現在地
 * @return {Hash}    利いているマスのリスト
 */
Koma.prototype.getCloseKiki = function(list, ax, ay, ox, oy) {
  var x, y;
  x = ox + ax;
  if (x < 0 || x > 8) return list;

  if (this.teban === Koma.SENTEBAN) {
    y = oy - ay;
  } else {
    y = oy + ay;
  }
  if (y < 0 || y > 8) return list;

  // masu = ban[x][y];
  if (Math.abs(x - ox) <= 1 && Math.abs(y - oy) <= 1) {
    list.rin8.push([x, y]);
  } else {
    // 桂馬はこっち
    list.straight.push([x, y]);
  }
};

/**
 * 利いているマスのリストを返す。他のコマの影響を考慮。
 *
 * @param {Number} ox 現在地
 * @param {Number} oy 現在地
 *
 * @return {Object} 利いているマスのリスト
 *                  {rin8   :[[x, y], ...], 隣接8マス
 *                  straight:[[x, y], ...]} 隣接8マスより遠い
 */
Koma.prototype.getKiki = function(ox, oy) {
  //
  var list = {rin8: [], straight: []};
  var movablemasulist = this.movable();
  var sz = movablemasulist.length;
  for (var idx = 0; idx < sz; ++idx) {
    var ax = movablemasulist[idx][0];
    var ay = movablemasulist[idx][1];
    var straight = movablemasulist[idx][2];
    if (straight) {
      list = this.getStraightKiki(list, ax, ay, ox, oy, true);
    } else {
      list = this.getCloseKiki(list, ax, ay, ox, oy);
    }
  }
  return list;
};

/**
 * 利いているマスのリストを返す。他のコマの影響を無視。
 *
 * @param {Number} ox 現在地
 * @param {Number} oy 現在地
 *
 * @return {Object} 利いているマスのリスト
 *                  {rin8   :[[x, y], ...], 隣接8マス
 *                  straight:[[x, y], ...]} 隣接8マスより遠い
 */
Koma.prototype.getKiki2 = function(ox, oy) {
  //
  var list = {rin8: [], straight: []};
  var movablemasulist = this.movable();
  var sz = movablemasulist.length;
  for (var idx = 0; idx < sz; ++idx) {
    var ax = movablemasulist[idx][0];
    var ay = movablemasulist[idx][1];
    var straight = movablemasulist[idx][2];
    if (straight) {
      list = this.getStraightKiki(list, ax, ay, ox, oy, false);
    } else {
      list = this.getCloseKiki(list, ax, ay, ox, oy);
    }
  }
  return list;
};

Koma.prototype.getStraightMovable = function (list, ax, ay, ox, oy) {
  var x = ox;
  var y = oy;
  if (this.teban === Koma.SENTEBAN) {
    ay = -ay;
  }

  for ( ; ; ) {
    x += ax;
    y += ay;
    if (x < 0 || x > 8) break;
    if (y < 0 || y > 8) break;
    var teban = ban[x][y].koma.teban;
    if (teban === this.teban) break;
    list.push([x, y]);
    if (teban !== Koma.AKI) break;
  }
  return list;
};

Koma.prototype.getCloseMovable = function (list, ax, ay, ox, oy) {
  var x, y;
  x = ox + ax;
  if (x < 0 || x > 8) return list;

  if (this.teban === Koma.SENTEBAN) {
    y = oy - ay;
  } else {
    y = oy + ay;
  }
  if (y < 0 || y > 8) return list;

  var teban = ban[x][y].koma.teban;
  if (teban !== this.teban) {
    list.push([x, y]);
  }
  return list;
};

/**
 * 動けるマスのリストを返す。
 *
 * @param {Number} ox 現在地
 * @param {Number} oy 現在地
 *
 * @return {Array} 動けるマスのリスト[[x, y], ....]
 */
Koma.prototype.getMovable = function(ox, oy) {
  var list = [];
  var movablemasulist = this.movable();
  var sz = movablemasulist.length;
  for (var idx = 0; idx < sz; ++idx) {
    var ax = movablemasulist[idx][0];
    var ay = movablemasulist[idx][1];
    var straight = movablemasulist[idx][2];
    if (straight) {
      list = this.getStraightMovable(list, ax, ay, ox, oy);
    } else {
      list = this.getCloseMovable(list, ax, ay, ox, oy);
    }
  }
  return list;
};

/**
 * 王手になる指し手を抽出
 * @param  {Array} ohtelist 王手になる指し手リスト
 * @param  {Number} x       現在地
 * @param  {Number} y       現在地
 * @param  {Number} gx      玉の現在地
 * @param  {Number} gy      玉の現在地
 * @param  {Number} nari    成った手かどうか
 * @return {Array} 王手になる指し手リスト
 */
Koma.prototype.pickup_ohte = function(ohtelist, x, y, gx, gy, nari) {
  var list = this.getMovable(x, y);
  var sz = list.length;
  for (var i = 0; i < sz; ++i) {
    var xx = list[i][0];
    var yy = list[i][1];
    // 相手方の玉の位置に移動できるなら王手になる手
    if (xx === gx && yy === gy) {
      ohtelist.push([x, y, nari]);
      return ohtelist;
    }
  }
  return ohtelist;
}

/**
 * 王手になるマスのリストを返す。
 *
 * @param {Number} ox 現在地
 * @param {Number} oy 現在地
 *
 * @return {Array} 王手になる手のリスト[[x, y, nari], ....]
 */
Koma.prototype.getOhteMovable = function(ox, oy) {
  var mvlist = this.getMovable(ox, oy);  // 移動可能なマス
  if (mvlist.length <= 0) {
    return [];
  }
  var gx, gy;
  if (this.teban === Koma.SENTEBAN) {
    gx = sentegyoku.x;
    gy = sentegyoku.y;
  } else if (this.teban === Koma.GOTEBAN) {
    gx = gotegyoku.x;
    gy = gotegyoku.y;
  } else {
    return null;
  }
  var koma;
  var ohtelist = [];
  var szmvl = mvlist.length;
  for (var j = 0; j < szmvl; ++j) {
    var x = mvlist[j][0];
    var y = mvlist[j][1];
    // 移動した先に玉がある場合
    // すでに王手になっているということなので、ルール上ありえない条件
    /* if (x === gx && y === gy) {
     ohtelist.push(mvlist[i]);
    }*/
    /*
     * Koma.NARENAI 成れない
     * Koma.NARERU  成れる
     * Koma.NARU    成らないといけない
     * Koma.NATTA   成った後
     */
    switch (this.checkNari(oy, y)) {
    case Koma.NATTA:
      ohtelist = this.pickup_ohte(ohtelist, x, y, gx, gy, Koma.NARAZU);
      break;
    case Koma.NARENAI:
      ohtelist = this.pickup_ohte(ohtelist, x, y, gx, gy, Koma.NARAZU);
      break;
    case Koma.NARERU:
      // 成る成らないで評価
      ohtelist = this.pickup_ohte(ohtelist, x, y, gx, gy, Koma.NARAZU);
      koma = this.clone();
      koma.nari = Koma.NARI;
      ohtelist = koma.pickup_ohte(ohtelist, x, y, gx, gy, Koma.NARI);
      break;
    case Koma.NARU:
      // 成ってから評価
      koma = this.clone();
      koma.nari = Koma.NARI;
      ohtelist = koma.pickup_ohte(ohtelist, x, y, gx, gy, Koma.NARI);
      break;
    }
  }
  return ohtelist;
};

/**
 * 打てるマスのリストを返す。
 *
 * @return {Array} 打てるマスのリスト
 */
Koma.prototype.getUchable = function() {
  return this.getUchableGeneral(0, 9);
};

/**
 * 打てるマスのリストを返す。
 *
 * @param {Number} starty 打てる段の始まり
 * @param {Number} endyy  打てる段の終わり
 *
 * @return {Array} 打てるマスのリスト
 */
Koma.prototype.getUchableGeneral = function(starty, endy) {
  var list = [];
  for (var i = 0; i < 9; ++i) {
    for (var j = starty; j < endy; ++j) {
      if (ban[i][j].koma.teban === Koma.AKI) {
        list.push([i, j]);
      }
    }
  }
  return list;
};

/**
 * CSA形式で１手を出力
 *
 * @param {Number} fromx 移動元の座標
 * @param {Number} fromy 移動元の座標
 * @param {Number} tox 移動先の座標
 * @param {Number} toy 移動先の座標
 *
 *
 * @return {String} １手分の棋譜
 */
Koma.prototype.kifuCSA = function(fromx, fromy, tox, toy) {
  fromx++;
  fromy++;
  tox++;
  toy++;

  var str;
  if (this.teban === Koma.SENTEBAN) {
    str = Koma.SenteStrCSA;
  } else if (this.teban === Koma.GOTEBAN) {
    str = Koma.GoteStrCSA;
  }
  str += fromx;
  str += fromy;
  str += tox;
  str += toy;
  if (this.nari === Koma.NARI) {
    str += this.strntypeCSA;
  } else {
    str += this.strtypeCSA;
  }
  return str;
};

Koma.prototype.kifuDouNumKIF = function(tox, toy, lastx, lasty) {
  if (tox === lastx && toy === lasty) {
    return Koma.DouStrKIF;
  } else {
    return Koma.ZenkakuNum[tox] + Koma.KanjiNum[toy];
  }
};

/**
 * KIF形式で１手を出力
 *
 * @param {Number} fromx 移動元の座標
 * @param {Number} fromy 移動元の座標
 * @param {Number} tox 移動先の座標
 * @param {Number} toy 移動先の座標
 * @param {Number} lastx 直前の手の移動先の座標
 * @param {Number} lasty 直前の手の移動先の座標
 * @param {Number} nari 成ったかどうか
 *
 * @return {String} １手分の棋譜
 */
Koma.prototype.kifuKIF = function(fromx, fromy, tox, toy, lastx, lasty, nari) {
  fromx++;
  fromy++;

  var str = '';
  /* if (this.teban === Koma.SENTEBAN) {
   str = Koma.SenteStrKIF;
  } else if (this.teban === Koma.GOTEBAN) {
   str = Koma.GoteStrKIF;
  } */
  str += this.kifuDouNumKIF(tox, toy, lastx, lasty);
  if (this.nari === Koma.NARI) {
    if (nari === Koma.NARI) {
      str += this.strtypeKIF;
      str += Koma.NariStrKIF;
    } else {
      str += this.strntypeKIF;
    }
  } else {
    str += this.strtypeKIF;
    if (fromx === 0) {
      str += Koma.UchiStrKIF;
    }
  }
  if (fromx !== 0) {
    str += '(' + fromx + '' + fromy + ')';
  }
  return str;
};

/**
 * 独自形式で１手を出力
 *
 * @param {Number} fromx 移動元の座標
 * @param {Number} fromy 移動元の座標
 * @param {Number} tox   移動先の座標
 * @param {Number} toy   移動先の座標
 * @param {Number} lastx 直前の手の移動先の座標
 * @param {Number} lasty 直前の手の移動先の座標
 * @param {Number} nari  成ったかどうか
 *
 * @return {String} １手分の棋譜
 */
Koma.prototype.kifuKIFU = function(fromx, fromy, tox, toy, lastx, lasty, nari) {
  fromx++;
  fromy++;

  var str;
  if (this.teban === Koma.SENTEBAN) {
    str = Koma.SenteStrOrg;
  } else if (this.teban === Koma.GOTEBAN) {
    str = Koma.GoteStrOrg;
  }
  str += this.kifuDouNumKIF(tox, toy, lastx, lasty);
  if (this.nari === Koma.NARI) {
    if (nari === Koma.NARI) {
      str += this.strtypeKIF;
      str += Koma.NariStrKIF;
    } else {
      str += this.strntypeKIF;
    }
  } else if (nari === Koma.NARERU) {
    str += this.strtypeKIF;
    str += Koma.FunariStr;
  } else {
    str += this.strtypeKIF;
    if (fromx === 0) {
      str += Koma.UchiStrKIF;
    }
  }
  if (fromx !== 0) {
    str += ' (' + fromx + '' + fromy + ')';
  }
  return str;
};

/**
 * CSA形式で１手を短め出力
 *
 * @param {Number} x 座標
 * @param {Number} y 座標
 *
 * @return {String} １手分の棋譜
 */
Koma.prototype.kifuShortCSA = function(x, y) {
  x++;
  y++;

  var str;
  if (this.teban === Koma.SENTEBAN) {
    str = Koma.SenteStrCSA;
  } else if (this.teban === Koma.GOTEBAN) {
    str = Koma.GoteStrCSA;
  }
  str += x;
  str += y;
  if (this.nari === Koma.NARI) {
    str += this.strntypeCSA;
  } else {
    str += this.strtypeCSA;
  }
  return str;
};

Koma.prototype.checkNariFromPos = function(ugokeru, fromy, toy) {
  if (ugokeru) {
    // 動ければNARERU
    if (fromy < 3 || toy < 3) {
      return Koma.NARERU;
    }
  } else {
    // 動けなければNARU
    if (fromy < 3 || toy < 3) {
      return Koma.NARU;
    }
  }
  return Koma.NARENAI;
};

Koma.prototype.checkNariSente = function(fromy, toy) {
  // 動けるかのチェック
  var ugokeru = this.checkMovable(toy);
  return this.checkNariFromPos(ugokeru, fromy, toy)
};

Koma.prototype.checkNariGote = function(fromy, toy) {
  // 動けるかのチェック
  var _fromy = 9-1-fromy;
  var _toy = 9-1-toy;
  var ugokeru = this.checkMovable(_toy);
  return this.checkNariFromPos(ugokeru, _fromy, _toy)
};

/**
 * 成れるかどうかをチェック
 *
 * @param {Number} fromy 移動元の座標
 * @param {Number} toy   移動先の座標
 *
 * @return {Number} Koma.NARENAI 成れない
 *                  Koma.NARERU  成れる
 *                  Koma.NARU    成らないといけない
 *                  Koma.NATTA   成った後
 */
Koma.prototype.checkNari = function(fromy, toy) {
  if (this.nari === Koma.NARI) {
    return Koma.NATTA;
  }
  if (this.teban === Koma.SENTEBAN) {
    return this.checkNariSente(fromy, toy);
  } else if (this.teban === Koma.GOTEBAN) {
    return this.checkNariGote(fromy, toy);
  }
  return Koma.NARENAI;
};

Koma.prototype.movemsg = function(tox, toy)
{
  var x = this.x;
  var toxy = Koma.ZenkakuNum[tox] + Koma.KanjiNum[toy];
  var str = this.getTypeStr();
  if (x < 0) {
    return str + 'を' + toxy + 'に打ちます。';
  } else {
    var y = this.y;
    var fromxy = Koma.ZenkakuNum[x] + Koma.KanjiNum[y];
    return str + 'を' + fromxy + 'から' + toxy + 'に移動します。';
  }
}

Koma.prototype.InitStr = function(a, b, c, d, e, f, g, h, i, j)
{
  this.strtype = a;
  this.strntype = b;
  this.strtypeKIF = c;
  this.strntypeKIF = d;
  this.strtypeKIFU = e;
  this.strntypeKIFU = f;
  this.strtypeCSA = g;
  this.strntypeCSA = h;
  this.strtypeIMG = i;
  this.strntypeIMG = j;
}

/**
 * 動けるマスの情報の初期化
 * @param  {Array} funari 不成状態での動けるところ
 * @param  {Array} nari   成り状態での動けるところ
 */
Koma.prototype.InitMovable = function(funari, nari)
{
  this.funariMovable = funari;
  this.nariMovable = nari;
}

Fu.prototype = new Koma();
/**
 * 歩クラス
 *
 * @class
 * @constructor
 *
 * @param {Number} teban 先手後手
 * @param {Number} x 座標
 * @param {Number} y 座標
 */
function Fu(teban, x, y) {
  Koma.call(this, teban, x, y);

  this.InitStr(Koma.FuStrLong, Koma.NFuStrLong, Koma.FuStrKIF, Koma.NFuStrKIF,
    Koma.FuStrKIF, Koma.NFuStrKIF, Koma.FuStr, Koma.NFuStr,
    Koma.FuStrIMG, Koma.NFuStrIMG);
  this.InitMovable(Koma.FuMovable, Koma.KinMovable);
  this.id = Koma.FuID;
}

/**
 * 打てるマスのリストを返す。(二歩対策)
 *
 * @override
 *
 * @return {Array} 打てるマスのリスト
 */
Fu.prototype.getUchable = function() {
  var starty = 0;
  var endy = 9;
  if (this.teban === Koma.SENTEBAN) {
    starty = 1;
  } else {
    endy = 8;
  }
  var list = [];
  for (var i = 0; i < 9; ++i) {
    if (this.check2FU(i, starty, endy)) {
      continue;
    }
    for (var j = starty; j < endy; ++j) {
      if (ban[i][j].koma.teban === Koma.AKI) {
        list.push([i, j]);
      }
    }
  }
  return list;
};

/**
 * その他の駒がないとしてこれ以上動けるか
 *
 * @param {Number} oy 現在地。後手はひっくり返して(9-1-y)から入れること。
 *
 * @return {Boolean} true:まだ動ける, false:もう無理。
 */
Fu.prototype.checkMovable = function(oy) {
  return (oy !== 0);
};

/**
 * 二歩になるかどうかチェックする。
 *
 * @param {Number} x      チェックする筋
 * @param {Number} starty チェックする範囲
 * @param {Number} endy   チェックする範囲
 *
 * @return {Boolean} true:二歩になる, false:ならない
 */
Fu.prototype.check2FU = function(x, starty, endy) {
  for (var j = starty; j < endy; ++j) {
    if (ban[x][j].koma.id === Koma.FuID &&
        ban[x][j].koma.nari === Koma.NARAZU &&
        ban[x][j].koma.teban === this.teban) {
      return true;
    }
  }
  return false;
};

Kyosha.prototype = new Koma();
/**
 * 香車クラス
 *
 * @class
 * @constructor
 *
 * @param {Number} teban 先手後手
 * @param {Number} x 座標
 * @param {Number} y 座標
 */
function Kyosha(teban, x, y) {
  Koma.call(this, teban, x, y);

  this.InitStr(Koma.KyoshaStrLong, Koma.NKyoshaStrLong, Koma.KyoshaStrKIF,
    Koma.NKyoshaStrKIF, Koma.KyoshaStrKIF, Koma.NKyoshaStrKIF,
    Koma.KyoshaStr, Koma.NKyoshaStr, Koma.KyoshaStrIMG, Koma.NKyoshaStrIMG);
  this.InitMovable(Koma.KyoshaMovable, Koma.KinMovable);
  this.id = Koma.KyoshaID;
}

/**
 * その他の駒がないとしてこれ以上動けるか
 *
 * @param {Number} oy 現在地。後手はひっくり返して(9-1-y)から入れること。
 *
 * @return {Boolean} true:まだ動ける, false:もう無理。
 */
Kyosha.prototype.checkMovable = function(oy) {
  return (oy !== 0);
};

/**
 * 打てるマスのリストを返す。
 *
 * @return {Array} 打てるマスのリスト
 */
Kyosha.prototype.getUchable = function() {
  var starty, endy;
  if (this.teban === Koma.SENTEBAN) {
    starty = 1;
    endy = 9;
  } else {
    starty = 0;
    endy = 8;
  }
  return this.getUchableGeneral(starty, endy);
};

Keima.prototype = new Koma();
/**
 * 桂馬クラス
 *
 * @class
 * @constructor
 *
 * @param {Number} teban 先手後手
 * @param {Number} x 座標
 * @param {Number} y 座標
 */
function Keima(teban, x, y) {
  Koma.call(this, teban, x, y);

  this.InitStr(Koma.KeimaStrLong, Koma.NKeimaStrLong, Koma.KeimaStrKIF,
    Koma.NKeimaStrKIF, Koma.KeimaStrKIF, Koma.NKeimaStrKIF,
    Koma.KeimaStr, Koma.NKeimaStr, Koma.KeimaStrIMG, Koma.NKeimaStrIMG);
  this.InitMovable(Koma.KeimaMovable, Koma.KinMovable);
  this.id = Koma.KeimaID;
}

/**
 * その他の駒がないとしてこれ以上動けるか
 *
 * @param {Number} oy 現在地。後手はひっくり返して(9-1-y)から入れること。
 *
 * @return {Boolean} true:まだ動ける, false:もう無理。
 */
Keima.prototype.checkMovable = function(oy) {
  return (oy > 1);
};

/**
 * 打てるマスのリストを返す。
 *
 * @return {Array} 打てるマスのリスト
 */
Keima.prototype.getUchable = function() {
  var starty, endy;
  if (this.teban === Koma.SENTEBAN) {
    starty = 2;
    endy = 9;
  } else {
    starty = 0;
    endy = 7;
  }
  return this.getUchableGeneral(starty, endy);
};

Gin.prototype = new Koma();
/**
 * 銀将クラス
 *
 * @class
 * @constructor
 *
 * @param {Number} teban 先手後手
 * @param {Number} x 座標
 * @param {Number} y 座標
 */
function Gin(teban, x, y) {
  Koma.call(this, teban, x, y);

  this.InitStr(Koma.GinStrLong, Koma.NGinStrLong, Koma.GinStrKIF,
    Koma.NGinStrKIF, Koma.GinStrKIF, Koma.NGinStrKIF, Koma.GinStr,
    Koma.NGinStr, Koma.GinStrIMG, Koma.NGinStrIMG);
  this.InitMovable(Koma.GinMovable, Koma.KinMovable);
  this.id = Koma.GinID;
}

Kin.prototype = new Koma();
/**
 * 金将クラス
 *
 * @class
 * @constructor
 *
 * @param {Number} teban 先手後手
 * @param {Number} x 座標
 * @param {Number} y 座標
 */
function Kin(teban, x, y) {
  Koma.call(this, teban, x, y);

  this.InitStr(Koma.KinStrLong, Koma.KinStrLong, Koma.KinStrKIF, Koma.KinStrKIF,
    Koma.KinStrKIF, Koma.KinStrKIF, Koma.KinStr, Koma.KinStr,
    Koma.KinStrIMG, Koma.KinStrIMG);
  this.InitMovable(Koma.KinMovable, Koma.KinMovable);
  this.id = Koma.KinID;
}

/**
 * 成れるかどうかをチェック
 *
 * @param {Number} fromy 移動元の座標
 * @param {Number} toy   移動先の座標
 *
 * @return {Number} Koma.NARENAI 成れない
 */
Kin.prototype.checkNari = function(fromy, toy) {
  return Koma.NARENAI;
};

Kaku.prototype = new Koma();
/**
 * 角行クラス
 *
 * @class
 * @constructor
 *
 * @param {Number} teban 先手後手
 * @param {Number} x 座標
 * @param {Number} y 座標
 */
function Kaku(teban, x, y) {
  Koma.call(this, teban, x, y);

  this.InitStr(Koma.KakuStrLong, Koma.NKakuStrLong, Koma.KakuStrKIF,
    Koma.NKakuStrKIF, Koma.KakuStrKIF, Koma.NKakuStrKIF, Koma.KakuStr,
    Koma.NKakuStr, Koma.KakuStrIMG, Koma.NKakuStrIMG);
  this.InitMovable(Koma.KakuMovable, Koma.UmaMovable);
  this.id = Koma.KakuID;
}

Hisha.prototype = new Koma();
/**
 * 飛車クラス
 *
 * @class
 * @constructor
 *
 * @param {Number} teban 先手後手
 * @param {Number} x 座標
 * @param {Number} y 座標
 */
function Hisha(teban, x, y) {
  Koma.call(this, teban, x, y);

  this.InitStr(Koma.HishaStrLong, Koma.NHishaStrLong, Koma.HishaStrKIF,
    Koma.NHishaStrKIF, Koma.HishaStrKIF, Koma.NHishaStrKIF,
    Koma.HishaStr, Koma.NHishaStr, Koma.HishaStrIMG, Koma.NHishaStrIMG);
  this.InitMovable(Koma.HishaMovable, Koma.RyuMovable);
  this.id = Koma.HishaID;
}

// 成れない駒なところが金と同じ
Gyoku.prototype = new Kin();
/**
 * 玉将クラス
 *
 * @class
 * @constructor
 *
 * @param {Number} teban 先手後手
 * @param {Number} x 座標
 * @param {Number} y 座標
 */
function Gyoku(teban, x, y) {
  Koma.call(this, teban, x, y);

  this.InitStr((teban === Koma.SENTEBAN) ? Koma.GyokuStrLong : Koma.OuStrLong,
    Koma.GyokuStrLong, Koma.GyokuStrKIF, Koma.GyokuStrKIF,
    Koma.GyokuStrKIF, Koma.GyokuStrKIF, Koma.GyokuStr, Koma.GyokuStr,
    Koma.GyokuStrIMG, Koma.GyokuStrIMG);
  this.InitMovable(Koma.GyokuMovable, Koma.GyokuMovable);
  this.id = Koma.GyokuID;
}

/**
 * 成れるかどうかをチェック
 *
 * @param {Number} fromy 移動元の座標
 * @param {Number} toy   移動先の座標
 *
 * @return {Number} Koma.NARENAI 成れない
 */
Gyoku.prototype.checkNari = function(fromy, toy) {
  return Koma.NARENAI;
};

function build_movecsa(koma, from_x, from_y, to_x, to_y, tottaid, nari) {
  var str ;

  if (koma.teban === Koma.SENTEBAN) {
    str = Koma.SenteStrCSA;
  } else {
    str = Koma.GoteStrCSA;
  }

  str += from_x + 1;
  str += from_y + 1;

  str += to_x + 1;
  str += to_y + 1;

  if (nari === Koma.NARI || koma.nari !== Koma.NARI) {
    str += koma.strtypeCSA;
  } else {
    str += koma.strntypeCSA;
  }

  if (tottaid === Koma.NoID) {
    str += '__';
  } else if (tottaid >= 1000) {
    str += tottakoma.strntypeCSA;
  } else {
    str += tottakoma.strtypeCSA;
  }

  if (nari === Koma.NARI) {
    str += 'P';
  }

  return str;
}

/**
 * コマの移動。
 *
 * @param {Object} koma 移動するコマ
 * @param {Number} to_x 移動先
 * @param {Number} to_y 移動先
 * @param {Number} nari 成る(Koma.NARI)か成らない(Koma.Narazu)か
 *                      成る場合は駒を裏返す(=成った駒を元に戻せる)
 */
function move(koma, to_x, to_y, nari) {
  var from_x = koma.x;
  var from_y = koma.y;

  koma.kaesu(nari);

  var tottaid = mykifu.totta_id;

  mykifu.genKifu(koma, from_x, from_y, to_x, to_y, nari);
  // console.log(mykifu.genKifu(masu.koma, from_x, from_y, to_x, to_y, nari));
  // console.log(masu.koma.CSA(from_x, from_y, to_x, to_y));
  // console.log(masu.koma.KIF(from_x, from_y, to_x, to_y, nari));

  koma.x = to_x;
  koma.y = to_y;

  var temp = ban[to_x][to_y].koma;
  ban[to_x][to_y].koma = koma;
  ban[from_x][from_y].koma = temp;

  if (activeteban === Koma.SENTEBAN) {
    activeteban = Koma.GOTEBAN;
  } else {
    activeteban = Koma.SENTEBAN;
  }

  movecsa = build_movecsa(koma, from_x, from_y, to_x, to_y, tottaid, nari);
}

/**
 * ban[x][y]にある駒を取る。
 *
 * @param {Number} x 取る駒がある座標
 * @param {Number} y 取る駒がある座標
 */
function toru(x, y) {
  var koma = ban[x][y].koma;
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
  ban[x][y].koma = new Koma();
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
  if (koma.id < Koma.GyokuID)
    tegoma[koma.id][0].push(koma);
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
 * @param {Number} to_x 移動先
 * @param {Number} to_y 移動先
 */
function uchi(tegoma, koma, to_x, to_y) {
  // console.log(koma.CSA(-1, -1, to_x, to_y));
  // console.log(koma.KIF(-1, -1, to_x, to_y, Koma.Narazu));
  // console.log(mykifu.genKifu(koma, -1, -1, to_x, to_y, Koma.Narazu));
  mykifu.genKifu(koma, -1, -1, to_x, to_y, Koma.Narazu, koma.id);

  var k = komadai_del(tegoma, koma.id);

  ban[to_x][to_y].koma = k;

  k.x = to_x;
  k.y = to_y;

  if (activeteban === Koma.SENTEBAN) {
    activeteban = Koma.GOTEBAN;
  } else {
    activeteban = Koma.SENTEBAN;
  }

  movecsa = '';
  if (k.teban === Koma.SENTEBAN) {
    movecsa += Koma.SenteStrCSA;
  } else {
    movecsa += Koma.GoteStrCSA;
  }
  movecsa += '00';
  movecsa += to_x + 1;
  movecsa += to_y + 1;
  movecsa += k.strtypeCSA;
  movecsa += '__';
}

/**
 * 駒を打つ。
 *
 * @param {Object} tegoma 手駒リスト
 * @param {Number} koma_id 打つ駒のID
 * @param {Number} to_x 移動先
 * @param {Number} to_y 移動先
 */
function uchi2(tegoma, koma_id, to_x, to_y) {
  var k = komadai_del(tegoma, koma_id);

  ban[to_x][to_y].koma = k;

  k.x = to_x;
  k.y = to_y;

  if (activeteban === Koma.SENTEBAN) {
    activeteban = Koma.GOTEBAN;
  } else {
    activeteban = Koma.SENTEBAN;
  }

  movecsa = '';
  if (k.teban === Koma.SENTEBAN) {
    movecsa += k.SenteStrCSA;
  } else {
    movecsa += k.GoteStrCSA;
  }
  movecsa += '00';
  movecsa += to_x + 1;
  movecsa += to_y + 1;
  movecsa += k.strtypeCSA;
  movecsa += '__';
}

/**
 * nari==Koma.NARIなら駒をひっくり返す。
 *
 * @param  {[type]} nari Koma.NARI or not
 */
Koma.prototype.kaesu = function (nari) {
  if (nari === Koma.NARI) {
    if (this.nari === Koma.NARI) {
      this.nari = Koma.NARAZU;
    } else {
      this.nari = Koma.NARI;
    }
  }
};

/**
 * コマの移動。(感想戦用)
 *
 * @param {Object} koma 移動するコマ
 * @param {Number} to_x 移動先
 * @param {Number} to_y 移動先
 * @param {Number} nari 成る(Koma.NARI)か成らない(Koma.Narazu)か
 *                      成る場合は駒を裏返す(=成った駒を元に戻せる)
 */
function move2(koma, to_x, to_y, nari) {
  var from_x = koma.x;
  var from_y = koma.y;

  koma.kaesu(nari);

  // mykifu.genKifu(masu.koma, from_x, from_y, to_x, to_y, nari);
  // console.log(mykifu.genKifu(masu.koma, from_x, from_y, to_x, to_y, nari));
  // console.log(masu.koma.CSA(from_x, from_y, to_x, to_y));
  // console.log(masu.koma.KIF(from_x, from_y, to_x, to_y, nari));

  koma.x = to_x;
  koma.y = to_y;

  var temp = ban[to_x][to_y].koma;
  ban[to_x][to_y].koma = koma;
  ban[from_x][from_y].koma = temp;

  if (activeteban === Koma.SENTEBAN) {
    activeteban = Koma.GOTEBAN;
  } else {
    activeteban = Koma.SENTEBAN;
  }

  var tottaid = mykifu.totta_id;
  movecsa = build_movecsa(koma, from_x, from_y, to_x, to_y, tottaid, nari);
}

/**
 * 取った駒を盤に戻す。(感想戦用)
 *
 * @param {Object} tegoma 手駒リスト
 * @param {Object} koma_id 戻す駒のID
 * @param {Number} to_x 移動先
 * @param {Number} to_y 移動先
 */
function torimodosu(tegoma, koma_id, to_x, to_y) {
  var nari = false;
  // 成り駒を取った時は+1000してIDを覚えてある
  if (koma_id >= 1000) {
    koma_id -= 1000;
    nari = true;
  }
  var k = komadai_del(tegoma, koma_id);
  if (k.teban === Koma.SENTEBAN) {
    k.teban = Koma.GOTEBAN;
  } else {
    k.teban = Koma.SENTEBAN;
  }
  if (nari) {
    k.nari = Koma.NARI;
  }
  ban[to_x][to_y].koma = k;

  k.x = to_x;
  k.y = to_y;
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
      if (koma.teban === Koma.AKI) {
        continue;
      }
      if (koma.teban === gyoku.teban) {
        continue;
      }

      var masulist = koma.getMovable(i, j);
      // var masulist = koma.getMovable(koma.x, koma.y);
      // var masulist = koma.getMovable();
      for (var idx = 0; idx < masulist.length; ++idx) {
      // for (var idx in masulist) {
        if (masulist[idx][0] === gyoku.x && masulist[idx][1] === gyoku.y) {
          return true;
        }
      }
    }
  }
  return false;
}

function KyokumenCSATegoma(tegoma) {
  var kyokumen = '';
  for (var idx in tegoma) {
    if (tegoma[idx][0].length !== 0) {
      var koma = tegoma[idx][1].koma;
      kyokumen += 'P' + koma.kifuShortCSA(-1, -1) + '\n';
    }
  }
  return kyokumen;
}

/**
 * 局面の出力CSA
 *
 * @return {String} 局面のデータ文字列
 */
function KyokumenCSA() {
  var kyokumen = '';
  for (var i = 0; i < 9; ++i) {
    kyokumen += 'P' + (i + 1);
    for (var j = 8; j >= 0; --j) {
      var koma = ban[j][i].koma;
      kyokumen += koma.getShortStrCSA();
    }
    kyokumen += '\n';
  }
  kyokumen += KyokumenCSATegoma(sentegoma);
  kyokumen += KyokumenCSATegoma(gotegoma);
  // kyokumen += '\nP-00AL\n';  // 残りは全部後手の駒台の上
  if (activeteban === Koma.SENTEBAN) {
    kyokumen += '+';
  } else {
    kyokumen += '-';
  }
  return kyokumen;
}

function KyokumenKIFTegoma(tegoma) {
  var komadai = '';
  for (var idx in gotegoma) {
    if (tegoma[idx][0].length !== 0) {
      var koma = tegoma[idx][1].koma;
      komadai += koma.strtypeKIF
          + Koma.KanjiNum[tegoma[idx][0].length - 1] + '　';
    }
  }
  if (komadai === '') {
    komadai = 'なし';
  }
  return komadai;
}

/**
 * 局面の出力KIF
 *
 * @return {String} 局面のデータ文字列
 */
function KyokumenKIF() {
  var kyokumen = '後手の持駒：';

  var komadai = KyokumenKIFTegoma(gotegoma);
  kyokumen += komadai;

  kyokumen += '\n  ９ ８ ７ ６ ５ ４ ３ ２ １\n+---------------------------+\n';
  for (var i = 0; i < 9; ++i) {
    var koma;
    kyokumen += '|';
    for (var j = 8; j >= 0; --j) {
      koma = ban[j][i].koma;
      kyokumen += koma.getShortStrKIF();
    }
    kyokumen += '|' + Koma.KanjiNum[i] + '\n';
  }
  kyokumen += '+---------------------------+\n先手の持駒：';

  komadai = KyokumenKIFTegoma(gotegoma);
  kyokumen += komadai;

  kyokumen += '\n手数＝' + mykifu.NTeme + ' ' + mykifu.lastTe.strs + 'まで\n';

  return kyokumen;
}

/**
 * 棋譜管理クラス
 *
 * @class
 * @constructor
 *
 * @param {Number} md 先手後手空き
 */
function Kifu(md) {
  /** 生成する棋譜の形式 */
  this.mode = md || Kifu.Org;
  /** 初手からの棋譜 */
  this.kifuText = '';
  /** 直前の手の情報 */
  this.lastTe = {};
  /** 直前の手の棋譜 */
  this.lastTe.str = '';
  /** 直前の手の棋譜 短め */
  this.lastTe.strs = '';
  /** 直前の手の座標 */
  this.lastTe.x = 10;
  /** 直前の手の座標 */
  this.lastTe.y = 10;
  /** 今何手目か */
  this.NTeme = 0;
  /** 直前に取った駒のID */
  this.totta_id = Koma.NoID;
  /** 対局中(又は直近)の棋譜 */
  this.Honp = []; // 一手分の棋譜 [手番, fromx, fromy, tox, toy, nari, totta_id];

  /** 先手の名前 */
  this.sentename = '';
  /** 後手の名前 */
  this.gotename = '';
  /** 棋戦名 */
  this.eventname = '';
  /** 場所 */
  this.sitename = '';
  /** 開始時間 */
  this.starttime = '';
  /** 終了時間 */
  this.endtime = '';
  /** 持ち時間 */
  this.timelimit = '';
  /** 戦型 */
  this.opening = '';
}

/**
 * CSA形式
 *
 * @const
 */
Kifu.CSA = 1;
/**
 * KIF形式
 *
 * @const
 */
Kifu.KIF = 2;
/**
 * 独自形式
 *
 * @const
 */
Kifu.Org = 3;

/**
 * 独自形式(JSON)
 *
 * @const
 */
Kifu.JSON = 4;

/**
 * 一手分を棋譜リストに覚える。
 *
 * @param {Number} teban 手番
 * @param {Number} fromx 移動元の座標
 * @param {Number} fromy 移動元の座標
 * @param {Number} tox   移動先の座標
 * @param {Number} toy   移動先の座標
 * @param {Number} nari  成ったかどうか
 */
Kifu.prototype.Sashita = function(teban, fromx, fromy, tox, toy, nari) {
  this.Honp.push([teban, fromx, fromy, tox, toy, nari]);
};

/**
 * 棋譜リストからある指し手を取り出す。
 *
 * @param {Number} idx 何手目か
 *
 * @return {Array} 一手分の棋譜情報([手番, fromx, fromy, tox, toy, nari])
 */
Kifu.prototype.getHonp = function(idx) {
  return this.Honp[idx];
};

/**
 * 棋譜リストからある範囲を取り出す。
 *
 * @param {Number} from 範囲の始め
 * @param {Number} to   範囲の終わり(この数字の添字で指定される要素を含まない)
 *
 * @return {Array} 指定した分の棋譜情報([手番, fromx, fromy, tox, toy, nari])
 */
Kifu.prototype.getHonp = function(from, to) {
  return this.Honp.slice(from, to);
};

/**
 * 指定した文字でパディングした数値文字列を生成します。
 *
 * @param {Number} number 変換する数値
 * @param {Number} length パディング込みの長さ
 * @param {String} ch     パディングに使う文字
 *
 * @return {String} 変換された文字列
 */
Kifu.prototype.toStringPadding = function(number, length, ch) {
  return (Array(length).join(ch) + number).slice(-length);
};

/**
 * １手分の棋譜を生成
 *
 * @param {Koma}   koma   駒
 * @param {Number} from_x 移動元
 * @param {Number} from_y 移動元
 * @param {Number} to_x   移動先
 * @param {Number} to_y   移動先
 * @param {Number} nari   成ったかどうか
 *
 * @return {String} １手分の棋譜
 */
Kifu.prototype.genKifu = function(koma, from_x, from_y, to_x, to_y, nari) {
  this.NTeme++;
  if (this.mode === Kifu.CSA) {
    this.lastTe.str = koma.kifuCSA(from_x, from_y, to_x, to_y);
  } else if (this.mode === Kifu.KIF) {
    this.lastTe.str = this.toStringPadding(this.NTeme, 4, ' ');
    this.lastTe.str += ' ';
    this.lastTe.strs =
      koma.kifuKIF(from_x, from_y, to_x, to_y,
        this.lastTe.x, this.lastTe.y, nari);
    this.lastTe.str += this.lastTe.strs;
    this.lastTe.str += '   ( 0:00/00:00:00)';
  } else if (this.mode === Kifu.Org) {
    this.lastTe.str = this.toStringPadding(this.NTeme, 4, ' ');
    this.lastTe.str += ' ';
    this.lastTe.strs =
      koma.kifuKIFU(from_x, from_y, to_x, to_y,
        this.lastTe.x, this.lastTe.y, nari);
    this.lastTe.str += this.lastTe.strs;
  } else {
    /* console.log('invalid mode@Kifu class!!(' + this.mode + ')'); */
  }
  this.kifuText += this.lastTe.str + '\n';
  this.lastTe.x = to_x;
  this.lastTe.y = to_y;

  // 一手分の棋譜を記憶 [手番, fromx, fromy, tox, toy, nari, id];
  this.Sashita(koma.teban, from_x, from_y, to_x, to_y, nari, this.totta_id);
  // this.Honp.push(
  //  [koma.teban, from_x, from_y, to_x, to_y, nari, this.totta_id]);
  this.totta_id = Koma.NoID;

  return this.lastTe.str;
};

/**
 * 棋譜情報の初期化
 */
Kifu.prototype.reset = function() {
  this.kifuText = '';
  this.lastTe.str = '';
  this.lastTe.x = 10;
  this.lastTe.y = 10;
  this.NTeme = 0;
  this.Honp = [];
  this.sentename = '';
  this.gotename = '';
  this.eventname = '';
  this.sitename = '';
  this.starttime = '';
  this.endtime = '';
  this.timelimit = '';
  this.opening = '';
};

/**
 * 対局者の名前をセットする。
 *
 * @param {String} sentename 先手の名前
 * @param {String} gotename  後手の名前
 */
Kifu.prototype.setPlayers = function(sentename, gotename) {
  this.sentename = sentename;
  this.gotename = gotename;
};

/**
 * 棋譜ヘッダの出力。
 *
 * @param {String} sentename 先手の名前
 * @param {String} gotename  後手の名前
 */
Kifu.prototype.putHeader = function(sentename, gotename) {
  sentename = sentename || this.sentename;
  gotename = gotename || this.gotename;
  if (this.mode === Kifu.CSA) {
    this.kifuText = this.headerCSA(sentename, gotename);
  } else if (this.mode === Kifu.KIF) {
    this.kifuText = this.headerKIF(sentename, gotename);
  } else if (this.mode === Kifu.Org) {
    this.kifuText = this.headerOrg(sentename, gotename);
  } else {
    /* console.log('invalid mode@Kifu class!!(' + this.mode + ')'); */
  }
};

/**
 * 時刻文字列の生成
 *
 * @param {Time} n 時刻オブジェクト
 *
 * @return {String} 時刻文字列 'yyyy/mm/dd hh/mm/ss'
 */
Kifu.prototype.build_datetime = function(n) {
  var ret = n.getFullYear() + '/' + (n.getMonth() + 1) + '/' + n.getDate()
    + ' ' + n.getHours() + ':' + n.getMinutes() + ':' + n.getSeconds();
  return ret;
}

/**
 * CSA棋譜ヘッダの出力。
 *
 * @param {String} sentename 先手の名前
 * @param {String} gotename  後手の名前
 *
 * @return {String} 棋譜ヘッダ文字列
 */
Kifu.prototype.headerCSA = function(sentename, gotename) {
  var now = new Date();
  var time = this.build_datetime(now);
  var str = "'encoding=Shift_JIS\n" +
            "' ---- JavaScript Shogi CSA形式棋譜ファイル ----\n" +
            'V2.2\n' +
            'N+' + sentename + '\nN-' + gotename + '\n' +
            // $EVENT:レーティング対局室
            '$START_TIME:' + time + '\n' + // 2014/04/01 12:25:21
            'PI\n+\n';
  return str;
};

/**
 * KIF棋譜ヘッダの出力。
 *
 * @param {String} sentename 先手の名前
 * @param {String} gotename  後手の名前
 *
 * @return {String} 棋譜ヘッダ文字列
 */
Kifu.prototype.headerKIF = function(sentename, gotename) {
  var now = new Date();
  var time = this.build_datetime(now);
  var str = '#KIF version=2.0 encoding=Shift_JIS\n' +
            '# ---- JavaScript Shogi 棋譜ファイル ----\n' +
            '開始日時：' + time + '\n' + // 2014/04/26 20:23
            // 終了日時：2014/04/26 20:33:41\n
            // 表題：将棋ウォーズ\n
            '手合割：平手　　\n先手：' + sentename + '\n後手：' + gotename +
            '\n手数----指手---------消費時間--\n';
  return str;
};

/**
 * 独自棋譜ヘッダの出力。
 *
 * @param {String} sentename 先手の名前
 * @param {String} gotename  後手の名前
 *
 * @return {String} 棋譜ヘッダ文字列
 */
Kifu.prototype.headerOrg = function(sentename, gotename) {
  var now = new Date();
  var time = this.build_datetime(now);
  var str = // '#KIF version=2.0 encoding=Shift_JIS\n'
            '# ---- JavaScript Shogi 棋譜ファイル ----\n' +
            '開始日時：' + time + '\n' + // 2014/04/26 20:23
            // 終了日時：2014/04/26 20:33:41\n
            // 表題：将棋ウォーズ\n
            '手合割：平手　　\n先手：' + sentename + '\n後手：' + gotename +
            '\n手数----指手---------消費時間--\n';
  return str;
};

/**
 * 棋譜ヘッダの出力。
 *
 * @param {Object} winte 勝った方の手番
 */
Kifu.prototype.putFooter = function(winte) {
  if (this.mode === Kifu.CSA) {
    this.kifuText += this.footerCSA();
  } else if (this.mode === Kifu.KIF) {
    this.kifuText += this.footerKIF(winte);
  } else if (this.mode === Kifu.Org) {
    this.kifuText += this.footerOrg(winte);
  } else {
    /* console.log('invalid mode@Kifu class!!(' + this.mode + ')'); */
  }
};

/**
 * CSA棋譜フッタの出力。
 *
 * @return {String} 棋譜フッタ文字列
 */
Kifu.prototype.footerCSA = function() {
  return '';  // nothing to do
};

/**
 * KIF棋譜フッタの出力。
 *
 * @param {Object} winte 勝った方の手番
 *
 * @return {String} 棋譜フッタ文字列
 */
Kifu.prototype.footerKIF = function(winte) {
  var str = 'まで' + this.NTeme + 'で';
  if (winte === Koma.SENTEBAN) {
    str += '先手の勝ち';
  } else {
    str += '後手の勝ち';
  }
  return str;
};

/**
 * 独自棋譜フッタの出力。
 *
 * @param {Object} winte 勝った方の手番
 *
 * @return {String} 棋譜フッタ文字列
 */
Kifu.prototype.footerOrg = function(winte) {
  var str = 'まで' + this.NTeme + '手で';
  if (winte === Koma.SENTEBAN) {
    str += '先手の勝ち';
  } else {
    str += '後手の勝ち';
  }
  return str;
};

/**
 * kif.Honpの内容をJSONに変換
 *
 * @return {String} JSON文字列
 */
Kifu.prototype.generateJSON = function() {
  var obj = {};
  obj.kifu = this.Honp;
  return JSON.stringify(obj);
};

/**
 * JSONをkif.Honpに変換
 *
 * @param {String} jsontext JSON文字列
 */
Kifu.prototype.fromJSON = function(jsontext) {
  this.Honp = JSON.parse(jsontext);
};

/**
 * CSA形式の１行読み込み
 *
 * @param {String} text CSA形式の１行分
 */
Kifu.prototype.readLineCSA = function(text) {
  if (/^[+-][0-9]{4}{FU|KY|KE|GI|KI|OU|HI|KA|TO|NY|NE|NG|RY|UM}/.test(text)) {
    var letters = text.split('');
    // 0 1 2 3 4 5 6
    // + 7 7 7 6 F U
    var teban, fromx, fromy, tox, toy, nari, totta_id;
    teban = Koma.SENTEBAN;
    if (letters[0] === '-') {
      teban = Koma.GOTEBAN;
    }
    // 一手分の棋譜 [手番, fromx, fromy, tox, toy, nari, totta_id];
    this.Honp.push([teban, fromx, fromy, tox, toy, nari, totta_id]);
  } else if (text.startsWith('N+')) {
    // alert('先手：'+text);
    this.sentename = text.slice(2);
  } else if (text.startsWith('N-')) {
    // alert('後手：'+text);
    this.gotename = text.slice(2);
  } else if (text.startsWith('$EVENT:')) {
    this.eventname = text.slice(7);
  } else if (text.startsWith('$SITE:')) {
    // 場所
    this.sitename = text.slice(6);
  } else if (text.startsWith('$START_TIME:')) {
    // 開始時間
    this.starttime = text.slice(12);
  } else if (text.startsWith('$END_TIME:')) {
    // 終了時間
    this.endtime = text.slice(10);
  } else if (text.startsWith('$TIME_LIMIT:')) {
    // 持ち時間
    this.timelimit = text.slice(12);
  } else if (text.startsWith('$OPENING:')) {
    // 戦型
    this.opening = text.slice(9);
  } else if (text.startsWith('%')) {
    /*
    %TORYO           投了
    %CHUDAN          中断
    %SENNICHITE      千日手
    %TIME_UP         手番側が時間切れで負け
    %ILLEGAL_MOVE    手番側の反則負け、反則の内容はコメントで記録する
    %+ILLEGAL_ACTION 先手(下手)の反則行為により、後手(上手)の勝ち
    %-ILLEGAL_ACTION 後手(上手)の反則行為により、先手(下手)の勝ち
    %JISHOGI         持将棋
    %KACHI           (入玉で)勝ちの宣言
    %HIKIWAKE        (入玉で)引き分けの宣言
    %MATTA           待った
    %TSUMI           詰み
    %FUZUMI          不詰
    %ERROR           エラー
    */
  } else if (text.startsWith('\'')) {
    // コメント行
  } else if (text.startsWith('P')) {
    // 初期の駒配置
  } else if (text === '+') {
    // 先手番か
    activeteban = Koma.SENTEBAN;
  } else if (text === '-') {
    // 後手番か
    activeteban = Koma.GOTEBAN;
    // } else {
  }
};

/**
 * CSA形式の複数行読み込み
 *
 * @param {Array} arr_text CSAファイルの全文を行毎に区切った配列
 */
Kifu.prototype.readCSA = function(arr_text) {
  var sz = arr_text.length;
  for (var i = 0 ; i < sz; ++i) {
    this.readLineCSA(arr_text[i]);
  }
};

/**
 * KIF形式の複数行読み込み
 *
 * @param {Array} arr_text KIFファイルの全文を行毎に区切った配列
 */
Kifu.prototype.readKIF = function(arr_text) {
  var sz = arr_text.length;
  for (var i = 0 ; i < sz; ++i) {
    this.readLineCSA(arr_text[i]);
  }
};

/**
 * ファイルの読み込み
 *
 * @param {String} path ファイルのパス
 * @param {Number} type ファイルの形式(Kifu.CSA, Kifu.KIF, Kifu.Org)
 */
Kifu.prototype.receive = function(path, type) {
  var ajax = new XMLHttpRequest();
  if (ajax !== null) {
    ajax.open('GET', path, true);
    // CSA file's charset is Shift-JIS.
    ajax.overrideMimeType('text/plain; charset=Shift_JIS');
    ajax.send(null);
    ajax.onload = function(e) {
      var utf8text = ajax.responseText;
      var kifulines = utf8text.split(/\r\n|\r|\n/);
      if (type === Kifu.CSA) {
        // CSA形式
        this.readCSA(kifulines);
      } else if (type === Kifu.KIF) {
        // KIF形式
      } else if (type === Kifu.Org) {
        // 独自形式
      } else {
        // ナニコレ？
      }
    };
  }
};

/**
 * 駒の損得を計算
 *
 * @param {Array} ban 盤面
 * @param {Array} sentegoma 先手の手駒
 * @param {Array} gotegoma 後手の手駒
 *
 * @return {Array} 損得リスト
 */
Kifu.prototype.evalKomazon = function(ban, sentegoma, gotegoma) {
  var komazon = [
    0, 0, 0, 0, 0, 0, 0, 0,  // 歩香桂銀金角飛玉
    0, 0, 0, 0, 0, 0, 0, 0];  // 成り駒

  for (var i = 0; i < 9; ++i) {
    for (var j = 0; j < 9; ++j) {
      var koma = ban[i][j].koma;
      if (koma.teban === Koma.SENTEBAN) {
        if (koma.nari !== Koma.NARI) {
          komazon[koma.id]++;
        } else {
          komazon[koma.id + 8]++;
        }
      } else if (koma.teban === Koma.GOTEBAN) {
        if (koma.nari !== Koma.NARI) {
          komazon[koma.id]--;
        } else {
          komazon[koma.id + 8]--;
        }
      }
    }
  }
  for (i = 0; i < 7; ++i) {
    var num = sentegoma[i][0].length;
    komazon[i] += num;
    num = gotegoma[i][0].length;
    komazon[i] -= num;
  }

  return komazon;
};

/**
 * 駒損を人がわかる形式にする
 *
 * @param {Array} komazon 駒損配列
 * @param {Boolean} nari  成り駒の考え方(true:別扱い, false:成った駒と同等)
 *
 * @return {String} 先手にとっての駒損
 */
Kifu.prototype.komazon_text = function(komazon, nari) {
  var str = '';
  if (nari) {
    for (var i = 0; i < 15; ++i) {
      if (komazon[i] > 0) {
        // 得
        str = Koma.KomaStrTbl[i] + komazon[i] + '枚得,';
      }
    }
    for (i = 0; i < 15; ++i) {
      if (komazon[i] < 0) {
        // 損
        str += Koma.KomaStrTbl[i] + (-komazon[i]) + '枚損,';
      }
    }
  } else {
    var kz = [0, 0, 0, 0, 0, 0, 0];
    for (i = 0; i < 7; ++i) {
      kz[i] = komazon[i] + komazon[i + 8];
    }
    for (i = 0; i < 7; ++i) {
      if (kz[i] > 0) {
        // 得
        str += Koma.KomaStrTbl[i] + kz[i] + '枚得,';
      }
    }
    for (i = 0; i < 7; ++i) {
      if (kz[i] < 0) {
        // 損
        str += Koma.KomaStrTbl[i] + (-kz[i]) + '枚損,';
      }
    }
  }
  if (str === '') {
    str = '損得なし';
  }
  return str;
};

/**
 * 局面を初手に戻す。
 */
Kifu.prototype.shote = function() {
  this.seek_te(0);
};

/**
 * 一手戻す
 */
Kifu.prototype.prev_te = function() {
  this.seek_te(this.NTeme - 1);
};

/**
 * idx手目にする
 *
 * @param {Number} idx 何手目か
 *
 * @return {Boolean} 本譜より大きい値を指定した時はfalse。
 */
Kifu.prototype.seek_te = function(idx) {
  if (idx < 0) {
    return false;
  }
  if (idx > this.Honp.length) {
    return false;
  }

  var te, masu, tegoma;
  if (this.NTeme < idx) {
    while (this.NTeme < idx) {
      te = this.Honp[this.NTeme];
      // [teban, fromx, fromy, tox, toy, nari, totta_id];

      if (te[1] === -1) {
        // 駒を打つ
        if (te[0] === Koma.SENTEBAN) {
          tegoma = sentegoma;
          uchi2(tegoma, te[6], te[3], te[4]);
        } else {
          tegoma = gotegoma;
          uchi2(tegoma, te[6], te[3], te[4]);
        }
      } else {
        if (te[6] > Koma.NoID) {
          toru(te[3], te[4]);
          this.totta_id = Koma.NoID;
        }
        masu = ban[te[1]][te[2]];
        move2(masu, te[3], te[4], te[5]);  // 動かした駒を戻す
      }
      this.NTeme++;
    }
  } else {
    while (this.NTeme > idx) {
      this.NTeme--;
      te = this.Honp[this.NTeme];
      // [teban, fromx, fromy, tox, toy, nari, totta_id];

      if (te[1] === -1) {
        // 駒台に戻す
        toru(te[3], te[4]);
        this.totta_id = Koma.NoID;
      } else {
        masu = ban[te[3]][te[4]];
        move2(masu, te[1], te[2], te[5]);  // 動かした駒を戻す

        if (te[6] >= 0) {
          if (te[0] === Koma.SENTEBAN) {
            tegoma = sentegoma;
          } else {
            tegoma = gotegoma;
          }
          torimodosu(tegoma, te[6], te[3], te[4]);
        }
      }
    }
  }
  return true;
};

/**
 * 次の手に進める
 */
Kifu.prototype.next_te = function() {
  this.seek_te(this.NTeme + 1);
};

/**
 * 最新の局面にする。
 */
Kifu.prototype.last_te = function() {
  this.seek_te(this.Honp.length);
};

var mykifu = new Kifu(Kifu.Org);
// var mykifu = new Kifu(Kifu.KIF);
// var mykifu = new Kifu(Kifu.CSA);
