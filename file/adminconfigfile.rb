# -*- encoding: utf-8 -*-

require './file/pathlist.rb'

# Admin登録ファイル管理クラス
class AdminConfigFile
  # 初期化
  def initialize
    @path = PathList::ADMINCONFIGFILE
    @idlist = []
  end

  attr_reader :path, :idlist

  # IDが含まれるか確認
  #
  # @param id ユーザーID
  # @return IDが含まれるときtrue
  def exist?(id)
    @idlist.include?(id)
  end

  # ファイルの読み込み
  #
  # @param fpath ファイルパス
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

  # ファイルの書き込み
  #
  # @param fpath ファイルパス
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

  # ファイルの追加書き込み
  #
  # @param newid 追加するID
  # @param fpath ファイルパス
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
