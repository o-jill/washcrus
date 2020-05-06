# -*- encoding: utf-8 -*-

# Sfenを保存するファイル管理クラス
class SfenStore
  # DIRPATH = './taikyoku/'.freeze
  # STOREFILE = '/sfenlog.txt'.freeze

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
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  end

  # 千日手かどうか
  #
  # @param line 最新局面
  def sennichite?(line)
    File.open(@path, 'r') do |file|
      file.flock File::LOCK_EX
      file.each_line do |l|
        count[l] = count[l] || 1;
        count[l] = count[l] + 1;
      end
    end
    count[line] >= 4
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  end
end
