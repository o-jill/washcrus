#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

# チャットファイル管理クラス
class ChatFile
  DIRPATH = './taikyoku/'.freeze
  CHATFILE = '/chat.txt'.freeze
  ERRMSG = 'ERROR:read a file at first...'.freeze

  def initialize(id)
    @id = id
    @path = DIRPATH + @id + CHATFILE
    @msg = ERRMSG
  end

  attr_reader :id, :path, :msg

  def read(fpath = path)
    File.open(fpath, 'r:utf-8') do |file|
      file.flock File::LOCK_EX
      @msg = file.read
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in read"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in read"
  end

  def write(fpath = path)
    File.open(fpath, 'w') do |file|
      file.flock File::LOCK_EX
      file.puts msg
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  def add(line, fpath = path)
    begin
      File.open(fpath, 'a') do |file|
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

  def say(name, mssg)
    add "<B>#{name}</B>:#{mssg}&nbsp;(#{Time.now})<BR>"
  end

  def sayex(name, mssg)
    add "#{name}:#{mssg}&nbsp;(#{Time.now})<BR>"
  end

  def put
    print "Content-type:text/html;\n\n#{msg}"
  end
end
