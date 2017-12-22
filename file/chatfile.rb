# -*- encoding: utf-8 -*-

require './file/pathlist.rb'

# チャットファイル管理クラス
class ChatFile
  ERRMSG = 'ERROR:read a file at first...'.freeze

  # 初期化
  #
  # @param id 対局ID
  def initialize(id)
    @id = id
    @path = PathList::TAIKYOKUDIR + @id + '/' + PathList::CHATFILE
    @msg = ERRMSG
  end

  attr_reader :id, :path, :msg

  # ファイルの読み込み
  #
  # @param fpath ファイルパス
  def read(fpath = path)
    File.open(fpath, 'r:utf-8') do |file|
      file.flock File::LOCK_EX
      @msg = file.read
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in read"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in read"
  end

  # ファイルの書き出し
  #
  # @param fpath ファイルパス
  def write(fpath = path)
    File.open(fpath, 'w') do |file|
      file.flock File::LOCK_EX
      file.puts msg
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  end

  # ファイルの1行追加書き出し
  #
  # @param line  1行分の文字列
  # @param fpath ファイルパス
  def add(line, fpath = path)
    File.open(fpath, 'a') do |file|
      file.flock File::LOCK_EX
      file.puts line
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  end

  # 発言する
  #
  # @param name 名前
  # @param mssg 発言内容
  def say(name, mssg)
    add "<B>#{name}</B>:#{mssg}&nbsp;(#{Time.now})<BR>"
  end

  # 発言する
  #
  # @param name 名前
  # @param mssg 発言内容
  def sayex(name, mssg)
    add "#{name}:#{mssg}&nbsp;(#{Time.now})<BR>"
  end

  # 対局開始の合図
  #
  # @param name 先手名
  def say_start(name)
    sayex("<span id='chatadmin'>Witness</span>",
          "it's on time. please start your move as SENTE, #{name}-san.")
  end

  # チャット内容の出力
  def put
    print "Content-type:text/html;\n\n#{msg}"
  end
end
