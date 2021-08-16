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
/* Koma.NATTA = 4; */

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

// -- KIF
Koma.NariStrKIF = '成';
Koma.UchiStrKIF = '打';
Koma.DouStrKIF = '同　';
Koma.FunariStr = '不成';


Koma.InitStrTable = {
  fu: {
    long: ['歩兵', 'と金'], kif: ['歩', 'と'],
    kifu: ['歩', 'と'], csa: ['FU', 'TO'],
    img: ['koma_fu', 'koma_to']
  },
  kyosha: {
    long: ['香車', '成香'], kif: ['香', '成香'],
    kifu: ['香', '成香'], csa: ['KY', 'NY'],
    img: ['koma_kyo', 'koma_nkyo']
  },
  keima: {
    long: ['桂馬', '成桂'], kif: ['桂', '成桂'],
    kifu: ['桂', '成桂'], csa: ['KE', 'NK'],
    img: ['koma_kei', 'koma_nkei']
  },
  gin: {
    long: ['銀将', '成銀'], kif: ['銀', '成銀'],
    kifu: ['銀', '成銀'], csa: ['GI', 'NG'],
    img: ['koma_gin', 'koma_ngin']
  },
  kin: {
    long: ['金将', '金将'], kif: ['金', '金'],
    kifu: ['金', '金'], csa: ['KI', 'KI'],
    img: ['koma_kin', 'koma_kin']
  },
  kaku: {
    long: ['角行', '竜馬'], kif: ['角', '馬'],
    kifu: ['角', '馬'], csa: ['KA', 'UM'],
    img: ['koma_kaku', 'koma_uma']
  },
  hisha: {
    long: ['飛車', '竜王'], kif: ['飛', '竜'],
    kifu: ['飛', '竜'], csa: ['HI', 'RY'],
    img: ['koma_hisha', 'koma_ryu']
  },
  gyoku: {
    long: ['玉将', '玉将'], kif: ['玉', '玉'],
    kifu: ['玉', '玉'], csa: ['OU', 'OU'],
    img: ['koma_ou', 'koma_ou']
  },
  ou: {
    long: ['王将', '王将'], kif: ['玉', '玉'],
    kifu: ['玉', '玉'], csa: ['OU', 'OU'],
    img: ['koma_ou', 'koma_ou']
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
  if (this.teban === Koma.SENTEBAN) return strSente;
  if (this.teban === Koma.GOTEBAN) return strGote;
  return null;
};

/**
 * 表示用の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getStr = function() {
  var str = this.getTebanStr(Koma.SenteStr, Koma.GoteStr);

  if (str == null) return Koma.AkiStr;

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

  if (str == null) return Koma.AkiStr;

  str += (this.nari === Koma.NARI) ? this.strntypeKIFU : this.strtypeKIFU;

  str += '</div>';
  return str;
};


Koma.prototype.chooseKomaExp = function(a, b) {
  return (this.nari === Koma.NARI) ? a : b;
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

  if (str == null) return '';

  str += this.chooseKomaExp(this.strntypeIMG, this.strtypeIMG);

  return str;
};

/**
 * CSA表示用の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getShortStrCSA = function() {
  var str = this.getTebanStr(Koma.SenteStrCSA, Koma.GoteStrCSA);

  if (str == null) return Koma.AkiStrCSA;

  str += this.chooseKomaExp(this.strntypeCSA, this.strtypeCSA);

  return str;
};

/**
 * CSA表示用の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getShortStrKIF = function() {
  var str = this.getTebanStr(Koma.SenteStrKIF, Koma.GoteStrKIF);

  if (str == null) return Koma.AkiStrKIF;

  str += this.chooseKomaExp(this.strntypeKIF, this.strtypeKIF);

  return str;
};

/**
 * 駒の種類の文字列の取得
 *
 * @return {String} 表示用の文字列
 */
Koma.prototype.getTypeStr = function() {
  return (this.nari === Koma.NARI) ? this.strntype : this.strtype;
};

/**
 * 動ける方向のリストを返す。
 *
 * @return {Array} 空のArray
 */
Koma.prototype.movable = function() {
  return (this.nari === Koma.NARI) ? this.nariMovable : this.funariMovable;
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

Koma.onTheBan = function (xory) {
  return 0 <= xory && xory < 9;
}

Koma.prototype.getStraightMovable = function (list, axy, ox, oy) {
  var x = ox;
  var y = oy;
  var ax = axy.x;
  var ay = axy.y;
  if (this.teban === Koma.SENTEBAN) ay = -ay;

  x += ax;
  y += ay;
  for ( ; Koma.onTheBan(x) && Koma.onTheBan(y) ; x += ax, y += ay) {
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
  if (!Koma.onTheBan(x)) return list;

  if (this.teban === Koma.SENTEBAN) {
    y = oy - axy.y;
  } else {
    y = oy + axy.y;
  }
  if (!Koma.onTheBan(y)) return list;

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
    list = straight ? this.getStraightMovable(list, axy, ox, oy)
          : this.getCloseMovable(list, axy, ox, oy);
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
};

/**
 * 打てるマスのリストを返す。
 *
 * @return {Array} 打てるマスのリスト
 */
Koma.prototype.getUchable = function(bann) {
  return this.getUchableGeneral(bann, 0, 9);
};

Koma.prototype.getUchableKEKY = function(bann, voidarea) {
  var starty = (this.teban === Koma.SENTEBAN) ? voidarea : 0;
  var endy = 9 - voidarea + starty;

  return this.getUchableGeneral(bann, starty, endy);
};

Koma.prototype.getUchableGeneralY = function(bann, i, starty, endy) {
  var list = [];
  for (var j = starty; j < endy; ++j) {
    if (bann[i][j].koma.teban === Koma.AKI)
      list.push([i, j]);
  }
  return list;
};

/**
 * 打てるマスのリストを返す。
 *
 * @param {Number} starty 打てる段の始まり
 * @param {Number} endyy  打てる段の終わり
 *
 * @return {Array} 打てるマスのリスト
 */
Koma.prototype.getUchableGeneral = function(bann, starty, endy) {
  var list = [];
  for (var i = 0; i < 9; ++i)
    list = list.concat(this.getUchableGeneralY(bann, i, starty, endy));
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

  str += ('' + fromx) + fromy + ('' + tox) + toy;
  str += this. pieceStr(this.strtypeCSA, this.strntypeCSA)

  return str;
};

Koma.prototype.pieceStr = function(hunaristr, naristr) {
  return (this.nari === Koma.NARI) ? naristr : hunaristr;
};

Koma.prototype.kifuDouNumKIF = function(toxy, lastxy) {
  if (toxy.x === lastxy.x && toxy.y === lastxy.y)
    return Koma.DouStrKIF;
  return Koma.ZenkakuNum[toxy.x] + Koma.KanjiNum[toxy.y];
};

Koma.prototype.strFromPos = function(fromxy)
{
  if (fromxy.x === 0) return '';
  return '(' + fromxy.x + '' + fromxy.y + ')';
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
  str += this.narifunariuchiStrKIF(nari, fromxy.x);
  str += this.strFromPos(fromxy);

  return str;
};

Koma.prototype.narifunariuchiStrKIF = function(nari, x) {
  var komastr = this.strtypeKIF;
  if (this.nari === Koma.NARI) {
    if (nari === Koma.NARI)
      return komastr + Koma.NariStrKIF;
    return this.strntypeKIF;
  } else if (x === 0) {
    return komastr + Koma.UchiStrKIF;
  }
  return komastr;
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
  str += this.narifunariuchiStrKIF(nari, fromxy.x);
  str += this.strFromPos(fromxy);

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

  str += ('' + x) + y;
  str += this.pieceStr(this.strtypeCSA, this.strntypeCSA)

  return str;
};

Koma.prototype.checkNariFromPos = function(ugokeru, fromy, toy) {
  if (fromy < 3 || toy < 3)
    return ugokeru ? Koma.NARERU : Koma.NARU;

  return Koma.NARENAI;
};

Koma.prototype.checkNariSente = function(fromy, toy) {
  // 動けるかのチェック
  var ugokeru = this.checkMovable(toy);
  return this.checkNariFromPos(ugokeru, fromy, toy)
};

Koma.prototype.checkNariGote = function(fromy, toy) {
  // 動けるかのチェック
  var _fromy = 9 - 1 - fromy;
  var _toy = 9 - 1 - toy;
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
  if (this.nari === Koma.NARI)
    return Koma.NARENAI;  /* return Koma.NATTA; */

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

  if (x < 0) return str + 'を' + toxy + 'に打ちます。';

  var y = this.y;
  var fromxy = Koma.ZenkakuNum[x] + Koma.KanjiNum[y];
  return str + 'を' + fromxy + 'から' + toxy + 'に移動します。';
};

/**
 * nari==Koma.NARIなら駒をひっくり返す。
 *
 * @param  {[type]} nari Koma.NARI or not
 */
Koma.prototype.kaesu = function (nari) {
  if (nari === Koma.NARI)
    this.nari = (this.nari === Koma.NARI) ?
      this.nari = Koma.NARAZU : this.nari = Koma.NARI;
};

Koma.prototype.InitStr = function(abcd)
{
  this.strtype = abcd.long[0];
  this.strntype = abcd.long[1];
  this.strtypeKIF = abcd.kif[0];
  this.strntypeKIF = abcd.kif[1];
  this.strtypeKIFU = abcd.kifu[0];
  this.strntypeKIFU = abcd.kifu[1];
  this.strtypeCSA = abcd.csa[0];
  this.strntypeCSA = abcd.csa[1];
  this.strtypeIMG = abcd.img[0];
  this.strntypeIMG = abcd.img[1];
};

/**
 * 動けるマスの情報の初期化
 * @param  {Array} funari 不成状態での動けるところ
 * @param  {Array} nari   成り状態での動けるところ
 */
Koma.prototype.InitMovable = function(funari, nari)
{
  this.funariMovable = funari;
  this.nariMovable = nari || Koma.KinMovable;
};

/* 駒汎用ここまで */

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
  this.InitMovable(Koma.FuMovable);
  this.id = Koma.FuID;
}

Fu.prototype.retpos = function (banx, x, starty, endy) {
  var list = [];
  for (var y = starty; y < endy; ++y) {
    if (banx[y].koma.teban === Koma.AKI)
      list.push([x, y]);
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
Fu.prototype.getUchable = function(ban) {
  var ypostbl = [{}, {start: 1, end: 9}, {start: 0, end: 8}];
  var ypos = ypostbl[this.teban];
  var starty = ypos.start;
  var endy = ypos.end;

  var list = [];
  for (var i = 0; i < 9; ++i) {
    if (this.check2FU(ban[i], starty, endy)) continue;

    list = list.concat(this.retpos(ban[i], i, starty, endy));
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
 * @param {Array} banx    チェックする筋
 * @param {Number} starty チェックする範囲
 * @param {Number} endy   チェックする範囲
 *
 * @return {Boolean} true:二歩になる, false:ならない
 */
Fu.prototype.check2FU = function(banx, starty, endy) {
  for (var j = starty; j < endy; ++j) {
    if (banx[j].koma.id === Koma.FuID &&
        banx[j].koma.nari === Koma.NARAZU &&
        banx[j].koma.teban === this.teban) {
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
  this.InitMovable(Koma.KyoshaMovable);
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
Kyosha.prototype.getUchable = function(bann) {
  return this.getUchableKEKY(bann, 1);
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
  this.InitMovable(Koma.KeimaMovable);
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
Keima.prototype.getUchable = function(bann) {
  return this.getUchableKEKY(bann, 2);
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
  this.InitMovable(Koma.GinMovable);
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
  this.InitMovable(Koma.KinMovable);
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
