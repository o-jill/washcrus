# frozen_string_literal: true

require 'selenium-webdriver'
require 'yaml'

require './file/mylock.rb'
require './file/pathlist.rb'
require './travisci/testgameabs.rb'

#
# play a game automatically with a kifu.
#
class TestGame < TestGameAbstract
  # 初期化
  def initialize
    super
  end

  attr_reader :color, :moves, :special, :resultsfen

  # 棋譜を使いやすい形に整形
  def reshapemoves
    @moves = moves.map.each do |te|
      te['move']
    end
    @moves.compact!
    # puts @moves
  end

  # 棋譜の読み込み
  #
  # @param path 棋譜のパス
  def read(path)
    File.open(path, 'r:utf-8') do |file|
      data = JSON.parse(file.read)
      @header = data['header']
      @moves = data['moves']
      @initial = data['initial']
      @resultsfen = data['result']
      @special = moves.last['special']
    end
    reshapemoves
  end

  # 対局ページ経由でloginできることの確認用ログイン
  #
  # @param email メールアドレス
  # @param pwd パスワード
  def checklogin_viagame(email, pwd)
    driver.find_element(:name, 'siemail').send_keys(email)
    elem = driver.find_element(:name, 'sipassword')
    elem.send_keys pwd
    sleep 0.5
    elem.submit
    sleep 1.3
    simpleurlcheck('index.rb?logincheck')
    res.checkmatch(/Logged in successfully/)
  end

  # 対局ページに移動
  def gogame_wo_login(sente)
    gogame
    sleep 1
    # login
    sente ? checklogin_viagame(emlsen, pwsen) : checklogin_viagame(emlgo, pwgo)

    # wait jumping
    sleep 4
  end

  # 移動元のマスをクリックする
  #
  # @param sujidan 移動元の座標
  def touch(sujidan)
    driver.find_element(:id, "b#{sujidan['x']}#{sujidan['y']}").click
  end

  # 移動先のマスをクリックする
  #
  # @param sujidan 移動先の座標
  def move(sujidan)
    driver.find_element(:id, "b#{sujidan['x']}#{sujidan['y']}").click
  end

  # 成りダイアログのボタンをクリックする
  #
  # @param bnaru true:成る, false:成らず
  def naru(bnaru)
    eid = bnaru ? 'naru' : 'narazu'
    driver.find_element(:id, eid).click
  end

  # 打つ（持つだけ）
  #
  # @param str CSA駒タイプ
  def utu_motu(str)
    driver.find_element(:id, {
      FU: 'sg_fu_img',
      KY: 'sg_kyo_img',
      KE: 'sg_kei_img',
      GI: 'sg_gin_img',
      KI: 'sg_kin_img',
      KA: 'sg_kaku_img',
      HI: 'sg_hisha_img'
    }[str.to_sym]).click
  end

  # 強制成りかどうか
  #
  # @param piece 動かす駒
  # @param yfrm 移動元のy座標
  def mustpromote?(piece, yfrm)
    yfrm == 2 && piece == 'FU' || yfrm == 2 && piece == 'KY' \
      || yfrm <= 4 && piece == 'KE'
  end

  # 成りダイアログの処理
  #
  # @param prmt nil:don't care or true:promote or false:no-promote
  # @param piece 動かす駒
  # @param yfrm 移動元のy座標
  def promotedlg?(prmt, piece, yfrm)
    return false if prmt.nil?

    !mustpromote?(piece, yfrm)
  end

  # 投了ボタンをクリックする。
  def resignbtn
    driver.find_element(:id, 'btn_resign').click
  end

  # 投了する
  #
  # @param clr 0:先, 1:後
  def resign(clr)
    sleep 5 # wait logout
    gogame_wo_login(clr.zero?) # login here
    res.checkurl(BASE_URL + "index.rb?game/#{gid}")
    sleep 0.5
    resignbtn
    sleep 0.5
    confirmmove('ok')
    sleep 3
  end

  # 最後の局面のチェック
  def checklastsfen
    # path = "taikyoku/#{gid}/matchinfo.txt"
    data = YAML.load_file("taikyoku/#{gid}/matchinfo.txt")

    sfen = data[:sfen]
    @turn = data[:turn]
    puts "#{sfen == resultsfen} := #{sfen} == #{resultsfen}"
    res.succfail(sfen == resultsfen)
  end

  def lastmove
    driver.find_element(:id, 'lastmove').attribute(:value)
  end

  def checklastmove(txt)
    sleep 0.1
    lastmove != txt
  rescue Selenium::WebDriver::Error::NoSuchElementError => e
    puts e
    false
  end

  # コマを動かす。
  #
  # @param from 移動元の座標
  # @param to   移動先の座標
  def move_a_piece(from, to)
    sfen = lastmove
    if from
      touch(from)
      move(to)
      confirmmove('ok')
      naru(@prmt) if promotedlg?(@prmt, @piece, from['y'])
    else
      utu_motu(@piece)
      move(to)
      confirmmove('ok')
    end

    sleep 1
    @wait.until { checklastmove(sfen) }
  end

  # ひふみんアイ用の座標変換
  #
  # @param frm 移動元の座標
  # @param too  移動先の座標
  def cvtxy(frm, too)
    from = {}
    if frm
      from['x'] = 10 - frm['x']
      from['y'] = 10 - frm['y']
    else
      from = frm
    end
    to = {}
    to['x'] = 10 - too['x']
    to['y'] = 10 - too['y']

    { from: from, to: to }
  end

  # 先手または後手でログインして１手準備
  #
  # @param from 移動元の座標
  # @param to   移動先の座標
  def prcs_sengo(from, to)
    if color.zero?
      becomesente
      { from: from, to: to }
    else
      becomegote
      cvtxy(from, to)
    end
  end

  # 1手指す
  def li_move_a_piece(nth)
    ret = prcs_sengo(@from, @to)

    gogame
    gamechat(GREETING[nth]) if nth < 2
    sleep 0.5
    move_a_piece(ret[:from], ret[:to])

    logout
  end

  # １手分の指し手情報の読み取り
  #
  # @param tee 指し手情報
  def readmove(tee)
    @from = tee['from']
    @to = tee['to'] if tee['to']
    @prmt = tee['promote']
    @piece = tee['piece']
    @color = tee['color']

    # puts "#{@color}#{@piece}:#{@from}->#{@to},#{@prmt}" if tee['same']
  end

  # 棋譜に従って指す。
  def move_with_kifu
    moves.each_with_index do |tee, nth|
      puts "tee#{nth}:#{tee}"

      readmove(tee)

      li_move_a_piece(nth)
    end
  rescue StandardError => e
    puts "ERROR in move_with_kifu: class=[#{e.class}] message=[#{e.message}]"
  end

  # 指したりチェックしたり
  def run
    move_with_kifu
    resign(1 - moves.last['color']) if special == 'TORYO'
    logout
    # ブラウザを終了させる
    # driver.quit

    checklastsfen
    checktaikyokuchucsv
    checktaikyokucsv
  end
end
