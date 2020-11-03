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
    msg_tmpl = [
      '後手がいいです。',
      '先手がいいです。',
      '強い人はカンベン。',
      'どなたでも歓迎！',
      '振り駒バッチ来い',
      'よろしくお願いします。'
    ]
    puts <<-FILING_BUTTON_CMT.unindent
      <hr>
      <div align='center'>
       <div id='filing_btn' class='btn_filing_lounge'>
        <input type='text' list='cmt_tmpl' id='cmt' class='inpform' placeholder='コメント欄'></input>
        <datalist id='cmt_tmpl'>
    FILING_BUTTON_CMT
    msg_tmpl.each do |msg|
      puts "<option value='#{msg}'>"
    end
    puts <<-FILING_BUTTON_BTN.unindent
        </datalist>
        <button id='btn_f2l' class='inpform' onclick='file2lounge();'>対局待ちに登録</button>
        <br><span id='msg_l2f'></span>
       </div>
      </div>
    FILING_BUTTON_BTN
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

  # 対局待ちフォームの出力
  def put_userinlounge_head
    scriptname = File.basename($PROGRAM_NAME)

    puts <<-TAIKYOKU_LOUNGE.unindent
      <script type='text/javascript' src='./js/lounge.js'></script>
      <style>
      input.bigradio {
        transform: scale(2);
        margin: 10px 10px;
        /* width: 2em; */
        /* height: 2em; */
      }
      </style>
      <div align='center'>
       <div class='btn_filing_lounge'>
        <form action='#{scriptname}?gennewgame3' method='post' name='gennewgame'>
    TAIKYOKU_LOUNGE
  end

  # 対局開始UIの表示
  USERINLOUNGE_BOTTOM = <<-EO_USERINLOUNGE_BTM.unindent
    対戦相手は「<span id='opponentname'>(対戦相手を選んでください)</span>」です。<BR>
    <select class='inpform' name='sengo' id='sengo'>
     <option value='0'>振り駒で</option>
     <option value='1'>自分が先手で</option>
     <option value='2'>自分が後手で</option>
    </select>
    <input type='hidden' id='furigoma' name='furigoma' value='FTFTF' class='inpform'>
    <button id='btn_gen' class='inpform' onclick='return onstart()' disabled>Start!</button>
    </form>
  EO_USERINLOUNGE_BTM

  # 対局待ちユーザーの表示
  def put_userinlounge(reqdb, uid)
    put_userinlounge_head

    reqdb.to_html('対局待ちユーザー', uid)

    puts USERINLOUNGE_BOTTOM

    sz_and_style = "style='display:none' width='32' height='32'"
    (1..5).each do |i|
      puts <<-KOMAIMG.unindent
        <img id='furikomanim#{i}' src='image/komanim.gif' #{sz_and_style}>
        <img id='furikomafu#{i}' src='image/komafu.png' #{sz_and_style}>
        <img id='furikomato#{i}' src='image/komato.png' #{sz_and_style}>
      KOMAIMG
    end
    puts '</div></div>'
  end

  # チャット領域の表示
  #
  # @param uname ユーザー名
  def put_chatarea(uname)
    puts <<-CHAT_AREA
      <hr><div id='chatlog' class='chat'>チャットえりあ</div>
      <input id='chatname' type='text' value='#{uname}' class='chatnm' readonly/>
      : <input id='chatmsg' list='chatmsg_tmpl' type='text' class='chatmsg' placeholder='チャットメッセージ欄'/>
      <datalist id='chatmsg_tmpl'>
       <option value='よろしくお願いします。'>
       <option value='おはようございます。'>
       <option value='こんにちは。'>
       <option value='こんばんわ。'>
       <option value='ありがとうございました。'>
      </datalist>
      <input type='button' class='chatbtn' id='chatbtn' onClick='onChatSay();' value='&gt;&gt;'/>
      <input type='hidden' id='gameid' value='lounge'/>
      <script type='text/javascript' src='./js/chat.v014.js' defer></script>
    CHAT_AREA
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

    put_chatarea(userinfo.user_name)

    CommonUI.html_foot
  end
end
