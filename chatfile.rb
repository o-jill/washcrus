#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

# チャットファイル管理クラス
class ChatFile
  DIRPATH = './taikyoku/'
  CHATFILE = 'chat.txt'
  def initialize(id)
    @id = id;
    @path = DIRPATH + @id + CHATFILE
  end

  def read
     File.open(@path, 'r:utf-8') do |file|
      file.flock File::LOCK_EX

      @msg = file.read
      # 例外は小さい単位で捕捉する
      rescue SystemCallError => e
        puts "class=[#{e.class}] message=[#{e.message}] in read"
      rescue IOError => e
        puts "class=[#{e.class}] message=[#{e.message}] in read"
    end
  end

  def write
    File.oprn(@path, 'w') do
      file.flock File::LOCK_EX
      file.puts @msg
      # 例外は小さい単位で捕捉する
      rescue SystemCallError => e
        puts "class=[#{e.class}] message=[#{e.message}] in write"
      rescue IOError => e
        puts "class=[#{e.class}] message=[#{e.message}] in write"
    end
  end

  def say(name, msg)
    line <<-MSG_LINE
<B>#{name}</B>:#{msg}&nbsp;()
MSG_LINE
  end

  def put
  end
end
