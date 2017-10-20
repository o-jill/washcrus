/** 将棋盤の色(画像の時はtransparentにする) */
var banColor = 'transparent';
//var banColor = '#FDA';
/** マス目にカーソルが乗った時の色 */
var hoverColor = 'yellow';
/** 選択中のマス目の色 */
var activeColor = 'green';
/** 選択中の駒が指せるマス目の色 */
var movableColor = 'pink';

//var testKoma = new Fu(Koma.SENTEBAN);
//var testKoma = new Kaku(Koma.SENTEBAN);
var testKoma = new Koma();

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
//var kifuArea;
/** 棋譜形式選択欄 */
//var kifuType;
/** 解析結果出力欄 */
//var analysisArea;
/** 先手の名前 */
var nameSente;
/** 後手の名前 */
var nameGote;


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

var elem_id = document.getElementById('gameid');
var id = elem_id.value;

/** 最終手 筋 */
var last_mx = -1;
/** 最終手 段 */
var last_my = -1;

function update_banindex() {
  var column = document.getElementById('bancolumn');
  var text = '';
  var numbersc = ['９', '８', '７', '６', '５', '４', '３', '２', '１'];
  /*var numbersc = testKoma.ZenkakuNum;
  numbersc.reverse();*/
  numbersc.forEach(function(c) {
    text += '<th width=45>' + c + '</th>';
  });
  column.innerHTML = text + '<th>&nbsp;</th>';

  /* var numbersr = ['一', '二', '三', '四', '五', '六', '七', '八', '九'];*/
  var numbersr = testKoma.KanjiNum;
  var row = document.getElementById('banrow1');
  row.innerHTML = numbersr[0];
  row = document.getElementById('banrow2');
  row.innerHTML = numbersr[1];
  row = document.getElementById('banrow3');
  row.innerHTML = numbersr[2];
  row = document.getElementById('banrow4');
  row.innerHTML = numbersr[3];
  row = document.getElementById('banrow5');
  row.innerHTML = numbersr[4];
  row = document.getElementById('banrow6');
  row.innerHTML = numbersr[5];
  row = document.getElementById('banrow7');
  row.innerHTML = numbersr[6];
  row = document.getElementById('banrow8');
  row.innerHTML = numbersr[7];
  row = document.getElementById('banrow9');
  row.innerHTML = numbersr[8];
}

