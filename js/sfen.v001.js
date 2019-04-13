
var sfenkomabako = null;

// KING無しのSFEN用駒文字 先手
var komatblb = 'PLNSGBR';
// KING有りのSFEN用駒文字 先手
var komatblbk = 'PLNSGBRK';
// KING無しのSFEN用駒文字 後手
var komatblw = 'plnsgbr';

function sfenkoma_piece(sfk, ch, teban, ndan) {
  var nid = komatblbk.indexOf(ch);
  if (nid < 0) return null;

  var koma = sfenkomabako[nid].clone();

  koma.teban = teban;
  koma.x = sfk.nsuji;
  koma.y = ndan;

  if (sfk.nari !== 0) {
    koma.nari = Koma.NARI;
  }

  return koma;
}

var sfenkoma_analyzer = function(sfk, ch, ndan) {
  if (/[PLNSGBRKplnsgbrk]/.test(ch)) {
    var kind = ch.toUpperCase();
    var teban = (kind == ch) ? Koma.SENTEBAN : Koma.GOTEBAN;
    sfk.result.push(sfenkoma_piece(sfk, kind, teban, ndan));
    sfk.nari = 0;
    sfk.nsuji -= 1;
  } else if (ch === '+') {
    sfk.nari = 1;
  } else if (/[1-9]/.test(ch)) {
    var n_aki = +ch;
    sfk.nari = 0;
    for (var i = 0; i < n_aki; ++i)
      sfk.result.push(new Koma());
    sfk.nsuji -= n_aki;
  }
  return sfk;
};

var sfenkoma = function(dan, ndan) {
  // var result = [];
  var len = dan.length;
  // var nari = 0;
  // var nsuji = 8;
  var sfk = { nari: 0, nsuji: 8, result: [] };
  for (var j = 0; j < len; ++j) {
    var ch = dan.charAt(j);
    sfk = sfenkoma_analyzer(sfk, ch, ndan);
  }
  return sfk.result;
};

var sfentegoma = function(tegomastr) {
  /* tegoma[0]:先手, tegoma[0]:後手 */
  var tegoma = [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]];
  var num = 1;
  var len = tegomastr.length;
  var komatbl = komatblb+komatblw;
  for (var j = 0; j < len; ++j) {
    var ch = tegomastr.charAt(j);
    var idx = komatbl.indexOf(ch);
    if (idx >= 7) {
      tegoma[1][idx-7] = num;
      num = 1;
    } else if (idx >= 0) {
      tegoma[0][idx] = num;
      num = 1;
    } else if (/[1-9]/.test(ch)) {  // 1~9
      num = +ch;
    } else {
      // error
    }
  }
  return tegoma;
};

/**
 * 手駒にオブジェクトを入れる
 * @param {Array} ntegoma  手駒の数が入った配列
 * @param {[type]} tegoma  手駒オブジェクト
 * @param {[type]} teban   先手か後手か
 */
function sfentegoma_add(ntegoma, tegoma, teban) {
  for (var idx = 0 ; idx < 7 ; ++idx) {
    var num = ntegoma[idx];
    for (var k = 0; k < num; ++k) {
      var koma = sfenkomabako[idx].clone();
      koma.teban = teban;
      koma.x = -1;
      koma.y = -1;
      komadai_add(tegoma, koma);
    }
  }
}

/**
 *
 * @param {String} sfentext sfen文字列
 */
