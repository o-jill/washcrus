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
    @header['記録ID'] = rid if rid
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
  # @param nmb 先手
  # @param nmw 後手
  def setplayers(nmb, nmw)
    @header['先手'] = nmb
    @header['後手'] = nmw
  end

  # 開始日時と終了日時のセット
  #
  # @param start  開始日時
  # @param finish 終了日時
  def setdate(start, finish = '')
    @header['開始日時'] = start
    @header['終了日時'] = finish
  end

  # 戦後に同じものを設定する
  #
  # @param type 先手後手に続ける文字
  # @param val 設定する値
  def setbothsengo(type, val)
    @header['先手' + type] = val
    @header['後手' + type] = val
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
  # @param mov 着手
  #
  # @return 同xxのときtrue
  def checkdou(mov)
    lt = @moves[-1]['move']
    return false unless lt
    lt['to'] == mov['to']
  end

  # 駒の移動の反映
  #
  # @param mv  指し手
  # @param tim  消費時間
  #
  # @return { 'move':, 'time': }
  def movehash(mov, tim)
    # @log.debug("mov.checkdou if $#{@moves[-1]['move'].to_s}$")
    mov['same'] = true if checkdou(mv)

    # @log.debug("data = { 'move' => mov }")
    data = { 'move' => mov }

    # @log.debug("data['time'] = tim || zerotime")
    data['time'] = tim || zerotime

    data
  end

  # 駒の移動の反映
  #
  # @param mov  指し手
  # @param tim  消費時間
  # @param cmt コメント
  def move(mov, tim = nil, cmt = nil)
    # @log.debug("if mov[:special]")
    data =
      if mov[:special] || mov['special']
        mov
      else
        movehash(mov, tim)
      end
    # @log.debug("data['comments'] = cmt unless cmt.nil?")
    data['comments'] = cmt if cmt
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
    nil
  end

  # 初期値の書き出し
  #
  # @param plb 先手
  # @param plw 後手
  # @param cdt 開始日時
  # @param path ファイルパス
  def initial_write(plb, plw, cdt, path)
    setplayers(plb, plw)
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
