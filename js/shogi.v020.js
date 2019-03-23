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

Koma.InitStrTable = {
  fu: {
    long: {narazu: Koma.FuStrLong, nari: Koma.NFuStrLong},
    kif: {narazu: Koma.FuStrKIF, nari: Koma.NFuStrKIF},
    kifu: {narazu: Koma.FuStrKIF, nari: Koma.NFuStrKIF},
    csa: {narazu: Koma.FuStr, nari: Koma.NFuStr},
    img: {narazu: Koma.FuStrIMG, nari: Koma.NFuStrIMG}
  },
  kyosha: {
    long: {narazu: Koma.KyoshaStrLong, nari: Koma.NKyoshaStrLong},
    kif: {narazu: Koma.KyoshaStrKIF, nari: Koma.NKyoshaStrKIF},
    kifu: {narazu: Koma.KyoshaStrKIF, nari: Koma.NKyoshaStrKIF},
    csa: {narazu: Koma.KyoshaStr, nari: Koma.NKyoshaStr},
    img: {narazu: Koma.KyoshaStrIMG, nari: Koma.NKyoshaStrIMG}
  },
  keima: {
    long: {narazu: Koma.KeimaStrLong, nari: Koma.NKeimaStrLong},
    kif: {narazu: Koma.KeimaStrKIF, nari: Koma.NKeimaStrKIF},
    kifu: {narazu: Koma.KeimaStrKIF, nari: Koma.NKeimaStrKIF},
    csa: {narazu: Koma.KeimaStr, nari: Koma.NKeimaStr},
    img: {narazu: Koma.KeimaStrIMG, nari: Koma.NKeimaStrIMG}
  },
  gin: {
    long: {narazu: Koma.GinStrLong, nari: Koma.NGinStrLong},
    kif: {narazu: Koma.GinStrKIF, nari: Koma.NGinStrKIF},
    kifu: {narazu: Koma.GinStrKIF, nari: Koma.NGinStrKIF},
    csa: {narazu: Koma.GinStr, nari: Koma.NGinStr},
    img: {narazu: Koma.GinStrIMG, nari: Koma.NGinStrIMG}
  },
  kin: {
    long: {narazu: Koma.KinStrLong, nari: Koma.KinStrLong},
    kif: {narazu: Koma.KinStrKIF, nari: Koma.KinStrKIF},
    kifu: {narazu: Koma.KinStrKIF, nari: Koma.KinStrKIF},
    csa: {narazu: Koma.KinStr, nari: Koma.KinStr},
    img: {narazu: Koma.KinStrIMG, nari: Koma.KinStrIMG}
  },
  kaku: {
    long: {narazu: Koma.KakuStrLong, nari: Koma.NKakuStrLong},
    kif: {narazu: Koma.KakuStrKIF, nari: Koma.NKakuStrKIF},
    kifu: {narazu: Koma.KakuStrKIF, nari: Koma.NKakuStrKIF},
    csa: {narazu: Koma.KakuStr, nari: Koma.NKakuStr},
    img: {narazu: Koma.KakuStrIMG, nari: Koma.NKakuStrIMG}
  },
  hisha: {
    long: {narazu: Koma.HishaStrLong, nari: Koma.NHishaStrLong},
    kif: {narazu: Koma.HishaStrKIF, nari: Koma.NHishaStrKIF},
    kifu: {narazu: Koma.HishaStrKIF, nari: Koma.NHishaStrKIF},
    csa: {narazu: Koma.HishaStr, nari: Koma.NHishaStr},
    img: {narazu: Koma.HishaStrIMG, nari: Koma.NHishaStrIMG}
  },
  gyoku: {
    long: {narazu: Koma.GyokuStrLong, nari: Koma.GyokuStrLong},
    kif: {narazu: Koma.GyokuStrKIF, nari: Koma.GyokuStrKIF},
    kifu: {narazu: Koma.GyokuStrKIF, nari: Koma.GyokuStrKIF},
    csa: {narazu: Koma.GyokuStr, nari: Koma.GyokuStr},
    img: {narazu: Koma.GyokuStrIMG, nari: Koma.GyokuStrIMG}
  },
  ou: {
    long: {narazu: Koma.OuStrLong, nari: Koma.OuStrLong},
    kif: {narazu: Koma.GyokuStrKIF, nari: Koma.GyokuStrKIF},
    kifu: {narazu: Koma.GyokuStrKIF, nari: Koma.GyokuStrKIF},
    csa: {narazu: Koma.GyokuStr, nari: Koma.GyokuStr},
    img: {narazu: Koma.GyokuStrIMG, nari: Koma.GyokuStrIMG}
  }
};

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

