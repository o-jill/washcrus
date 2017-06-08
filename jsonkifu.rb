#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'json'
require 'jkf'
require './taikyokudata.rb'

#
# JSON棋譜管理クラス
#
# refer:https://github.com/na2hiro/json-kifu-format
#
class JsonKifu
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
    @initial = { preset: 'HIRATE' }
    @moves = [{ comments: [] }]
  end

  attr_reader :header, :moves, :initial

  def setid(tid, rid = nil)
    @header['対局ID'] = tid
    @header['記録ID'] = rid unless rid.nil?
  end

  def setheader(key, val)
    @header[key] = val
  end

  def setplayers(b, w)
    @header['先手'] = b
    @header['後手'] = w
  end

  def setdate(start, finish = '')
    @header['開始日時'] = start
    @header['終了日時'] = finish
  end

  def zerotime
    { 'now': { 'm': 0, 's': 0 }, 'total': { 'h': 0, 'm': 0, 's': 0 } }
  end

  def move(mv, tm = nil, cmt = nil)
    data = { 'move': mv }
    data['time'] = tm unless tm.nil?
    data['comments'] = cmt unless cmt.nil?
    @moves << data
  end

  def spmove(tm, mv = nil, cmt = nil)
    data = { 'special': mv }
    data['time'] = tm unless tm.nil?
    data['comments'] = cmt unless cmt.nil?
    @moves << data
  end

  def addcomment(nth, cmt)
    @moves[nth]['comments'] << cmt
  end

  def genjson
    { 'header' => header, 'initial' => initial, 'moves' => moves }
  end

  def read(path)
    File.open(path, 'r:utf-8') do |file|
      data = JSON.load(file)

      @header = data['header']
      @moves = data['moves']
      @initial = data['initial']
    end
  end

  def initial_write(td)
    setplayers(td.player1, td.player2)
    setdate(td.datetime)
    write(td.kifupath)
  end

  def write(path)
    File.open(path, 'w') do |file|
      file.puts JSON.pretty_generate(genjson)
    end
  end

  def to_csa
    Jkf::Converter::Csa.new.convert(genjson)
  end

  def to_kif
    # genjson.to_s
    return Jkf::Converter::Kif.new.convert(genjson)
  end

  def to_ki2
    Jkf::Converter::Ki2.new.convert(genjson)
  end
end
