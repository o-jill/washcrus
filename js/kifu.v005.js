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
  /**
   * 直前の手の情報
   * str: 直前の手の棋譜
   * strs: 直前の手の棋譜 短め
   * x:,y: 直前の手の座標
   */
  this.lastTe = { str: '', strs: '', x: 10, y: 10 };
  /** 今何手目か */
  this.NTeme = 0;
  /** 直前に取った駒のID */
  this.totta_id = Koma.NoID;
  /** 対局中(又は直近)の棋譜 */
  this.Honp = []; // 一手分の棋譜 [手番, fromx, fromy, tox, toy, nari, totta_id];

  /** 先手の名前 後手の名前 */
  this.name = {sen: '', go: ''};
  /** 棋戦名 */
  this.eventname = '';
  /** 場所 */
  this.sitename = '';
  /** 開始時間 終了時間 */
  this.time = {start: '', end: ''};
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
 * @param {Number} fromxy 移動元の座標
 * @param {Number} toxy   移動先の座標
 * @param {Number} nari  成ったかどうか
 */
Kifu.prototype.Sashita = function(teban, fromxy, toxy, nari) {
  this.Honp.push([teban, fromxy.x, fromxy.y, toxy.x, toxy.y, nari]);
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
 * @param {Number} fromxy 移動元
 * @param {Number} toxy   移動先
 * @param {Number} nari   成ったかどうか
 *
 * @return {String} １手分の棋譜
 */
Kifu.prototype.genKifu = function(koma, fromxy, toxy, nari) {
  this.NTeme++;
  if (this.mode === Kifu.CSA) {
    this.lastTe.str = koma.kifuCSA(fromxy.x, fromxy.y, toxy.x, toxy.y);
  } else if (this.mode === Kifu.KIF) {
    this.lastTe.str = this.toStringPadding(this.NTeme, 4, ' ') + ' ';
    this.lastTe.strs =
      koma.kifuKIF(fromxy, toxy, {x: this.lastTe.x, y: this.lastTe.y}, nari);
    this.lastTe.str += this.lastTe.strs;
    this.lastTe.str += '   ( 0:00/00:00:00)';
  } else if (this.mode === Kifu.Org) {
    this.lastTe.str = this.toStringPadding(this.NTeme, 4, ' ') + ' ';
    this.lastTe.strs =
      koma.kifuKIFU(fromxy, toxy, {x: this.lastTe.x, y: this.lastTe.y}, nari);
    this.lastTe.str += this.lastTe.strs;
  } else {
    /* console.log('invalid mode@Kifu class!!(' + this.mode + ')'); */
  }
  this.kifuText += this.lastTe.str + '\n';
  this.lastTe.x = toxy.x;
  this.lastTe.y = toxy.y;

  // 一手分の棋譜を記憶 [手番, fromxy, toxy, nari, id];
  this.Sashita(koma.teban, fromxy, toxy, nari, this.totta_id);
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
  this.lastTe = { str: '', strs: '', x: 10, y: 10 };
  this.NTeme = 0;
  this.Honp = [];
  this.name = {sen: '', go: ''};
  this.eventname = this.sitename = '';
  this.time = {start: '', end: ''};
  this.timelimit = this.opening = '';
};

/**
 * 対局者の名前をセットする。
 *
 * @param {String} sentename 先手の名前
 * @param {String} gotename  後手の名前
 */
Kifu.prototype.setPlayers = function(sentename, gotename) {
  this.name = {sen: sentename, go: gotename};
};

/**
 * 棋譜ヘッダの出力。
 *
 * @param {String} sentename 先手の名前
 * @param {String} gotename  後手の名前
 */
Kifu.prototype.putHeader = function(sentename, gotename) {
  sentename = sentename || this.name.sen;
  gotename = gotename || this.name.go;
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
 * @return {String} 時刻文字列 'yyyy/mm/dd hh:mm:ss'
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
            'V2.2\n' + 'N+' + sentename + '\nN-' + gotename + '\n' +
            // $EVENT:レーティング対局室
            '$START_TIME:' + time /* 2014/04/01 12:25:21 */ + '\n' + 'PI\n+\n';
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
  if (winte === Koma.SENTEBAN) return str + '先手の勝ち';
  return str + '後手の勝ち';
};

/**
 * 独自棋譜フッタの出力。
 *
 * @param {Object} winte 勝った方の手番
 *
 * @return {String} 棋譜フッタ文字列
 */
Kifu.prototype.footerOrg = function(winte) {
  return this.footerKIF(winte);
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

Kifu.prototype.readLineCSA_dollar = function(text) {
  if (text.startsWith('$EVENT:')) return this.eventname = text.slice(7);
  /* 場所 */
  if (text.startsWith('$SITE:')) return this.sitename = text.slice(6);
  // 開始時間
  if (text.startsWith('$START_TIME:')) return this.time.start = text.slice(12);
  // 終了時間
  if (text.startsWith('$END_TIME:')) return this.time.end = text.slice(10);
  // 持ち時間
  if (text.startsWith('$TIME_LIMIT:')) return this.timelimit = text.slice(12);
  // 戦型
  if (text.startsWith('$OPENING:')) return this.opening = text.slice(9);
};

Kifu.prototype.readLineCSA_name = function(text) {
  if (text.startsWith('N+')) return this.name.sen = text.slice(2);
  this.name.go = text.slice(2);
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
    if (letters[0] === '-') teban = Koma.GOTEBAN;

    // 一手分の棋譜 [手番, fromx, fromy, tox, toy, nari, totta_id];
    this.Honp.push([teban, fromx, fromy, tox, toy, nari, totta_id]);
  } else if (/^N[+-]/.test(text)) {
    this.readLineCSA_name(text)
  } else if (text.startsWith('$')) {
    this.readLineCSA_dollar(text);
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
 * ファイルの読み込み
 *
 * @param {String} path ファイルのパス
 * @param {Number} type ファイルの形式(Kifu.CSA, Kifu.KIF, Kifu.Org)
 */
Kifu.prototype.receive = function(path, type) {
  var ajax = new XMLHttpRequest();
  if (ajax === null) return;

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
};

Kifu.prototype.evalKomazon_koma = function(komazon, kid, teban, nari)
{
  if (teban === Koma.SENTEBAN) {
    if (nari === Koma.NARI) kid += 8
    komazon[kid]++;
  } else if (teban === Koma.GOTEBAN) {
    if (nari === Koma.NARI) kid += 8
    komazon[kid]--;
  }
  return komazon;
}

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

Kifu.prototype.seek_te_foward_move = function(te) {
  var xy = {x: te[3], y: te[4]};
  if (te[1] === -1) {
    // 駒を打つ
    uchi2((te[0] === Koma.SENTEBAN) ? sentegoma : gotegoma, te[6], xy);
  } else {
    if (te[6] > Koma.NoID) {
      toru(xy);
      this.totta_id = Koma.NoID;
    }
    var masu = ban[te[1]][te[2]];
    move2(masu, xy, te[5]);  // 動かした駒を戻す
  }
}

Kifu.prototype.seek_te_foward = function(idx) {
  while (this.NTeme < idx) {
    var te = this.Honp[this.NTeme];
    // [teban, fromx, fromy, tox, toy, nari, totta_id];
    this.seek_te_foward_move(te);
    this.NTeme++;
  }
}

Kifu.prototype.seek_te_backward_ = function(te) {
  var teban, fx, fy, tx, ty, nari, tid = te;
  var fromxy = { x: fx, y: fy }, toxy = { x: tx, y: ty };

  if (fx === -1) {
    // 駒台に戻す
    toru(toxy);
    return this.totta_id = Koma.NoID;
  }

  var masu = ban[tx][ty];
  move2(masu, fromxy, nari);  // 動かした駒を戻す

  if (tid >= 0) {
    var tegoma = (teban === Koma.SENTEBAN) ? sentegoma : gotegoma;
    torimodosu(tegoma, tid, tx, ty);
  }
}

Kifu.prototype.seek_te_backward = function(idx) {
  while (this.NTeme > idx) {
    this.NTeme--;
    var te = this.Honp[this.NTeme];
    // [teban, fromx, fromy, tox, toy, nari, totta_id];
    this.seek_te_backward_(te);
  }
}

/**
 * idx手目にする
 *
 * @param {Number} idx 何手目か
 *
 * @return {Boolean} 本譜より大きい値を指定した時はfalse。
 */
Kifu.prototype.seek_te = function(idx) {
  if (idx < 0 || idx > this.Honp.length) return false;

  // var te, masu, tegoma;
  if (this.NTeme < idx) this.seek_te_foward(idx);
  else this.seek_te_backward(idx);

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

function build_movecsa(koma, fromxy, toxy, tottaid, nari) {
  var str = koma.getTebanStrUtil(Koma.UtilStr.csa);

  str += ('' + (fromxy.x + 1)) + (fromxy.y + 1);

  str += ('' + (toxy.x + 1)) + (toxy.y + 1);

  str += (nari === Koma.NARI || koma.nari !== Koma.NARI)
    ? koma.strtype.csa[0] : str += koma.strtype.csa[1];

  if (tottaid === Koma.NoID) str += '__';
  else if (tottaid >= 1000) str += tottakoma.strtype.csa[1];
  else str += tottakoma.strtype.csa[0];

  if (nari === Koma.NARI) str += 'P';

  return str;
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

function KyokumenCSATegoma(tegoma) {
  var kyokumen = '';
  for (var elem of tegoma) {
    if (elem[0].length === 0) continue;

    kyokumen += 'P' + elem[1].koma.kifuShortCSA(-1, -1) + '\n';
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

  kyokumen += (activeteban === Koma.SENTEBAN) ? '+' : '-';

  return kyokumen;
}

function KyokumenKIFTegoma(tegoma) {
  var komadai = '';
  for (var elem of gotegoma) {
    if (elem[0].length === 0) continue;

    komadai += elem[1].koma.strtype.kif[0]
      + Koma.KanjiNum[elem[0].length - 1] + '　';
  }
  if (komadai === '') komadai = 'なし';

  return komadai;
}

/**
 * 局面の出力KIF
 *
 * @return {String} 局面のデータ文字列
 */
function KyokumenKIF() {
  var kyokumen = '後手の持駒：';

  var komadai =
  kyokumen += KyokumenKIFTegoma(gotegoma);

  kyokumen += '\n  ９ ８ ７ ６ ５ ４ ３ ２ １\n+---------------------------+\n';
  for (var i = 0; i < 9; ++i) {
    kyokumen += '|';
    for (var j = 8; j >= 0; --j) {
      var koma = ban[j][i].koma;
      kyokumen += koma.getShortStrKIF();
    }
    kyokumen += '|' + Koma.KanjiNum[i] + '\n';
  }
  kyokumen += '+---------------------------+\n先手の持駒：';

  kyokumen += KyokumenKIFTegoma(sentegoma);

  kyokumen += '\n手数＝' + mykifu.NTeme + ' ' + mykifu.lastTe.strs + 'まで\n';

  return kyokumen;
}