Koma.prototype.getTebanStr = function(strSente, strGote) {
  if (this.teban === Koma.SENTEBAN) {
    return strSente;
  } else if (this.teban === Koma.GOTEBAN) {
    return strGote;
  } else {
    return null;
  }
}
/**
 * 表示用の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getStr = function() {
  var str = this.getTebanStr(Koma.SenteStr, Koma.GoteStr);
  if (str == null) {
    return Koma.AkiStr;
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
  if (hanten) {
    str = this.getTebanStr('<div class=gotemoji>', '<div class=sentemoji>');
  } else {
    str = this.getTebanStr('<div class=sentemoji>', '<div class=gotemoji>');
  }
  if (str == null) {
    return Koma.AkiStr;
  }

  str += (this.nari === Koma.NARI) ? this.strntypeKIFU : this.strtypeKIFU;

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
  if (hanten) {
    str = this.getTebanStr('h', '');
  } else {
    str = this.getTebanStr('', 'h');
  }
  if (str == null) {
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
  var str = this.getTebanStr(Koma.SenteStrCSA, Koma.GoteStrCSA);
  if (str == null) {
    return Koma.AkiStrCSA;
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
  var str = this.getTebanStr(Koma.SenteStrKIF, Koma.GoteStrKIF);
  if (str == null) {
    return Koma.AkiStrKIF;
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

Koma.prototype.getStraightMovable = function (list, axy, ox, oy) {
  var x = ox;
  var y = oy;
  var ax = axy.x;
  var ay = axy.y;
  if (this.teban === Koma.SENTEBAN) {
    ay = -ay;
  }

  x += ax;
  y += ay;
  for ( ; 0 <= x && 8 >= x && 0 <= y && 8 >= y ; x += ax, y += ay) {
    var teban = ban[x][y].koma.teban;
    if (teban === this.teban) break;
    list.push([x, y]);
    if (teban !== Koma.AKI) break;
  }

  return list;
};

Koma.prototype.getCloseMovable = function (list, axy, ox, oy) {
  var x, y;
  x = ox + axy.x;
  if (x < 0 || x > 8) return list;

  if (this.teban === Koma.SENTEBAN) {
    y = oy - axy.y;
  } else {
    y = oy + axy.y;
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
    var axy = {
      x: movablemasulist[idx][0],
      y: movablemasulist[idx][1]
    };
    var straight = movablemasulist[idx][2];
    if (straight) {
      list = this.getStraightMovable(list, axy, ox, oy);
    } else {
      list = this.getCloseMovable(list, axy, ox, oy);
    }
  }
  return list;
};

/**
 * 王手になる指し手を抽出
 * @param  {Array} ohtelist 王手になる指し手リスト
 * @param  {Number} xy      現在地
 * @param  {Number} gxy     玉の現在地
 * @param  {Number} nari    成った手かどうか
 * @return {Array} 王手になる指し手リスト
 */
Koma.prototype.pickup_ohte = function(ohtelist, xy, gxy, nari) {
  var list = this.getMovable(xy.x, xy.y);
  var sz = list.length;
  for (var i = 0; i < sz; ++i) {
    var xx = list[i][0];
    var yy = list[i][1];
    // 相手方の玉の位置に移動できるなら王手になる手
    if (xx === gxy.x && yy === gxy.y) {
      ohtelist.push([xy.x, xy.y, nari]);
      return ohtelist;
    }
  }
  return ohtelist;
}

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

  var str = this.getTebanStr(Koma.SenteStrCSA, Koma.GoteStrCSA);

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

Koma.prototype.kifuDouNumKIF = function(toxy, lastxy) {
  if (toxy.x === lastxy.x && toxy.y === lastxy.y) {
    return Koma.DouStrKIF;
  } else {
    return Koma.ZenkakuNum[toxy.x] + Koma.KanjiNum[toxy.y];
  }
};

/**
 * KIF形式で１手を出力
 *
 * @param {Number} fromxy 移動元の座標
 * @param {Number} toxy 移動先の座標
 * @param {Number} lastxy 直前の手の移動先の座標
 * @param {Number} nari 成ったかどうか
 *
 * @return {String} １手分の棋譜
 */
