# -*- encoding: utf-8 -*-

# Admin登録ファイル管理クラス
class AdminConfigFile
  def initialize(fpath = './db/adminconfig.txt')
    @path = fpath
    @idlist = []
  end

  attr_reader :path, :idlist

  def exist?(id)
    @idlist.include?(id)
  end

  def read(fpath = @path)
    File.open(fpath, 'r:utf-8') do |file|
      file.flock File::LOCK_EX
      @idlist = []
      file.each_line do |line|
        @idlist << line.chomp
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in read"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in read"
  end

  def write(fpath = @path)
    File.open(fpath, 'w') do |file|
      file.flock File::LOCK_EX
      @idlist.each do |id|
        file.puts id
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  def add(newid, fpath = @path)
    @idlist << newid

    File.open(fpath, 'a') do |file|
      file.flock File::LOCK_EX
      file.puts newid
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end
end