function fromsfen(sfentext) {
  // var sfenarea = document.getElementById('sfen');
  initKomaEx();

  var t = Koma.SENTEBAN;
  sfenkomabako = [new Fu(t, 0, 0), new Kyosha(t, 0, 0),
    new Keima(t, 0, 0), new Gin(t, 0, 0), new Kin(t, 0, 0),
    new Kaku(t, 0, 0), new Hisha(t, 0, 0), new Gyoku(t, 0, 0)];

  var sfenitem = sfentext.split(' ');
  // var sz = sfenitem.length;
  // for (var i = 1; i < sz; ++i) {
  //  console.log(sfenitem[i]);
  // }
  var bandan = sfenitem[0].split('/');
  // sz = bandan.length;
  // for (var i = 0; i < sz; ++i) {
  //  console.log(bandan[i]);
  // }

  var sz = bandan.length;
  for (var i = 0; i < sz; ++i) {
    var dankoma = sfenkoma(bandan[i], i);
    for (var j = 0; j < 9; ++j) {
      ban[8 - j][i].koma = dankoma[j];
    }
  }

  // 手駒
  var tegoma = sfentegoma(sfenitem[2]);
  sfentegoma_add(tegoma[0], sentegoma, Koma.SENTEBAN);
  sfentegoma_add(tegoma[1], gotegoma, Koma.GOTEBAN);

  if (sfenitem[1] === 'b') {
    activeteban = Koma.SENTEBAN;
  } else if (sfenitem[1] === 'w') {
    activeteban = Koma.GOTEBAN;
    // } else {
    // keep current teban
  }

  mykifu.NTeme = sfenitem[3] | 0;
}

function SFENGenBanText() {
  this.dantext = '';
  this.aki = 0;
}

SFENGenBanText.prototype.flushaki = function() {
  if (this.aki > 0) {
    this.dantext += this.aki;
    this.aki = 0;
  }
}

SFENGenBanText.prototype.analyze = function(koma) {
  var komach = '';

  if (koma.id < Koma.FuID) {
    this.aki += 1;
    return;
  }

  if (koma.nari === Koma.NARI) {
    komach = '+';
  }

  komach += komatblbk.charAt(koma.id);

  if (koma.teban === Koma.GOTEBAN) {
    komach = komach.toLowerCase();
  }

  this.flushaki();

  this.dantext += komach;
};

var sfen_genbantext_dan = function(shogiban, ndan) {
  var sgbt = new SFENGenBanText();

  for (var j = 0; j < 9; ++j) {
    var koma = shogiban[8-j][ndan].koma;
    sgbt.analyze(koma)
  }

  sgbt.flushaki();

  return sgbt.dantext;
};

var sfen_genbantext = function(shogiban) {
  var shogibantext = [];
  for (var i = 0; i < 9; ++i) {
    shogibantext[i] = sfen_genbantext_dan(shogiban, i);
  }
  return shogibantext;
};

function sfen_gentegomatext(komadai, komatbl) {
  var sfentegomatext = '';

  for (var i = 7; i ; ) {
    --i;
    var num = komadai[i][0].length;
    if (num >= 2) {
      sfentegomatext += num;
    }
    if (num > 0) {
      sfentegomatext += komatbl.charAt(i);
    }
  }

  return sfentegomatext;
}

var sfen_gentegomatext_sengo = function(sentekomadai, gotekomadai) {
  var sfentegomatext = sfen_gentegomatext(sentekomadai, komatblb);

  sfentegomatext += sfen_gentegomatext(gotekomadai, komatblw);

  if (sfentegomatext.length === 0) {
    sfentegomatext = '-';
  }
  return sfentegomatext;
};

/**
 * @param {String} nth 何手目
 */
function gensfen(nth /* = '1' */) {
  // 盤
  var bantext = sfen_genbantext(ban);

  // 手駒
  var tegomatext = sfen_gentegomatext_sengo(sentegoma, gotegoma);

  // いろいろ合体
  var sfentext = '';
  sfentext = bantext.join('/');
  // for (i = 0 ; i < bantext.length-1 ; ++i) {
  //  sfentext += bantext[i] + '/';
  // }
  // sfentext += bantext[i];
  sfentext += ' ';
  if (activeteban !== Koma.SENTEBAN) {
    sfentext += 'w';
  } else {
    sfentext += 'b';
  }
  sfentext += ' ';
  sfentext += tegomatext;
  sfentext += ' ';
  sfentext += nth;  // 何手目
  return sfentext;
}