Koma.prototype.kifuKIF = function(fromxy, toxy, lastxy, nari) {
  fromxy.x++;
  fromxy.y++;

  var str = '';
  /* if (this.teban === Koma.SENTEBAN) {
   str = Koma.SenteStrKIF;
  } else if (this.teban === Koma.GOTEBAN) {
   str = Koma.GoteStrKIF;
  } */
  str += this.kifuDouNumKIF(toxy, lastxy);
  var komastr = this.strtypeKIF;
  if (this.nari === Koma.NARI) {
    if (nari === Koma.NARI) {
      komastr += Koma.NariStrKIF;
    } else {
      komastr = this.strntypeKIF;
    }
  } else if (fromx === 0) {
    komastr += Koma.UchiStrKIF;
  }
  str += komastr;
  if (fromxy.x !== 0) {
    str += '(' + fromxy.x + '' + fromxy.y + ')';
  }
  return str;
};

/**
 * 独自形式で１手を出力
 *
 * @param {Number} fromxy 移動元の座標
 * @param {Number} toxy   移動先の座標
 * @param {Number} lastxy 直前の手の移動先の座標
 * @param {Number} nari   成ったかどうか
 *
 * @return {String} １手分の棋譜
 */
Koma.prototype.kifuKIFU = function(fromxy, toxy, lastxy, nari) {
  fromxy.x++;
  fromxy.y++;

  var str = this.getTebanStr(Koma.SenteStrOrg, Koma.GoteStrOrg);

  str += this.kifuDouNumKIF(toxy, lastxy);

  var komastr = this.strtypeKIF;
  if (this.nari === Koma.NARI) {
    if (nari === Koma.NARI) {
      komastr += Koma.NariStrKIF;
    } else {
      komastr = this.strntypeKIF;
    }
  } else if (nari === Koma.NARERU) {
    komastr += Koma.FunariStr;
  } else if (fromxy.x === 0) {
    komastr += Koma.UchiStrKIF;
  }
  str += komastr;

  if (fromxy.x !== 0) {
    str += ' (' + fromxy.x + '' + fromxy.y + ')';
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

  var str = this.getTebanStr(Koma.SenteStrCSA, Koma.GoteStrCSA);

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

Koma.prototype.InitStr = function(abcd)
{
  this.strtype = abcd.long.narazu;
  this.strntype = abcd.long.nari;
  this.strtypeKIF = abcd.kif.narazu;
  this.strntypeKIF = abcd.kif.nari;
  this.strtypeKIFU = abcd.kifu.narazu;
  this.strntypeKIFU = abcd.kifu.nari;
  this.strtypeCSA = abcd.csa.narazu;
  this.strntypeCSA = abcd.csa.nari;
  this.strtypeIMG = abcd.img.narazu;
  this.strntypeIMG = abcd.img.nari;
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

  this.InitStr(Koma.InitStrTable.fu);
  this.InitMovable(Koma.FuMovable, Koma.KinMovable);
  this.id = Koma.FuID;
}

Fu.prototype.retpos = function (x, starty, endy) {
  var list = [];
  for (var y = starty; y < endy; ++y) {
    if (ban[x][y].koma.teban === Koma.AKI) {
      list.push([x, y]);
    }
  }
  return list;
};

/**
 * 打てるマスのリストを返す。(二歩対策)
 *
 * @override
 *
 * @return {Array} 打てるマスのリスト
 */
Fu.prototype.getUchable = function() {
  var ypostbl = [
    {},
    {start: 1, end: 9},
    {start: 0, end: 8},
  ];
  var ypos = ypostbl[this.teban];
  var starty = ypos.start;
  var endy = ypos.end;

  var list = [];
  for (var i = 0; i < 9; ++i) {
    if (this.check2FU(i, starty, endy)) {
      continue;
    }
    list = list.concat(this.retpos(i, starty, endy));
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

  this.InitStr(Koma.InitStrTable.kyosha);
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
  var ypostbl = [
    {},
    {start: 1, end: 9},
    {start: 0, end: 8},
  ];
  var ypos = ypostbl[this.teban];
  var starty = ypos.start;
  var endy = ypos.end;

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

  this.InitStr(Koma.InitStrTable.keima);
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
  var ypostbl = [
    {},
    {start: 2, end: 9},
    {start: 0, end: 7},
  ];
  var ypos = ypostbl[this.teban];
  var starty = ypos.start;
  var endy = ypos.end;

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

  this.InitStr(Koma.InitStrTable.gin);
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

  this.InitStr(Koma.InitStrTable.kin);
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

  this.InitStr(Koma.InitStrTable.kaku);
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

  this.InitStr(Koma.InitStrTable.hisha);
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

  this.InitStr(
    (teban === Koma.SENTEBAN) ? Koma.InitStrTable.gyoku : Koma.InitStrTable.ou);
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
