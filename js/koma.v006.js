/* 汎用駒クラスKomaを使った具体的な駒クラス */

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
