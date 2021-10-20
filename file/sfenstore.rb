# -*- encoding: utf-8 -*-
# frozen_string_literal: true

# Sfenを保存するファイル管理クラス
class SfenStore
  # DIRPATH = './taikyoku/'
  # STOREFILE = '/sfenlog.txt'

  # 初期化
  #
  # @param sfenpath ファイルパス
  def initialize(sfenpath)
    @path = sfenpath # DIRPATH + @id + STOREFILE
  end

  attr_reader :path

  # 1行出力
  #
  # @param line 出力データ
  def add(line)
    File.open(@path, 'a') do |file|
      file.flock File::LOCK_EX
      file.puts line
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  # 千日手かどうか
  #
  # @param line 最新局面
  def sennichite?(line)
    count = {}
    File.open(@path, 'r') do |file|
      file.flock File::LOCK_EX
      file.each_line do |ln|
        /([^ ]+ ){3}/ =~ ln
        kykm = $&
        cnt = count[kykm] || 0
        count[kykm] = cnt + 1
      end
    end
    # p count
    /([^ ]+ ){3}/ =~ line
    count[$&] >= 4
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end
end
