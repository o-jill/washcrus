# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require './file/taikyokureqfile.rb'
require './game/userinfo.rb'
require './views/common_ui.rb'

#
# 対局待合画面
#
class LoungeScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # 登録ボタンの表示
  def put_filing_button
    puts <<-FILING_BUTTON.unindent
      <hr>
      <div align='center'>
       <div id='filing_btn' class='btn_filing_lounge'>
        <input type='text' list='cmt_tmpl' id='cmt' class='inpform' placeholder='コメント欄'></input>
        <datalist id='cmt_tmpl'>
         <option value='よろしくお願いします。'>
         <option value='どなたでも歓迎！'>
         <option value='先手がいいです。'>
         <option value='後手がいいです。'>
         <option value='振り駒バッチ来い'>
         <option value='強い人はカンベン。'>
        </datalist>
        <button id='btn_f2l' class='inpform' onclick='file2lounge();'>対局待ちに登録</button>
        <br><span id='msg_l2f'></span>
       </div>
      </div>
      FILING_BUTTON
  end

  # Cancelボタンの表示
  def put_canceling_button
    puts <<-FILING_BUTTON.unindent
      <hr>
      <div align='center'>
       <div id='filing_btn' class='btn_filing_lounge'>
        <button id='btn_cfl' class='inpform' onclick='cancelfromlounge();'>対局待ちを解除</button>
        <br><span id='msg_cfl'></span>
       </div>
      </div>
      FILING_BUTTON
  end

  # 対局待ちユーザーの表示
  def put_userinlounge(reqdb, uid)
    scriptname = File.basename($PROGRAM_NAME)

    puts <<-TAIKYOKU_LOUNGE.unindent
      <script type='text/javascript' src='./js/lounge.js'></script>
      <div align='center'>
       <div class='btn_filing_lounge'>
        <form action='#{scriptname}?gennewgame3' method='post' name='gennewgame'>
      TAIKYOKU_LOUNGE

    reqdb.to_html('対局待ちユーザー', uid)

    puts <<-TAIKYOKU_BTN.unindent
      対戦相手は「<span id='opponentname'>(対戦相手を選んでください)</span>」です。<BR>
      <select class='inpform' name='sengo' id='sengo'>
       <option value='0'>自分が先手で</option>
       <option value='1'>自分が後手で</option>
       <option value='2'>振り駒で</option>
      </select>
      <input type="hidden" id="furigoma" name="furigoma" value="FTFTF" class='inpform'>
      <button id='btn_gen' class='inpform' onclick='return onstart()' disabled>Start!</button>
      </form>
      <img id='furikomanim1' src='image/komanim.gif' style='display:none' width='32' height='32'>
      <img id='furikomafu1' src='image/komafu.png' style='display:none' width='32' height='32'>
      <img id='furikomato1' src='image/komato.png' style='display:none' width='32' height='32'>
      <img id='furikomanim2' src='image/komanim.gif' style='display:none' width='32' height='32'>
      <img id='furikomafu2' src='image/komafu.png' style='display:none' width='32' height='32'>
      <img id='furikomato2' src='image/komato.png' style='display:none' width='32' height='32'>
      <img id='furikomanim3' src='image/komanim.gif' style='display:none' width='32' height='32'>
      <img id='furikomafu3' src='image/komafu.png' style='display:none' width='32' height='32'>
      <img id='furikomato3' src='image/komato.png' style='display:none' width='32' height='32'>
      <img id='furikomanim4' src='image/komanim.gif' style='display:none' width='32' height='32'>
      <img id='furikomafu4' src='image/komafu.png' style='display:none' width='32' height='32'>
      <img id='furikomato4' src='image/komato.png' style='display:none' width='32' height='32'>
      <img id='furikomanim5' src='image/komanim.gif' style='display:none' width='32' height='32'>
      <img id='furikomafu5' src='image/komafu.png' style='display:none' width='32' height='32'>
      <img id='furikomato5' src='image/komato.png' style='display:none' width='32' height='32'>
      </div>
      TAIKYOKU_BTN
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  def show(userinfo)
    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    reqdb = TaikyokuReqFile.new
    reqdb.read

    put_userinlounge(reqdb, userinfo.user_id)

    if reqdb.exist_id(userinfo.user_id)
      put_canceling_button
    else
      put_filing_button
    end

    CommonUI.html_foot
  end
end
