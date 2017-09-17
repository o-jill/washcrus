# -*- encoding: utf-8 -*-

# Sfenを保存するファイル管理クラス
class SfenStore
  # DIRPATH = './taikyoku/'.freeze
  # STOREFILE = '/sfenlog.txt'.freeze

  def initialize(sfenpath)
    @path = sfenpath # DIRPATH + @id + STOREFILE
  end

  attr_reader :path

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
end
