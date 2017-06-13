#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

# チャットファイル管理クラス
class ChatFile
  DIRPATH = './taikyoku/'.freeze
  CHATFILE = 'chat.txt'.freeze

  def initialize(id)
    @id = id
    @path = DIRPATH + @id + '/' + CHATFILE
  end

  def read
    File.open(@path, 'r:utf-8') do |file|
      file.flock File::LOCK_EX
      @msg = file.read
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in read"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in read"
  end

  def write
    File.open(@path, 'w') do |file|
      file.flock File::LOCK_EX
      file.puts @msg
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  def add(line)
    begin
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

  def say(name, msg)
    add "<B>#{name}</B>:#{msg}&nbsp;(#{Time.now})"
  end

  def sayex(name, msg)
    add "#{name}:#{msg}&nbsp;(#{Time.now})"
  end

  def put
    print "Content-type:text/html;\n\n#{@msg}"
  end
end
