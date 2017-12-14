# -*- encoding: utf-8 -*-

require 'rubygems'
require 'json'
require 'jkf'
require 'logger'

require './file/jsonmove.rb'

#
# JSON棋譜管理クラス
#
# refer:https://github.com/na2hiro/json-kifu-format
#
class JsonKifu
  # 初期化
  #
  # @param tid 対局ID
  def initialize(tid)
    @header =
      {
        '対局ID' => tid, # '記録ID' => '',
        '開始日時' => '2014/09/02 10:00', # '終了日時' => '2014/09/02 21:47',
        # 表題: '竜王戦', 棋戦: '第２７期竜王戦挑戦者決定三番勝負　第２局',
        # 持ち時間: '各５時間', 消費時間: '117▲268△283',
        # 場所: '東京・将棋会館', 図: '投了', 手合割: '平手　　',
        '先手' => '羽生善治', '後手' => '糸谷哲郎'
      }
    @initial = { 'preset' => 'HIRATE' }
    @moves = [{ 'comments' => [] }]
    @log = nil
  end

  attr_reader :header, :moves, :initial

  # logging
  attr_accessor :log

  # 対局IDと記録IDのセット
  #
  # @param tid 対局ID
  # @param rid 記録ID
  def setid(tid, rid = nil)
    @header['対局ID'] = tid
    @header['記録ID'] = rid unless rid.nil?
  end

  # カスタムヘッダの追加
  #
  # @param key 項目名文字列
  # @param val 設定値
  def setheader(key, val)
    @header[key] = val
  end

  # 対局者の名前をセット
  #
  # @param b 先手
  # @param w 後手
  def setplayers(b, w)
    @header['先手'] = b
    @header['後手'] = w
  end

  # 開始日時と終了日時のセット
  #
  # @param start  開始日時
  # @param finish 終了日時
  def setdate(start, finish = '')
    @header['開始日時'] = start
    @header['終了日時'] = finish
  end

  # 終了日時のセット
  #
  # @param finish 終了日時
  def setfinishdate(finish)
    @header['終了日時'] = finish
  end

  # 前回のまでの消費時間
  #
  # @return 前回のまでの消費時間。初手の時はnil。
  def last_time
    @moves[-2]['time'] if @moves[-2]
  end

  # ゼロ消費時間を返す
  # @return ゼロ消費時間を返す
  def zerotime
    {
      'now' => { 'm' => 0, 's' => 0 },
      'total' => { 'h' => 0, 'm' => 0, 's' => 0 }
    }
  end

  # 同xxかどうかの確認
  #
  # @param a 着手
  # @return 同xxのときtrue
  def checkdou(a)
    lt = @moves[-1]['move']
    return false if lt.nil?
    lt['to'] == a['to']
  end

  # 駒の移動の反映
  #
  # @param mv  指し手
  # @param tm  消費時間
  # @param cmt コメント
  def movehash(mv, tm)
    # @log.debug("mv.checkdou if $#{@moves[-1]['move'].to_s}$")
    mv['same'] = true if checkdou(mv)

    # @log.debug("data = { 'move' => mv }")
    data = { 'move' => mv }

    # @log.debug("data['time'] = tm || zerotime")
    data['time'] = tm || zerotime

    data
  end

  # 駒の移動の反映
  #
  # @param mv  指し手
  # @param tm  消費時間
  # @param cmt コメント
  def move(mv, tm = nil, cmt = nil)
    # @log.debug("if mv[:special]")
    data =
      if mv[:special] || mv['special']
        mv
      else
        movehash(mv, tm)
      end
    # @log.debug("data['comments'] = cmt unless cmt.nil?")
    data['comments'] = cmt unless cmt.nil?
    @moves << data
  end

  # 投了
  def resign
    move(JsonMove.fromtext('%TORYO'))
  end

  # コメントの追加
  #
  # @param nth 何手目に追加するか
  # @param cmt コメント文
  def addcomment(nth, cmt)
    @moves[nth]['comments'] << cmt
  end

  # JSON用にハッシュオブジェクトを生成
  #
  # @return { 'header' => header, 'initial' => initial, 'moves' => moves }
  def genjson
    { 'header' => header, 'initial' => initial, 'moves' => moves }
  end

  # ファイルの読み込み
  #
  # @param path ファイルパス
  def read(path)
    File.open(path, 'r:utf-8') do |file|
      data = JSON.parse(file.read)
      @header = data['header']
      @moves = data['moves']
      @initial = data['initial']
    end
  rescue
    return nil
  end

  # 初期値の書き出し
  #
  # @param pl1 先手
  # @param pl2 後手
  # @param cdt 開始日時
  # @param path ファイルパス
  def initial_write(pl1, pl2, cdt, path)
    setplayers(pl1, pl2)
    setdate(cdt)
    write(path)
  end

  # ファイルに書き出し
  #
  # @param path ファイルパス
  def write(path)
    File.open(path, 'w') do |file|
      file.puts JSON.pretty_generate(genjson)
    end
  end

  # csa形式文字列に変換
  def to_csa
    Jkf::Converter::Csa.new.convert(genjson)
  end

  # kif形式文字列に変換
  def to_kif
    to_kifu.encode('Shift_JIS')
  end

  # kif形式文字列に変換
  def to_kifu
    Jkf::Converter::Kif.new.convert(genjson)
  end

  # ki2形式文字列に変換
  def to_ki2
    Jkf::Converter::Ki2.new.convert(genjson)
  end
end
