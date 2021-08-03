# frozen_string_literal: true

require 'selenium-webdriver'
require 'yaml'

require './travisci/browsertestabs.rb'
require './file/pathlist.rb'

#
# play a game automatically with a kifu.
#
class TestGame < BrowserTestAbstract
  # 初期化
  def initialize
    super
  end

  attr_reader :color, :driver, :gid, :nmsen, :nmgo, :emlsen, :emlgo, \
              :pwsen, :pwgo, :moves, :special, :resultsfen

  # 対局情報のセット
  def setgame(hash)
    @gid = hash
    swap_ply if checksengo
  end

  # 先後がどっちなのかチェックする
  def checksengo
    path = "taikyoku/#{gid}/matchinfo.txt"
    data = YAML.load_file(path)

    @gid = data[:gid]
    return puts "@gid:#{gid} is wrong." unless gid

    # puts "swap?:#{data[:playerb]} != #{@nmsen}"
    data[:playerb] != nmsen
  end

  # 先手と後手の情報を入れ替える
  def swap_ply
    t = nmsen
    @nmsen = nmgo
    @nmgo = t

    t = emlsen
    @emlsen = emlgo
    @emlgo = t

    t = pwsen
    @pwsen = pwgo
    @pwgo = t
  end

  # 先手情報のセット
  #
  # @param name 名前
  # @param eml メールアドレス
  # @param pwd パスワード
  def setplayersen(name, eml, pwd)
    @nmsen = name
    @emlsen = eml
    @pwsen = pwd
  end

  # 後手情報のセット
  #
  # @param name 名前
  # @param eml メールアドレス
  # @param pwd パスワード
  def setplayergo(name, eml, pwd)
    @nmgo = name
    @emlgo = eml
    @pwgo = pwd
  end

  # 棋譜を使いやすい形に整形
  def reshapemoves
    @moves = moves.map.each do |te|
      te['move']
    end
    @moves.compact!
    # puts @moves
  end

  # 棋譜の読み込み
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

  # 先手としてログイン
  def becomesente
    checklogin(emlsen, pwsen)
  end

  # 後手としてログイン
  def becomegote
    checklogin(emlgo, pwgo)
  end

  # ログアウトする
  def logout
    driver.navigate.to BASE_URL + 'index.rb?logout'
  end

  # 対局ページに移動
  def gogame
    driver.navigate.to BASE_URL + "index.rb?game/#{gid}"
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

  # 移動確認ダイアログのボタンをクリックする
  #
  # @param okcan ボタンのID。'ok' or 'cancel'
  def confirmmove(okcan = 'ok')
    eid = 'mvcfm_' + okcan
    driver.find_element(:id, eid).click
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
    if clr.zero?
      becomesente
    else
      becomegote
    end

    gogame

    resignbtn
    confirmmove('ok')
  end

  # 最後の局面のチェック
  def checklastsfen
    path = "taikyoku/#{gid}/matchinfo.txt"
    data = YAML.load_file(path)

    sfen = data[:sfen]
    @turn = data[:turn]
    puts "#{sfen == resultsfen} := #{sfen} == #{resultsfen}"
    res.succfail(sfen == resultsfen)
  end

  # usage:
  # lock do
  #   do_something
  # end
  def lock(*)
    Timeout.timeout(10) do
      File.open(@lockfn, 'w') do |file|
        begin
          file.flock(File::LOCK_EX)
          yield
        ensure
          file.flock(File::LOCK_UN)
        end
      end
    end
  rescue Timeout::Error
    raise AccessDenied.new('timeout')
  end

  # 対局ファイルのチェック
  def checktaikyokulines(file)
    file.each_line do |line|
      # next if line =~ /^#/ # comment
      # id, idv, idw, nameb, namew, turn, time, comment
      next unless line.start_with?(gid + ',')
      elem = line.chomp.split(',')
      ret = !%w[b w].include?(elem[5])
      puts "ret = !%w[b w].include?(#{elem[5]})" unless ret
      return res.succfail(ret)
    end
    false # 見つからなかった
  end

  # 対局ファイルのチェック
  def checktaikyokucsv
    @lockfn = PathList::TAIKYOKULOCKFILE
    lock do
      path = 'db/taikyoku.csv'
      File.open(path, 'r:utf-8') do |file|
        # file.flock File::LOCK_EX
        return checktaikyokulines(file)
      end
      puts "could not find game:#{gid}"
      res.succfail(false)
    end
  end

  # 対局中ファイルのチェック 本体
  def checktaikyokuchucsvmain
    path = 'db/taikyokuchu.csv'
    File.open(path, 'r:utf-8') do |file|
      # file.flock File::LOCK_EX
      file.each_line do |line|
        next if line.empty?
        # id, idv, idw, nameb, namew, turn, time, comment
        ret = line.start_with?(gid + ',')
        puts "'#{line}'.start_with?(#{gid + ','})" if ret
        return false if ret
      end
    end
    puts 'removed from taikyokuchu successfully.'
    true
  end

  # 対局中ファイルのチェック
  def checktaikyokuchucsv
    @lockfn = PathList::TAIKYOKUCHULOCKFILE
    lock do
      res.succfail(checktaikyokuchucsvmain)
    end
  end

  # コマを動かす。
  #
  # @param from 移動元の座標
  # @param to   移動先の座標
  def move_a_piece(from, to)
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
  def li_move_a_piece
    ret = prcs_sengo(@from, @to)

    gogame

    move_a_piece(ret[:from], ret[:to])

    sleep 3
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
    moves.each do |tee|
      puts "tee:#{tee}"

      readmove(tee)

      li_move_a_piece
    end
  rescue StandardError => er
    puts "ERROR in move_with_kifu: class=[#{er.class}] message=[#{er.message}]"
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