function update_banindex_rotate() {
  var column = document.getElementById('bancolumn');
  /*var numbersc = ['１', '２', '３', '４', '５', '６', '７', '８', '９'];*/
  var numbersc = testKoma.ZenkakuNum;
  var text = '';
  numbersc.forEach(function(c) {
    text += '<th width=45>' + c + '</th>';
  });
  column.innerHTML = text + '<th>&nbsp;</th>';

  var numbersr = ['九', '八', '七', '六', '五', '四', '三', '二', '一'];
  /*var numbersr = testKoma.KanjiNum;
  numbersr.reverse();*/
  var row = document.getElementById('banrow1');
  row.innerHTML = numbersr[0];
  row = document.getElementById('banrow2');
  row.innerHTML = numbersr[1];
  row = document.getElementById('banrow3');
  row.innerHTML = numbersr[2];
  row = document.getElementById('banrow4');
  row.innerHTML = numbersr[3];
  row = document.getElementById('banrow5');
  row.innerHTML = numbersr[4];
  row = document.getElementById('banrow6');
  row.innerHTML = numbersr[5];
  row = document.getElementById('banrow7');
  row.innerHTML = numbersr[6];
  row = document.getElementById('banrow8');
  row.innerHTML = numbersr[7];
  row = document.getElementById('banrow9');
  row.innerHTML = numbersr[8];
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
 * コマを並べる。
 */
function Naraberu() {
 for (var i = 0; i < 9; ++i) {
  for (var j = 0; j < 9; ++j) {
   var koma = ban[i][j].koma;
   var el = ban[i][j].el;
   if (koma !== null) {
     var fn = koma.getImgStr(0);
     if (fn.length === 0) {
       el.innerHTML = '<BR>';
     } else {
       var komaimg = '<img width="48px" height="48px" src="./image/'+ fn +'.png">';
       if (i === last_mx && j === last_my) {
         // 最後に指したところに印をつける
         var text = '<div style="position:relative;">' + komaimg;
         text += '<div style="position:absolute;left:0;top:0;">';
         text += '<img src="./image/dot16.png"></div></div>';
         el.innerHTML = text;
       } else {
         el.innerHTML = komaimg;
       }
     }
    // el.innerHTML = koma.getHtmlStr(0);
   }
  }
 }
 Naraberu_tegoma(sentegoma, sentegoma);
 Naraberu_tegoma(gotegoma, gotegoma);
}

/**
 * 逆さまにコマを並べる。
 */
function Naraberu_rotate() {
 for (var i = 0; i < 9; ++i) {
  for (var j = 0; j < 9; ++j) {
   var koma = ban[8 - i][8 - j].koma;
   var el = ban[i][j].el;
   if (koma !== null) {
    var fn = koma.getImgStr(1);
    if (fn.length === 0) {
      el.innerHTML = '<BR>';
    } else {
      var komaimg = '<img width="48px" height="48px" src="./image/'+ fn +'.png">';
      if (8-i === last_mx && 8-j === last_my) {
        // 最後に指したところに印をつける
        var text = '<div style="position:relative;">' + komaimg;
        text += '<div style="position:absolute;left:0;top:0;">';
        text += '<img src="./image/dot16.png"></div></div>';
        el.innerHTML = text;
      } else {
        el.innerHTML = komaimg;
      }
    }
    // el.innerHTML = koma.getHtmlStr(1);
   }
  }
 }
 Naraberu_tegoma(sentegoma, gotegoma);
 Naraberu_tegoma(gotegoma, sentegoma);
}

/**
 * 画面の更新
 */
function update_screen() {
 if (hifumin_eye) {
  update_banindex_rotate();
  Naraberu_rotate();
 } else {
  update_banindex();
  Naraberu();
 }
 //kifuArea.innerText = mykifu.kifuText;
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
  ban[0][0].el = document.getElementById('b11');
  ban[0][1].el = document.getElementById('b12');
  ban[0][2].el = document.getElementById('b13');
  ban[0][3].el = document.getElementById('b14');
  ban[0][4].el = document.getElementById('b15');
  ban[0][5].el = document.getElementById('b16');
  ban[0][6].el = document.getElementById('b17');
  ban[0][7].el = document.getElementById('b18');
  ban[0][8].el = document.getElementById('b19');
  ban[1][0].el = document.getElementById('b21');
  ban[1][1].el = document.getElementById('b22');
  ban[1][2].el = document.getElementById('b23');
  ban[1][3].el = document.getElementById('b24');
  ban[1][4].el = document.getElementById('b25');
  ban[1][5].el = document.getElementById('b26');
  ban[1][6].el = document.getElementById('b27');
  ban[1][7].el = document.getElementById('b28');
  ban[1][8].el = document.getElementById('b29');
  ban[2][0].el = document.getElementById('b31');
  ban[2][1].el = document.getElementById('b32');
  ban[2][2].el = document.getElementById('b33');
  ban[2][3].el = document.getElementById('b34');
  ban[2][4].el = document.getElementById('b35');
  ban[2][5].el = document.getElementById('b36');
  ban[2][6].el = document.getElementById('b37');
  ban[2][7].el = document.getElementById('b38');
  ban[2][8].el = document.getElementById('b39');
  ban[3][0].el = document.getElementById('b41');
  ban[3][1].el = document.getElementById('b42');
  ban[3][2].el = document.getElementById('b43');
  ban[3][3].el = document.getElementById('b44');
  ban[3][4].el = document.getElementById('b45');
  ban[3][5].el = document.getElementById('b46');
  ban[3][6].el = document.getElementById('b47');
  ban[3][7].el = document.getElementById('b48');
  ban[3][8].el = document.getElementById('b49');
  ban[4][0].el = document.getElementById('b51');
  ban[4][1].el = document.getElementById('b52');
  ban[4][2].el = document.getElementById('b53');
  ban[4][3].el = document.getElementById('b54');
  ban[4][4].el = document.getElementById('b55');
  ban[4][5].el = document.getElementById('b56');
  ban[4][6].el = document.getElementById('b57');
  ban[4][7].el = document.getElementById('b58');
  ban[4][8].el = document.getElementById('b59');
  ban[5][0].el = document.getElementById('b61');
  ban[5][1].el = document.getElementById('b62');
  ban[5][2].el = document.getElementById('b63');
  ban[5][3].el = document.getElementById('b64');
  ban[5][4].el = document.getElementById('b65');
  ban[5][5].el = document.getElementById('b66');
  ban[5][6].el = document.getElementById('b67');
  ban[5][7].el = document.getElementById('b68');
  ban[5][8].el = document.getElementById('b69');
  ban[6][0].el = document.getElementById('b71');
  ban[6][1].el = document.getElementById('b72');
  ban[6][2].el = document.getElementById('b73');
  ban[6][3].el = document.getElementById('b74');
  ban[6][4].el = document.getElementById('b75');
  ban[6][5].el = document.getElementById('b76');
  ban[6][6].el = document.getElementById('b77');
  ban[6][7].el = document.getElementById('b78');
  ban[6][8].el = document.getElementById('b79');
  ban[7][0].el = document.getElementById('b81');
  ban[7][1].el = document.getElementById('b82');
  ban[7][2].el = document.getElementById('b83');
  ban[7][3].el = document.getElementById('b84');
  ban[7][4].el = document.getElementById('b85');
  ban[7][5].el = document.getElementById('b86');
  ban[7][6].el = document.getElementById('b87');
  ban[7][7].el = document.getElementById('b88');
  ban[7][8].el = document.getElementById('b89');
  ban[8][0].el = document.getElementById('b91');
  ban[8][1].el = document.getElementById('b92');
  ban[8][2].el = document.getElementById('b93');
  ban[8][3].el = document.getElementById('b94');
  ban[8][4].el = document.getElementById('b95');
  ban[8][5].el = document.getElementById('b96');
  ban[8][6].el = document.getElementById('b97');
  ban[8][7].el = document.getElementById('b98');
  ban[8][8].el = document.getElementById('b99');

  ban[0][0].el.onclick = click11; ban[0][1].el.onclick = click12;
  ban[0][2].el.onclick = click13; ban[0][3].el.onclick = click14;
  ban[0][4].el.onclick = click15; ban[0][5].el.onclick = click16;
  ban[0][6].el.onclick = click17; ban[0][7].el.onclick = click18;
  ban[0][8].el.onclick = click19;
  ban[1][0].el.onclick = click21; ban[1][1].el.onclick = click22;
  ban[1][2].el.onclick = click23; ban[1][3].el.onclick = click24;
  ban[1][4].el.onclick = click25; ban[1][5].el.onclick = click26;
  ban[1][6].el.onclick = click27; ban[1][7].el.onclick = click28;
  ban[1][8].el.onclick = click29;
  ban[2][0].el.onclick = click31; ban[2][1].el.onclick = click32;
  ban[2][2].el.onclick = click33; ban[2][3].el.onclick = click34;
  ban[2][4].el.onclick = click35; ban[2][5].el.onclick = click36;
  ban[2][6].el.onclick = click37; ban[2][7].el.onclick = click38;
  ban[2][8].el.onclick = click39;
  ban[3][0].el.onclick = click41; ban[3][1].el.onclick = click42;
  ban[3][2].el.onclick = click43; ban[3][3].el.onclick = click44;
  ban[3][4].el.onclick = click45; ban[3][5].el.onclick = click46;
  ban[3][6].el.onclick = click47; ban[3][7].el.onclick = click48;
  ban[3][8].el.onclick = click49;
  ban[4][0].el.onclick = click51; ban[4][1].el.onclick = click52;
  ban[4][2].el.onclick = click53; ban[4][3].el.onclick = click54;
  ban[4][4].el.onclick = click55; ban[4][5].el.onclick = click56;
  ban[4][6].el.onclick = click57; ban[4][7].el.onclick = click58;
  ban[4][8].el.onclick = click59;
  ban[5][0].el.onclick = click61; ban[5][1].el.onclick = click62;
  ban[5][2].el.onclick = click63; ban[5][3].el.onclick = click64;
  ban[5][4].el.onclick = click65; ban[5][5].el.onclick = click66;
  ban[5][6].el.onclick = click67; ban[5][7].el.onclick = click68;
  ban[5][8].el.onclick = click69;
  ban[6][0].el.onclick = click71; ban[6][1].el.onclick = click72;
  ban[6][2].el.onclick = click73; ban[6][3].el.onclick = click74;
  ban[6][4].el.onclick = click75; ban[6][5].el.onclick = click76;
  ban[6][6].el.onclick = click77; ban[6][7].el.onclick = click78;
  ban[6][8].el.onclick = click79;
  ban[7][0].el.onclick = click81; ban[7][1].el.onclick = click82;
  ban[7][2].el.onclick = click83; ban[7][3].el.onclick = click84;
  ban[7][4].el.onclick = click85; ban[7][5].el.onclick = click86;
  ban[7][6].el.onclick = click87; ban[7][7].el.onclick = click88;
  ban[7][8].el.onclick = click89;
  ban[8][0].el.onclick = click91; ban[8][1].el.onclick = click92;
  ban[8][2].el.onclick = click93; ban[8][3].el.onclick = click94;
  ban[8][4].el.onclick = click95; ban[8][5].el.onclick = click96;
  ban[8][6].el.onclick = click97; ban[8][7].el.onclick = click98;
  ban[8][8].el.onclick = click99;

  ban[0][0].el.onmouseover = hoverin11; ban[0][1].el.onmouseover = hoverin12;
  ban[0][2].el.onmouseover = hoverin13; ban[0][3].el.onmouseover = hoverin14;
  ban[0][4].el.onmouseover = hoverin15; ban[0][5].el.onmouseover = hoverin16;
  ban[0][6].el.onmouseover = hoverin17; ban[0][7].el.onmouseover = hoverin18;
  ban[0][8].el.onmouseover = hoverin19;
  ban[1][0].el.onmouseover = hoverin21; ban[1][1].el.onmouseover = hoverin22;
  ban[1][2].el.onmouseover = hoverin23; ban[1][3].el.onmouseover = hoverin24;
  ban[1][4].el.onmouseover = hoverin25; ban[1][5].el.onmouseover = hoverin26;
  ban[1][6].el.onmouseover = hoverin27; ban[1][7].el.onmouseover = hoverin28;
  ban[1][8].el.onmouseover = hoverin29;
  ban[2][0].el.onmouseover = hoverin31; ban[2][1].el.onmouseover = hoverin32;
  ban[2][2].el.onmouseover = hoverin33; ban[2][3].el.onmouseover = hoverin34;
  ban[2][4].el.onmouseover = hoverin35; ban[2][5].el.onmouseover = hoverin36;
  ban[2][6].el.onmouseover = hoverin37; ban[2][7].el.onmouseover = hoverin38;
  ban[2][8].el.onmouseover = hoverin39;
  ban[3][0].el.onmouseover = hoverin41; ban[3][1].el.onmouseover = hoverin42;
  ban[3][2].el.onmouseover = hoverin43; ban[3][3].el.onmouseover = hoverin44;
  ban[3][4].el.onmouseover = hoverin45; ban[3][5].el.onmouseover = hoverin46;
  ban[3][6].el.onmouseover = hoverin47; ban[3][7].el.onmouseover = hoverin48;
  ban[3][8].el.onmouseover = hoverin49;
  ban[4][0].el.onmouseover = hoverin51; ban[4][1].el.onmouseover = hoverin52;
  ban[4][2].el.onmouseover = hoverin53; ban[4][3].el.onmouseover = hoverin54;
  ban[4][4].el.onmouseover = hoverin55; ban[4][5].el.onmouseover = hoverin56;
  ban[4][6].el.onmouseover = hoverin57; ban[4][7].el.onmouseover = hoverin58;
  ban[4][8].el.onmouseover = hoverin59;
  ban[5][0].el.onmouseover = hoverin61; ban[5][1].el.onmouseover = hoverin62;
  ban[5][2].el.onmouseover = hoverin63; ban[5][3].el.onmouseover = hoverin64;
  ban[5][4].el.onmouseover = hoverin65; ban[5][5].el.onmouseover = hoverin66;
  ban[5][6].el.onmouseover = hoverin67; ban[5][7].el.onmouseover = hoverin68;
  ban[5][8].el.onmouseover = hoverin69;
  ban[6][0].el.onmouseover = hoverin71; ban[6][1].el.onmouseover = hoverin72;
  ban[6][2].el.onmouseover = hoverin73; ban[6][3].el.onmouseover = hoverin74;
  ban[6][4].el.onmouseover = hoverin75; ban[6][5].el.onmouseover = hoverin76;
  ban[6][6].el.onmouseover = hoverin77; ban[6][7].el.onmouseover = hoverin78;
  ban[6][8].el.onmouseover = hoverin79;
  ban[7][0].el.onmouseover = hoverin81; ban[7][1].el.onmouseover = hoverin82;
  ban[7][2].el.onmouseover = hoverin83; ban[7][3].el.onmouseover = hoverin84;
  ban[7][4].el.onmouseover = hoverin85; ban[7][5].el.onmouseover = hoverin86;
  ban[7][6].el.onmouseover = hoverin87; ban[7][7].el.onmouseover = hoverin88;
  ban[7][8].el.onmouseover = hoverin89;
  ban[8][0].el.onmouseover = hoverin91; ban[8][1].el.onmouseover = hoverin92;
  ban[8][2].el.onmouseover = hoverin93; ban[8][3].el.onmouseover = hoverin94;
  ban[8][4].el.onmouseover = hoverin95; ban[8][5].el.onmouseover = hoverin96;
  ban[8][6].el.onmouseover = hoverin97; ban[8][7].el.onmouseover = hoverin98;
  ban[8][8].el.onmouseover = hoverin99;

  ban[0][0].el.onmouseout = hoverout11; ban[0][1].el.onmouseout = hoverout12;
  ban[0][2].el.onmouseout = hoverout13; ban[0][3].el.onmouseout = hoverout14;
  ban[0][4].el.onmouseout = hoverout15; ban[0][5].el.onmouseout = hoverout16;
  ban[0][6].el.onmouseout = hoverout17; ban[0][7].el.onmouseout = hoverout18;
  ban[0][8].el.onmouseout = hoverout19;
  ban[1][0].el.onmouseout = hoverout21; ban[1][1].el.onmouseout = hoverout22;
  ban[1][2].el.onmouseout = hoverout23; ban[1][3].el.onmouseout = hoverout24;
  ban[1][4].el.onmouseout = hoverout25; ban[1][5].el.onmouseout = hoverout26;
  ban[1][6].el.onmouseout = hoverout27; ban[1][7].el.onmouseout = hoverout28;
  ban[1][8].el.onmouseout = hoverout29;
  ban[2][0].el.onmouseout = hoverout31; ban[2][1].el.onmouseout = hoverout32;
  ban[2][2].el.onmouseout = hoverout33; ban[2][3].el.onmouseout = hoverout34;
  ban[2][4].el.onmouseout = hoverout35; ban[2][5].el.onmouseout = hoverout36;
  ban[2][6].el.onmouseout = hoverout37; ban[2][7].el.onmouseout = hoverout38;
  ban[2][8].el.onmouseout = hoverout39;
  ban[3][0].el.onmouseout = hoverout41; ban[3][1].el.onmouseout = hoverout42;
  ban[3][2].el.onmouseout = hoverout43; ban[3][3].el.onmouseout = hoverout44;
  ban[3][4].el.onmouseout = hoverout45; ban[3][5].el.onmouseout = hoverout46;
  ban[3][6].el.onmouseout = hoverout47; ban[3][7].el.onmouseout = hoverout48;
  ban[3][8].el.onmouseout = hoverout49;
  ban[4][0].el.onmouseout = hoverout51; ban[4][1].el.onmouseout = hoverout52;
  ban[4][2].el.onmouseout = hoverout53; ban[4][3].el.onmouseout = hoverout54;
  ban[4][4].el.onmouseout = hoverout55; ban[4][5].el.onmouseout = hoverout56;
  ban[4][6].el.onmouseout = hoverout57; ban[4][7].el.onmouseout = hoverout58;
  ban[4][8].el.onmouseout = hoverout59;
  ban[5][0].el.onmouseout = hoverout61; ban[5][1].el.onmouseout = hoverout62;
  ban[5][2].el.onmouseout = hoverout63; ban[5][3].el.onmouseout = hoverout64;
  ban[5][4].el.onmouseout = hoverout65; ban[5][5].el.onmouseout = hoverout66;
  ban[5][6].el.onmouseout = hoverout67; ban[5][7].el.onmouseout = hoverout68;
  ban[5][8].el.onmouseout = hoverout69;
  ban[6][0].el.onmouseout = hoverout71; ban[6][1].el.onmouseout = hoverout72;
  ban[6][2].el.onmouseout = hoverout73; ban[6][3].el.onmouseout = hoverout74;
  ban[6][4].el.onmouseout = hoverout75; ban[6][5].el.onmouseout = hoverout76;
  ban[6][6].el.onmouseout = hoverout77; ban[6][7].el.onmouseout = hoverout78;
  ban[6][8].el.onmouseout = hoverout79;
  ban[7][0].el.onmouseout = hoverout81; ban[7][1].el.onmouseout = hoverout82;
  ban[7][2].el.onmouseout = hoverout83; ban[7][3].el.onmouseout = hoverout84;
  ban[7][4].el.onmouseout = hoverout85; ban[7][5].el.onmouseout = hoverout86;
  ban[7][6].el.onmouseout = hoverout87; ban[7][7].el.onmouseout = hoverout88;
  ban[7][8].el.onmouseout = hoverout89;
  ban[8][0].el.onmouseout = hoverout91; ban[8][1].el.onmouseout = hoverout92;
  ban[8][2].el.onmouseout = hoverout93; ban[8][3].el.onmouseout = hoverout94;
  ban[8][4].el.onmouseout = hoverout95; ban[8][5].el.onmouseout = hoverout96;
  ban[8][6].el.onmouseout = hoverout97; ban[8][7].el.onmouseout = hoverout98;
  ban[8][8].el.onmouseout = hoverout99;
}

function gethtmlelement_tegoma() {
  sentegoma[0][1].el = document.getElementById('sg_fu_img');
  sentegoma[1][1].el = document.getElementById('sg_kyo_img');
  sentegoma[2][1].el = document.getElementById('sg_kei_img');
  sentegoma[3][1].el = document.getElementById('sg_gin_img');
  sentegoma[4][1].el = document.getElementById('sg_kin_img');
  sentegoma[5][1].el = document.getElementById('sg_kaku_img');
  sentegoma[6][1].el = document.getElementById('sg_hisha_img');
  sentegoma[0][1].el2 = document.getElementById('sg_fu_num');
  sentegoma[1][1].el2 = document.getElementById('sg_kyo_num');
  sentegoma[2][1].el2 = document.getElementById('sg_kei_num');
  sentegoma[3][1].el2 = document.getElementById('sg_gin_num');
  sentegoma[4][1].el2 = document.getElementById('sg_kin_num');
  sentegoma[5][1].el2 = document.getElementById('sg_kaku_num');
  sentegoma[6][1].el2 = document.getElementById('sg_hisha_num');
  gotegoma[0][1].el = document.getElementById('gg_fu_img');
  gotegoma[1][1].el = document.getElementById('gg_kyo_img');
  gotegoma[2][1].el = document.getElementById('gg_kei_img');
  gotegoma[3][1].el = document.getElementById('gg_gin_img');
  gotegoma[4][1].el = document.getElementById('gg_kin_img');
  gotegoma[5][1].el = document.getElementById('gg_kaku_img');
  gotegoma[6][1].el = document.getElementById('gg_hisha_img');
  gotegoma[0][1].el2 = document.getElementById('gg_fu_num');
  gotegoma[1][1].el2 = document.getElementById('gg_kyo_num');
  gotegoma[2][1].el2 = document.getElementById('gg_kei_num');
  gotegoma[3][1].el2 = document.getElementById('gg_gin_num');
  gotegoma[4][1].el2 = document.getElementById('gg_kin_num');
  gotegoma[5][1].el2 = document.getElementById('gg_kaku_num');
  gotegoma[6][1].el2 = document.getElementById('gg_hisha_num');
}

function gethtmlelement_tegomaclick() {
  sentegoma[0][1].el.onclick = clickstgfu;
  sentegoma[1][1].el.onclick = clickstgky;
  sentegoma[2][1].el.onclick = clickstgke;
  sentegoma[3][1].el.onclick = clickstggi;
  sentegoma[4][1].el.onclick = clickstgki;
  sentegoma[5][1].el.onclick = clickstgka;
  sentegoma[6][1].el.onclick = clickstghi;
  sentegoma[0][1].el2.onclick = clickstgfu;
  sentegoma[1][1].el2.onclick = clickstgky;
  sentegoma[2][1].el2.onclick = clickstgke;
  sentegoma[3][1].el2.onclick = clickstggi;
  sentegoma[4][1].el2.onclick = clickstgki;
  sentegoma[5][1].el2.onclick = clickstgka;
  sentegoma[6][1].el2.onclick = clickstghi;
  gotegoma[0][1].el.onclick = clickgtgfu;
  gotegoma[1][1].el.onclick = clickgtgky;
  gotegoma[2][1].el.onclick = clickgtgke;
  gotegoma[3][1].el.onclick = clickgtggi;
  gotegoma[4][1].el.onclick = clickgtgki;
  gotegoma[5][1].el.onclick = clickgtgka;
  gotegoma[6][1].el.onclick = clickgtghi;
  gotegoma[0][1].el2.onclick = clickgtgfu;
  gotegoma[1][1].el2.onclick = clickgtgky;
  gotegoma[2][1].el2.onclick = clickgtgke;
  gotegoma[3][1].el2.onclick = clickgtggi;
  gotegoma[4][1].el2.onclick = clickgtgki;
  gotegoma[5][1].el2.onclick = clickgtgka;
  gotegoma[6][1].el2.onclick = clickgtghi;
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
 * @param {Number} x マス目の座標
 * @param {Number} y マス目の座標
 */
function abshoverout(x, y) {
 // var masu = ban[x][y];
 hovercell(null);
 activatemovable(true);
}

function hoverout11() {abshoverout(0, 0);}
function hoverout12() {abshoverout(0, 1);}
function hoverout13() {abshoverout(0, 2);}
function hoverout14() {abshoverout(0, 3);}
function hoverout15() {abshoverout(0, 4);}
function hoverout16() {abshoverout(0, 5);}
function hoverout17() {abshoverout(0, 6);}
function hoverout18() {abshoverout(0, 7);}
function hoverout19() {abshoverout(0, 8);}
function hoverout21() {abshoverout(1, 0);}
function hoverout22() {abshoverout(1, 1);}
function hoverout23() {abshoverout(1, 2);}
function hoverout24() {abshoverout(1, 3);}
function hoverout25() {abshoverout(1, 4);}
function hoverout26() {abshoverout(1, 5);}
function hoverout27() {abshoverout(1, 6);}
function hoverout28() {abshoverout(1, 7);}
function hoverout29() {abshoverout(1, 8);}
function hoverout31() {abshoverout(2, 0);}
function hoverout32() {abshoverout(2, 1);}
function hoverout33() {abshoverout(2, 2);}
function hoverout34() {abshoverout(2, 3);}
function hoverout35() {abshoverout(2, 4);}
function hoverout36() {abshoverout(2, 5);}
function hoverout37() {abshoverout(2, 6);}
function hoverout38() {abshoverout(2, 7);}
function hoverout39() {abshoverout(2, 8);}
function hoverout41() {abshoverout(3, 0);}
function hoverout42() {abshoverout(3, 1);}
function hoverout43() {abshoverout(3, 2);}
function hoverout44() {abshoverout(3, 3);}
function hoverout45() {abshoverout(3, 4);}
function hoverout46() {abshoverout(3, 5);}
function hoverout47() {abshoverout(3, 6);}
function hoverout48() {abshoverout(3, 7);}
function hoverout49() {abshoverout(3, 8);}
function hoverout51() {abshoverout(4, 0);}
function hoverout52() {abshoverout(4, 1);}
function hoverout53() {abshoverout(4, 2);}
function hoverout54() {abshoverout(4, 3);}
function hoverout55() {abshoverout(4, 4);}
function hoverout56() {abshoverout(4, 5);}
function hoverout57() {abshoverout(4, 6);}
function hoverout58() {abshoverout(4, 7);}
function hoverout59() {abshoverout(4, 8);}
function hoverout61() {abshoverout(5, 0);}
function hoverout62() {abshoverout(5, 1);}
function hoverout63() {abshoverout(5, 2);}
function hoverout64() {abshoverout(5, 3);}
function hoverout65() {abshoverout(5, 4);}
function hoverout66() {abshoverout(5, 5);}
function hoverout67() {abshoverout(5, 6);}
function hoverout68() {abshoverout(5, 7);}
function hoverout69() {abshoverout(5, 8);}
function hoverout71() {abshoverout(6, 0);}
function hoverout72() {abshoverout(6, 1);}
function hoverout73() {abshoverout(6, 2);}
function hoverout74() {abshoverout(6, 3);}
function hoverout75() {abshoverout(6, 4);}
function hoverout76() {abshoverout(6, 5);}
function hoverout77() {abshoverout(6, 6);}
function hoverout78() {abshoverout(6, 7);}
function hoverout79() {abshoverout(6, 8);}
function hoverout81() {abshoverout(7, 0);}
function hoverout82() {abshoverout(7, 1);}
function hoverout83() {abshoverout(7, 2);}
function hoverout84() {abshoverout(7, 3);}
function hoverout85() {abshoverout(7, 4);}
function hoverout86() {abshoverout(7, 5);}
function hoverout87() {abshoverout(7, 6);}
function hoverout88() {abshoverout(7, 7);}
function hoverout89() {abshoverout(7, 8);}
function hoverout91() {abshoverout(8, 0);}
function hoverout92() {abshoverout(8, 1);}
function hoverout93() {abshoverout(8, 2);}
function hoverout94() {abshoverout(8, 3);}
function hoverout95() {abshoverout(8, 4);}
function hoverout96() {abshoverout(8, 5);}
function hoverout97() {abshoverout(8, 6);}
function hoverout98() {abshoverout(8, 7);}
function hoverout99() {abshoverout(8, 8);}

/**
 * マスにカーソルが入った時に呼ばれる
 *
 * @param {Number} x マス目の座標
 * @param {Number} y マス目の座標
 */
function abshoverin(x, y) {
 var masui = ban[x][y].el;
 hovercell(masui);
}

function hoverin11() {abshoverin(0, 0);} function hoverin12() {abshoverin(0, 1);}
function hoverin13() {abshoverin(0, 2);} function hoverin14() {abshoverin(0, 3);}
function hoverin15() {abshoverin(0, 4);} function hoverin16() {abshoverin(0, 5);}
function hoverin17() {abshoverin(0, 6);} function hoverin18() {abshoverin(0, 7);}
function hoverin19() {abshoverin(0, 8);}
function hoverin21() {abshoverin(1, 0);} function hoverin22() {abshoverin(1, 1);}
function hoverin23() {abshoverin(1, 2);} function hoverin24() {abshoverin(1, 3);}
function hoverin25() {abshoverin(1, 4);} function hoverin26() {abshoverin(1, 5);}
function hoverin27() {abshoverin(1, 6);} function hoverin28() {abshoverin(1, 7);}
function hoverin29() {abshoverin(1, 8);}
function hoverin31() {abshoverin(2, 0);} function hoverin32() {abshoverin(2, 1);}
function hoverin33() {abshoverin(2, 2);} function hoverin34() {abshoverin(2, 3);}
function hoverin35() {abshoverin(2, 4);} function hoverin36() {abshoverin(2, 5);}
function hoverin37() {abshoverin(2, 6);} function hoverin38() {abshoverin(2, 7);}
function hoverin39() {abshoverin(2, 8);}
function hoverin41() {abshoverin(3, 0);} function hoverin42() {abshoverin(3, 1);}
function hoverin43() {abshoverin(3, 2);} function hoverin44() {abshoverin(3, 3);}
function hoverin45() {abshoverin(3, 4);} function hoverin46() {abshoverin(3, 5);}
function hoverin47() {abshoverin(3, 6);} function hoverin48() {abshoverin(3, 7);}
function hoverin49() {abshoverin(3, 8);}
function hoverin51() {abshoverin(4, 0);} function hoverin52() {abshoverin(4, 1);}
function hoverin53() {abshoverin(4, 2);} function hoverin54() {abshoverin(4, 3);}
function hoverin55() {abshoverin(4, 4);} function hoverin56() {abshoverin(4, 5);}
function hoverin57() {abshoverin(4, 6);} function hoverin58() {abshoverin(4, 7);}
function hoverin59() {abshoverin(4, 8);}
function hoverin61() {abshoverin(5, 0);} function hoverin62() {abshoverin(5, 1);}
function hoverin63() {abshoverin(5, 2);} function hoverin64() {abshoverin(5, 3);}
function hoverin65() {abshoverin(5, 4);} function hoverin66() {abshoverin(5, 5);}
function hoverin67() {abshoverin(5, 6);} function hoverin68() {abshoverin(5, 7);}
function hoverin69() {abshoverin(5, 8);}
function hoverin71() {abshoverin(6, 0);} function hoverin72() {abshoverin(6, 1);}
function hoverin73() {abshoverin(6, 2);} function hoverin74() {abshoverin(6, 3);}
function hoverin75() {abshoverin(6, 4);} function hoverin76() {abshoverin(6, 5);}
function hoverin77() {abshoverin(6, 6);} function hoverin78() {abshoverin(6, 7);}
function hoverin79() {abshoverin(6, 8);}
function hoverin81() {abshoverin(7, 0);} function hoverin82() {abshoverin(7, 1);}
function hoverin83() {abshoverin(7, 2);} function hoverin84() {abshoverin(7, 3);}
function hoverin85() {abshoverin(7, 4);} function hoverin86() {abshoverin(7, 5);}
function hoverin87() {abshoverin(7, 6);} function hoverin88() {abshoverin(7, 7);}
function hoverin89() {abshoverin(7, 8);}
function hoverin91() {abshoverin(8, 0);} function hoverin92() {abshoverin(8, 1);}
function hoverin93() {abshoverin(8, 2);} function hoverin94() {abshoverin(8, 3);}
function hoverin95() {abshoverin(8, 4);} function hoverin96() {abshoverin(8, 5);}
function hoverin97() {abshoverin(8, 6);} function hoverin98() {abshoverin(8, 7);}
function hoverin99() {abshoverin(8, 8);}

function fillactivemasu(x, y, c)
{
  var masui = ban[x][y].el;
  if (masui !== null) {
   masui.style.backgroundColor = c;
  }
}

/**
 * 移動可能なマスのハイライト制御
 *
 * @param {Boolean} b true:ハイライトする, false:ハイライトしない
 */
function activatemovable(b) {
 var c, sz, idx, x, y;
 if (b) {
  c = movableColor;
 } else {
  c = banColor;
 }
 if (hifumin_eye) {
  sz = activemovable.length;
  for (idx = 0; idx < sz; ++idx) {
   x = 8 - activemovable[idx][0];
   y = 8 - activemovable[idx][1];
   fillactivemasu(x, y, c);
  }
 } else {
  sz = activemovable.length;
  for (idx = 0; idx < sz; ++idx) {
   x = activemovable[idx][0];
   y = activemovable[idx][1];
   fillactivemasu(x, y, c);
  }
 }
}

/**
 * マスを選択状態表示にする。
 *
 * @param {Object} masui 対象のマス
 * @param {Boolean} b true:選択状態にする,false:選択状態を解除する
 */
function setactivecell(masui, b) {
 if (b) {
  masui.style.border = '2px solid ' + activeColor;
 } else {
  masui.style.border = '2px solid black';
 }
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
 if (activemasu !== null) {
  setactivecell(activemasui, false);
  if (activemasu !== masu) {
   activatemovable(false);
  }
 }
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
 if (activetegoma !== null)
  activeuchi(null, null, null);
 activecell(koma, masu, masui);
}

function deactivate_activecell() {
 if (activetegoma !== null)
  activeuchi(null, null, null);
 else
  activecell(null, null, null);
}

function check_activemovablemasu(hx, hy) {
 var sz = activemovable.length;
 for (var idx = 0; idx < sz; ++idx) {
  if (activemovable[idx][0] === hx && activemovable[idx][1] === hy) {
   return true;
  }
 }
 return false;
}

/**
 * マスをクリックした時に呼ばれる。
 *
 * @param {Number} x マス目の座標
 * @param {Number} y マス目の座標
 */
function absclick(x, y) {
 if (taikyokuchu === false) {
  return;
 }
 if (wait_narimenu) {
  return;
 }
 var hx = x;  // 1~９筋(0~8)
 var hy = y;  // 一~九段(0~8)
 if (hifumin_eye) {
   hx = 8 - hx;
   hy = 8 - hy;
 } else {
 }
 var koma = ban[hx][hy].koma;
 var masu = ban[x][y];
 var masui = ban[x][y].el;
 if (activemasu === masu) {
  // アクティブなマスをクリックしたので非アクティブにする。
  activecell(null, null, null);
 } else {
  if (activemasu === null) {
   // アクティブなマスはないので
   // 自分の駒をクリックしたならアクティブにする。
   absclick_wo_active(koma, masu, masui);
  } else if (activekoma.teban === koma.teban) {
   // 自分の駒をクリックしたので非アクティブにする。
   absclick_on_mypiece(koma, masu, masui);
  } else if (koma.teban === Koma.AKI) {
   // 空きマスをクリックした
   var ismovable = check_activemovablemasu(hx, hy);
   if (ismovable === false) {
    // 選択キャンセル
    deactivate_activecell();
   } else {
    if (activemasu.x === -1) {
     // uchi
     msg = activekoma.movemsg(hx, hy);
     myconfirm(msg, CFRM_UTSU, hx, hy);
    } else {
     msg = activekoma.movemsg(hx, hy);
     myconfirm(msg, CFRM_MOVE, hx, hy);
    }
   }
  } else {
   ismovable = check_activemovablemasu(hx, hy);
   if (ismovable === false) {
    // 選択キャンセル
    deactivate_activecell();
   } else {
    msg = activekoma.movemsg(hx, hy);
    myconfirm(msg, CFRM_MVCAP, hx, hy);
   }
  }
 }
}

function click11() {absclick(0, 0);} function click12() {absclick(0, 1);}
function click13() {absclick(0, 2);} function click14() {absclick(0, 3);}
function click15() {absclick(0, 4);} function click16() {absclick(0, 5);}
function click17() {absclick(0, 6);} function click18() {absclick(0, 7);}
function click19() {absclick(0, 8);}
function click21() {absclick(1, 0);} function click22() {absclick(1, 1);}
function click23() {absclick(1, 2);} function click24() {absclick(1, 3);}
function click25() {absclick(1, 4);} function click26() {absclick(1, 5);}
function click27() {absclick(1, 6);} function click28() {absclick(1, 7);}
function click29() {absclick(1, 8);}
function click31() {absclick(2, 0);} function click32() {absclick(2, 1);}
function click33() {absclick(2, 2);} function click34() {absclick(2, 3);}
function click35() {absclick(2, 4);} function click36() {absclick(2, 5);}
function click37() {absclick(2, 6);} function click38() {absclick(2, 7);}
function click39() {absclick(2, 8);}
function click41() {absclick(3, 0);} function click42() {absclick(3, 1);}
function click43() {absclick(3, 2);} function click44() {absclick(3, 3);}
function click45() {absclick(3, 4);} function click46() {absclick(3, 5);}
function click47() {absclick(3, 6);} function click48() {absclick(3, 7);}
function click49() {absclick(3, 8);}
function click51() {absclick(4, 0);} function click52() {absclick(4, 1);}
function click53() {absclick(4, 2);} function click54() {absclick(4, 3);}
function click55() {absclick(4, 4);} function click56() {absclick(4, 5);}
function click57() {absclick(4, 6);} function click58() {absclick(4, 7);}
function click59() {absclick(4, 8);}
function click61() {absclick(5, 0);} function click62() {absclick(5, 1);}
function click63() {absclick(5, 2);} function click64() {absclick(5, 3);}
function click65() {absclick(5, 4);} function click66() {absclick(5, 5);}
function click67() {absclick(5, 6);} function click68() {absclick(5, 7);}
function click69() {absclick(5, 8);}
function click71() {absclick(6, 0);} function click72() {absclick(6, 1);}
function click73() {absclick(6, 2);} function click74() {absclick(6, 3);}
function click75() {absclick(6, 4);} function click76() {absclick(6, 5);}
function click77() {absclick(6, 6);} function click78() {absclick(6, 7);}
function click79() {absclick(6, 8);}
function click81() {absclick(7, 0);} function click82() {absclick(7, 1);}
function click83() {absclick(7, 2);} function click84() {absclick(7, 3);}
function click85() {absclick(7, 4);} function click86() {absclick(7, 5);}
function click87() {absclick(7, 6);} function click88() {absclick(7, 7);}
function click89() {absclick(7, 8);}
function click91() {absclick(8, 0);} function click92() {absclick(8, 1);}
function click93() {absclick(8, 2);} function click94() {absclick(8, 3);}
function click95() {absclick(8, 4);} function click96() {absclick(8, 5);}
function click97() {absclick(8, 6);} function click98() {absclick(8, 7);}
function click99() {absclick(8, 8);}

/**
 * 手駒のマスを選択状態表示にする。
 *
 * @param {Object} masui 対象のマス
 * @param {Boolean} b true:選択状態にする,false:選択状態を解除する
 */
function setactivecelluchi(masui, b) {
 if (b) {
  masui.style.border = '2px solid ' + activeColor;
 } else {
  masui.style.border = '0px solid black';
 }
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
  if (activemasu !== null) {
   setactivecelluchi(activemasui, false);
  }
  activatemovable(false);
 }
 if (tegoma === null || (activekoma !== null && activekoma.id === i)) {
  activetegoma = null;
  activemasu = null;
  activemovable = [];
  activekoma = null;
  return;
 }

 var masu = tegomasu[i][1];
 var masui = tegomasu[i][1].el;
 // var koma = tegoma[i][0][tegoma[i][0].length - 1];

 activetegoma = tegoma;
 activemasu = masu;
 activemasui = masui;
 activekoma = koma;

 setactivecelluchi(masui, true);
 activemovable = koma.getUchable();
 activatemovable(true);
}

/**
 * 先手の手駒をクリックした
 *
 * @param {Number} i 駒ID
 */
function absclickst(i) {
 if (taikyokuchu === false) {
  return;
 }
 var mytegoma, myteban;
 if (hifumin_eye) {
  myteban = Koma.GOTEBAN;
  mytegoma = gotegoma;
 } else {
  myteban = Koma.SENTEBAN;
  mytegoma = sentegoma;
 }
 if (activeteban !== myteban) {
  return;
 }
 if (activemasu !== null) {
   if (activetegoma === null) {
    activecell(null, null, null);
   }
 }
 var koma = mytegoma[i][0][mytegoma[i][0].length - 1];
 if (koma === undefined) {
  return;
 }
 var mytegomasu = sentegoma;
 activeuchi(koma, mytegoma, mytegomasu, i);
}

/**
 * 後手の手駒をクリックした
 *
 * @param {Number} i 駒ID
 */
function absclickgt(i) {
 if (taikyokuchu === false) {
  return;
 }
 var mytegoma, myteban;
 if (hifumin_eye) {
  myteban = Koma.SENTEBAN;
  mytegoma = sentegoma;
 } else {
  myteban = Koma.GOTEBAN;
  mytegoma = gotegoma;
 }
 if (activeteban !== myteban) {
  return;
 }
 if (activemasu !== null) {
   if (activetegoma === null) {
    activecell(null, null, null);
   }
 }
 var koma = mytegoma[i][0][mytegoma[i][0].length - 1];
 if (koma === undefined) {
  return;
 }
 var mytegomasu = gotegoma;
 activeuchi(koma, mytegoma, mytegomasu, i);
}

function clickstgfu() {absclickst(0);} function clickstgky() {absclickst(1);}
function clickstgke() {absclickst(2);} function clickstggi() {absclickst(3);}
function clickstgki() {absclickst(4);} function clickstgka() {absclickst(5);}
function clickstghi() {absclickst(6);}
function clickgtgfu() {absclickgt(0);} function clickgtgky() {absclickgt(1);}
function clickgtgke() {absclickgt(2);} function clickgtggi() {absclickgt(3);}
function clickgtgki() {absclickgt(4);} function clickgtgka() {absclickgt(5);}
function clickgtghi() {absclickgt(6);}

/**
 * 成り選択メニューを出す
 *
 * @param {Number} x 座標[ピクセル]
 * @param {Number} y 座標[ピクセル]
 */
function popupnari(x, y) {
 narimenu.style.left = x + 'px';
 narimenu.style.top = y + 'px';
 narimenu.style.visibility = 'visible';
 wait_narimenu = true;
}

/**
 * 駒を成る
 */
function clicknari() {
 move(activekoma, narimenu_tox, narimenu_toy, Koma.NARI);
 activecell(null, null);

 wait_narimenu = false;
 narimenu.style.visibility = 'hidden';
 update_screen();
 record_your_move();
}

/**
 * 駒を成らない
 */
function clicknarazu() {
 move(activekoma, narimenu_tox, narimenu_toy, Koma.NARERU);
 activecell(null, null);

 wait_narimenu = false;
 narimenu.style.visibility = 'hidden';
 update_screen();
 record_your_move();
}

/**
 * 着手確認ダイアログの表示
 * @param  {String} msg  メッセージ
 * @param  {[type]} type 0:打つとき, 1:動かすだけの時, 2:駒をとって動かすとき
 */
function myconfirm(msg, type, hx, hy) {
  msgui = document.getElementById('msg_movecfrm')
  msgui.innerText = msg;
  cfrmdlg.md = type;
  cfrmdlg.hx = hx;
  cfrmdlg.hy = hy;
  cfrmdlg.style.visibility = 'visible';
}

function clickcfrm_ok_move(hx, hy)
{
 // toru(取らないけど)
 toru(hx, hy);

 // move
 var nareru = activekoma.checkNari(activekoma.y, hy);
 if (nareru === Koma.NARENAI || nareru === Koma.NATTA) {
  move(activekoma, hx, hy, Koma.NARAZU);
  activecell(null, null, null);
  update_screen();
  record_your_move();
 } else if (nareru === Koma.NARU) {
  move(activekoma, hx, hy, Koma.NARI);
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
 // toru and move
 // toru
 toru(hx, hy);

 // move
 var nareru = activekoma.checkNari(activekoma.y, hy);
 if (nareru === Koma.NARENAI || nareru === Koma.NATTA) {
  move(activekoma, hx, hy, Koma.NARAZU);
  activecell(null, null, null);
  update_screen();
  record_your_move();
 } else if (nareru === Koma.NARU) {
  move(activekoma, hx, hy, Koma.NARI);
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
  uchi(activetegoma, activekoma, hx, hy);
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
  //駒の移動をやめる
  activecell(null, null, null);
 /* } else if (cfrmdlg.md === CFRM_RESIGN) { */
 }

 cfrmdlg.style.visibility = 'hidden';
}

/**
 * 新規対局
 */
function new_kyoku() {
 mykifu.reset();
 initKoma();
 activeteban = Koma.SENTEBAN;
 update_screen();
}

// タイマのID
var taikyokuchu_timer;
// タイマが使うデータ
var taikyokuchu_param = 0;

function taikyokuchu_tmout()
{
 ++taikyokuchu_param;
 taikyokuchu_param %= 255;
 var c = 255 - taikyokuchu_param;
 nameSente.style.backgroundColor = 'rgb(255,' + c + ',255)';
 nameGote.style.backgroundColor = 'rgb(' + c + ',255,' + c + ')';
}


/**
 * 対局始め
 */
function start_kyoku() {
 if (taikyokuchu === true) {
  return;
 }
 taikyokuchu = true;
 // activeteban = Koma.SENTEBAN;
 // mykifu.putHeader(nameSente.value, nameGote.value);
 update_screen();
 taikyokuchu_timer = setInterval('taikyokuchu_tmout()', 500);
}

/**
 * 対局中断
 */
function stop_kyoku() {
 if (taikyokuchu === false) {
  return;
 }
 taikyokuchu = false;
 update_screen();
 clearInterval(taikyokuchu_timer);
}

/**
 * 投了
 */
function giveup() {
 if (taikyokuchu === false) {
  return;
 }
 taikyokuchu = false;
 mykifu.putFooter(Koma.SENTEBAN);
 update_screen();
 clearInterval(taikyokuchu_timer);
}

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

var sfenkoma = function(dan, ndan) {
 var result = [];
 var len = dan.length;
 var strdan = '';
 var nari = 0;
 var nsuji = 8;
 for (var j = 0; j < len; ++j) {
  var ch = dan.charAt(j);
  if (ch === 'p') {
   var fu = new Fu(Koma.GOTEBAN, nsuji, ndan);
   if (nari !== 0) {
    fu.nari = Koma.NARI;
   }
   result.push(fu);
   nari = 0;
   --nsuji;
  } else if (ch === 'l') {
   var kyosha = new Kyosha(Koma.GOTEBAN, nsuji, ndan);
   if (nari !== 0) {
    kyosha.nari = Koma.NARI;
   }
   result.push(kyosha);
   nari = 0;
   --nsuji;
  } else if (ch === 'n') {
   var keima = new Keima(Koma.GOTEBAN, nsuji, ndan);
   if (nari !== 0) {
    keima.nari = Koma.NARI;
   }
   result.push(keima);
   nari = 0;
   --nsuji;
  } else if (ch === 's') {
   var gin = new Gin(Koma.GOTEBAN, nsuji, ndan);
   if (nari !== 0) {
    gin.nari = Koma.NARI;
   }
   result.push(gin);
   nari = 0;
   --nsuji;
  } else if (ch === 'g') {
   result.push(new Kin(Koma.GOTEBAN, nsuji, ndan));
   nari = 0;
   --nsuji;
  } else if (ch === 'b') {
   var kaku = new Kaku(Koma.GOTEBAN, nsuji, ndan);
   if (nari !== 0) {
    kaku.nari = Koma.NARI;
   }
   result.push(kaku);
   nari = 0;
   --nsuji;
  } else if (ch === 'r') {
   var hisha = new Hisha(Koma.GOTEBAN, nsuji, ndan);
   if (nari !== 0) {
    hisha.nari = Koma.NARI;
   }
   result.push(hisha);
   nari = 0;
   --nsuji;
  } else if (ch === 'k') {
   result.push(new Gyoku(Koma.GOTEBAN, nsuji, ndan));
   nari = 0;
   --nsuji;
  } else if (ch === 'P') {
   fu = new Fu(Koma.SENTEBAN, nsuji, ndan);
   if (nari !== 0) {
    fu.nari = Koma.NARI;
   }
   result.push(fu);
   nari = 0;
   --nsuji;
  } else if (ch === 'L') {
   kyosha = new Kyosha(Koma.SENTEBAN, nsuji, ndan);
   if (nari !== 0) {
    kyosha.nari = Koma.NARI;
   }
   result.push(kyosha);
   nari = 0;
   --nsuji;
  } else if (ch === 'N') {
   keima = new Keima(Koma.SENTEBAN, nsuji, ndan);
   if (nari !== 0) {
    keima.nari = Koma.NARI;
   }
   result.push(keima);
   nari = 0;
   --nsuji;
  } else if (ch === 'S') {
   gin = new Gin(Koma.SENTEBAN, nsuji, ndan);
   if (nari !== 0) {
    gin.nari = Koma.NARI;
   }
   result.push(gin);
   nari = 0;
   --nsuji;
  } else if (ch === 'G') {
   result.push(new Kin(Koma.SENTEBAN, nsuji, ndan));
   nari = 0;
   --nsuji;
  } else if (ch === 'B') {
   kaku = new Kaku(Koma.SENTEBAN, nsuji, ndan);
   if (nari !== 0) {
    kaku.nari = Koma.NARI;
   }
   result.push(kaku);
   nari = 0;
   --nsuji;
  } else if (ch === 'R') {
   hisha = new Hisha(Koma.SENTEBAN, nsuji, ndan);
   if (nari !== 0) {
    hisha.nari = Koma.NARI;
   }
   result.push(hisha);
   nari = 0;
   --nsuji;
  } else if (ch === 'K') {
   result.push(new Gyoku(Koma.SENTEBAN, nsuji, ndan));
   nari = 0;
   --nsuji;
  } else if (ch === '+') {
   nari = 1;
  } else if (/[1-9]/.test(ch)) {
   var naki = +ch;
   nari = 0;
   for (var i = 0; i < naki; ++i)
    result.push(new Koma());
   nsuji -= naki;
  }
 }
 return result;
};

var sfentegoma = function(tegomastr) {
 var tegoma = [new Array(7), new Array(7)];
 for (var i = 0; i < 7; ++i) {
  tegoma[0][i] = 0;
  tegoma[1][i] = 0;
 }
 var num = 1;
 var len = tegomastr.length;
 for (var j = 0; j < len; ++j) {
  var ch = tegomastr.charAt(j);
  if (ch === 'p') {
   tegoma[1][0] = num;
   num = 1;
  } else if (ch === 'l') {
   tegoma[1][1] = num;
   num = 1;
  } else if (ch === 'n') {
   tegoma[1][2] = num;
   num = 1;
  } else if (ch === 's') {
   tegoma[1][3] = num;
   num = 1;
  } else if (ch === 'g') {
   tegoma[1][4] = num;
   num = 1;
  } else if (ch === 'b') {
   tegoma[1][5] = num;
   num = 1;
  } else if (ch === 'r') {
   tegoma[1][6] = num;
   num = 1;
  // } else if (ch === 'k') {
  //  tegoma[0][7] = num;
  // num = 1;
  } else if (ch === 'P') {
   tegoma[0][0] = num;
   num = 1;
  } else if (ch === 'L') {
   tegoma[0][1] = num;
   num = 1;
  } else if (ch === 'N') {
   tegoma[0][2] = num;
   num = 1;
  } else if (ch === 'S') {
   tegoma[0][3] = num;
   num = 1;
  } else if (ch === 'G') {
   tegoma[0][4] = num;
   num = 1;
  } else if (ch === 'B') {
   tegoma[0][5] = num;
   num = 1;
  } else if (ch === 'R') {
   tegoma[0][6] = num;
   num = 1;
  // } else if (ch === 'K') {
  //  tegoma[0][7] = num;
  //  num = 1;
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
  var num = ntegoma[0];
  for (var k = 0; k < num; ++k) {
   komadai_add(tegoma, new Fu(teban, -1, -1));
  }
  num = ntegoma[1];
  for (k = 0; k < num; ++k) {
   komadai_add(tegoma, new Kyosha(teban, -1, -1));
  }
  num = ntegoma[2];
  for (k = 0; k < num; ++k) {
   komadai_add(tegoma, new Keima(teban, -1, -1));
  }
  num = ntegoma[3];
  for (k = 0; k < num; ++k) {
   komadai_add(tegoma, new Gin(teban, -1, -1));
  }
  num = ntegoma[4];
  for (k = 0; k < num; ++k) {
   komadai_add(tegoma, new Kin(teban, -1, -1));
  }
  num = ntegoma[5];
  for (k = 0; k < num; ++k) {
   komadai_add(tegoma, new Kaku(teban, -1, -1));
  }
  num = ntegoma[6];
  for (k = 0; k < num; ++k) {
   komadai_add(tegoma, new Hisha(teban, -1, -1));
  }
}

/**
 *
 * @param {String} sfentext sfen文字列
 */
function fromsfen(sfentext) {
 // var sfenarea = document.getElementById('sfen');
 initKomaEx();

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

 sz = bandan.length;
 for (var i = 0; i < sz; ++i) {
  dankoma = sfenkoma(bandan[i], i);
  for (var j = 0; j < 9; ++j) {
   ban[8 - j][i].koma = dankoma[j];
  }
 }

 // 手駒
 tegoma = sfentegoma(sfenitem[2]);
 sfentegoma_add(tegoma[0], sentegoma, Koma.SENTEBAN);
 sfentegoma_add(tegoma[1], gotegoma, Koma.GOTEBAN);

 if (sfenitem[1] === 'b') {
  activeteban = Koma.SENTEBAN;
 } else if (sfenitem[1] === 'w') {
  activeteban = Koma.GOTEBAN;
 } else {
  // keep current teban
 }

 mykifu.NTeme = sfenitem[3] | 0;
}

var sfen_genbantext = function(shogiban) {
 var shogibantext = [];
 for (var i = 0; i < 9; ++i) {
  var aki = 0;
  shogibantext[i] = '';
  for (var j = 0; j < 9; ++j) {
   var komach = '';
   var koma = shogiban[8 - j][i].koma;
   if (koma.nari === Koma.NARI) {
    komach = '+';
   } else {
    komach = '';
   }
   var komatbl = 'PLNSGBRK';
   var komaid = koma.id;
   if (koma.FuID <= komaid && komaid <= koma.GyokuID) {
    komach += komatbl.charAt(komaid);
   } else {
    aki = aki + 1;
   }
   var teban = koma.teban;
   if (teban === Koma.GOTEBAN) {
    komach = komach.toLowerCase();
   }
   if (komach !== '') {
    if (aki > 0) {
     shogibantext[i] += aki;
     aki = 0;
    }
    shogibantext[i] += komach;
   }
  }
  if (aki > 0) {
   shogibantext[i] += aki;
   aki = 0;
  }
 }
 return shogibantext;
};

function sfen_gentegomatext(komadai, komatbl) {
  var sfentegomatext = '';

  for (var i = 0; i < 7; ++i) {
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
 var komatblb = 'PLNSGBR';
 var sfentegomatext = sfen_gentegomatext(sentekomadai, komatblb);

 var komatblw = 'plnsgbr';
 sfentegomatext += sfen_gentegomatext(gotekomadai, komatblw);

 if (sfentegomatext.length === 0) {
   sfentegomatext = '-';
 }
 return sfentegomatext;
};

/**
 * @param {String} nth 何手目
 */
function gensfen(nth /*= '1'*/) {
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

 // var sfenarea = document.getElementById('sfen');
 // sfenarea.value = sfentext;
 var sfenarea = document.getElementById('sfen_');
 sfenarea.innerHTML = sfentext;
}

function activateteban()
{
  // String('true') or String('false')
 var strfinished = document.getElementById('isfinished').value;
 var isfinished = (strfinished !== 'false');  // convert to boolean
 if (isfinished) {
  taikyokuchu = false;
 } else {
  // var teban = document.getElementById('myturn').value;
  // if (teban !== '0') taikyokuchu = true;
  var teban = document.getElementById('myteban').value;
  if (teban === 'b' && activeteban === Koma.SENTEBAN) taikyokuchu = true;
  else if (teban === 'w' && activeteban === Koma.GOTEBAN) taikyokuchu = true;
  else taikyokuchu = false;
 }

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
 if (taikyokuchu) {
  document.getElementById('btn_resign').style.display = 'inline';
 } else {
  document.getElementById('btn_resign').style.display = 'none';
 }
}

function checkLatestMoveTmout()
{
 var ajax = new XMLHttpRequest();
 if (ajax !== null) {
  // tsushinchu = true;
  // activatefogscreen();
  ajax.open('POST', 'getsfen.rb?' + id, true);
  ajax.overrideMimeType('text/plain; charset=UTF-8');
  ajax.send('');
  ajax.onreadystatechange = function() {
   // tsushinchu = false;
   // var msg = document.getElementById('msg_fogscreen');
   switch (ajax.readyState) {
   case 4:
    var status = ajax.status;
    if (status === 0) {  // XHR 通信失敗
    //  msg.innerHTML += 'XHR 通信失敗\n自動的にリロードします。';
    //   location.reload(true);
     startUpdateTimer();
    } else {  // XHR 通信成功
     if ((200 <= status && status < 300) || status === 304) {
      // リクエスト成功
      var resp = ajax.responseText
      checkSfenResponse(resp);
      // msg.innerHTML = '通信完了。\n自動的にリロードします。';
      // location.reload(true);
     } else {  // リクエスト失敗
      // msg.innerHTML += 'その他の応答:" + status + "\n自動的にリロードします。';
      // location.reload(true);
      startUpdateTimer();
     }
    }
    break;
   }
  };
 }
}

function checkSfenResponse(sfenstr)
{
 if (sfenstr.match(/^ERROR:/)) {
  // ERROR
  return;
 }

 var oldsfen = document.getElementById('sfen_').innerHTML;
 if (sfenstr !== oldsfen) {
  if (true) {
   // show reload button
   document.getElementById('notify_area').style.display = 'inline';
  } else {
   document.getElementById('sfen_').innerHTML = sfenstr;

   fromsfen(sfentext);

   activateteban();

   hifumin_eye = document.getElementById('hifumineye').checked;

   update_screen();

   if (!taikyokuchu) {
     startUpdateTimer();
   }
  }
 } else {
  startUpdateTimer();
 }
}


function startUpdateTimer()
{
 setTimeout('checkLatestMoveTmout()', 60000);
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
 * sfenを読み込んで指せる状態にする。
 */
function init_board() {
 gethtmlelement();
 mykifu.reset();

 var sfentext = document.getElementById('sfen_').innerHTML;
 fromsfen(sfentext);

 read_lastmove();

 activateteban();

 if (!taikyokuchu) {
  startUpdateTimer();
 }

 hifumin_eye = document.getElementById('hifumineye').checked;

 update_screen();
}

init_board();

function buildMoveMsg()
{
 ret = 'sfen=' + encodeURIComponent(document.getElementById('sfen_').innerHTML);
 // ret = 'sfen=' + encodeURIComponent(document.getElementById('sfen').value);
 ret += '&jsonmove=' + encodeURIComponent(movecsa);

 return ret;
}

var tsushinchu = false;

function send_csamove()
{
  var ajax = new XMLHttpRequest();
  if (ajax !== null) {
    tsushinchu = true;
    activatefogscreen();
    ajax.open('POST', 'move.rb?' + id, true);
    ajax.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    ajax.send(buildMoveMsg());
    ajax.onreadystatechange = function() {
     tsushinchu = false;
     var msg = document.getElementById('msg_fogscreen');
     switch (ajax.readyState) {
     case 4:
      var status = ajax.status;
      if (status === 0) {  // XHR 通信失敗
       msg.innerHTML += 'XHR 通信失敗\n自動的にリロードします。';
        location.reload(true);
      } else {  // XHR 通信成功
       if ((200 <= status && status < 300) || status === 304) {
        // リクエスト成功
        msg.innerHTML = '通信完了。\n自動的にリロードします。';
        location.reload(true);
       } else {  // リクエスト失敗
        msg.innerHTML += 'その他の応答:" + status + "\n自動的にリロードします。';
        location.reload(true);
       }
      }
      break;
     }
    };
  }
}

function record_your_move()
{
 taikyokuchu = false;

 nteme = mykifu.NTeme;
 // nteme = document.getElementById('nthmove').innerHTML;
 gensfen(nteme);

 send_csamove();
}

function activatefogscreen()
{
 block_elem_ban = document.getElementById('block_elem_ban');
 scr = document.getElementById('fogscreen');
 scr.style.zIndex = 0;
 scr.style.visibility = 'visible';
 scr.style.left = block_elem_ban.style.left;
 scr.style.top = block_elem_ban.style.top;
 scr.style.width = block_elem_ban.style.width;
 scr.style.clientHeight = block_elem_ban.style.clientHeight;

 msgscr = document.getElementById('msg_fogscreen');
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
 if (tsushinchu === false) {
  return;
 }
 return '通信中に終了すると指し手が登録されない恐れがあります。\n終了しますか？';
};

function openurlin_blank(url) {
 var win = window.open(url, '_blank');
 win.focus();
}

function onresign() {
 myconfirm("負けを認めますか？", CFRM_RESIGN, -1, -1);
 /*if (!confirm()) return;

 movecsa = '%TORYO';
 send_csamove();*/
}
