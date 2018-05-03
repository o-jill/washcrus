# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'time'
require 'timeout'
require 'unindent'

require './file/pathlist.rb'
require './util/myerror.rb'

#
# 対局希望情報DB管理クラス
#
class TaikyokuReqFile
  # 初期化
  #
  # @param name   データベースファイルのパス
  # @param lockfn 同期用ファイルのパス
  def initialize(name = PathList::TAIKYOKUREQFILE,
                 lockfn = PathList::TAIKYOKUREQLOCKFILE)
    @fname = name
    @lockfn = lockfn
    @names = {}
    @comments = {}
  end

  # usage:
  # lock do
  #   do_something
  # end
  def lock(*)
    Timeout.timeout(10) do
      File.open(@lockfn, 'w') do |file|
        begin
          file.flock(File::LOCK_EX)
          yield
        ensure
          file.flock(File::LOCK_UN)
        end
      end
    end
  rescue Timeout::Error
    raise AccessDenied.new('timeout')
  end

  # read a line
  #
  # @param line 1行分
  def read_element(line)
    # comment
    return if line =~ /^#/

    # id, name, comment
    elem = line.chomp.split(',')
    id = elem[0]
    @names[id] = elem[1]
    @comments[id] = elem[2]
  end

  # ファイルの読み込み
  def read
    File.open(@fname, 'r:utf-8') do |file|
      file.flock File::LOCK_EX

      file.each_line do |line|
        read_element(line)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in read"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in read"
  end

  # ファイルのヘッダのコメント文の生成
  #
  # @param file Fileオブジェクト
  def self.put_header(file)
    file.puts "# taikyoku request #{Time.now}\n# id, name, comment"
  end

  # ファイルへの書き出し
  def write
    File.open(@fname, 'w') do |file|
      file.flock File::LOCK_EX
      TaikyokuReqFile.put_header(file)
      @names.each do |id, name|
        file.puts "#{id},#{name},#{@comments[id]}"
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  end

  # ファイルへの追加書き出し
  #
  # @param id 対局ID
  def append(id)
    File.open(@fname, 'a') do |file|
      file.flock File::LOCK_EX
      file.puts "#{id},#{@names[id]},#{@comments[id]}"
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  end

  # ユーザの追加
  #
  # @param id ユーザーID
  # @param name ユーザー名
  # @param cmt コメント
  def add(id, name, cmt)
    @names[id] = name
    @comments[id] = cmt
  end

  # remove request information
  #
  # @param id ユーザーID
  def remove(id)
    @names.delete(id)
    @comments.delete(id)
  end

  # remove 2 users and update a file.
  #
  # @param ida ユーザーAID
  # @param idb ユーザーBID
  # @return ユーザーBがリストにないときfalse
  def bonvoyage(ida, idb)
    lock do
      read

      return false unless exist_id(idb)

      remove(ida)
      remove(idb)

      write
    end

    true
  end

  # ユーザーを登録する
  #
  # @param uid ユーザーID
  # @param uname ユーザー名
  # @param cmt コメント
  # @return 成功すればtrue
  def fileauser(uid, uname, cmt)
    lock do
      read
      return false if exist_id(uid)

      add(uid, uname, cmt)
      append(uid)
    end

    true
  end

  # ユーザーを登録から外す
  #
  # @param uid ユーザーID
  # @return 成功すればtrue
  def cancelauser(uid)
    lock do
      read
      return false unless exist_id(uid)
      remove(uid)
      write
    end
    true
  end

  # duplication check
  #
  # @param id ユーザーID
  # @return true if nid exists.
  def exist_id(nid)
    @names.key?(nid)
  end

  # duplication check
  #
  # @param name ユーザー名
  # @return true if nm exists.
  def exist_name(name)
    @names.value?(name)
  end

  # get request information about a user
  #
  # @param id ユーザーID
  # @return { id:, name:, comments: }
  def probe(id)
    { id: id, name: @names[id], comments: @comments[id] }
  end

  # get request information by id
  #
  # @param id ユーザーID
  # @return nil or probe(id)
  def findid(id)
    probe(id) if exist_id(id)
  end

  # get request information by name
  #
  # @param name 対局者名
  # @return nil or probe(id)
  def findname(name)
    probe(id) if exist_name(name)
  end

  # HTML形式(TABLE)に変換して出力
  #
  # @param title テーブルのキャプション
  # @param myid 出力したくないユーザーID
  def to_html(title, myid = nil)
    print <<-TABLE_HEAD.unindent
      <table border=1 align=center> <caption>#{title}</caption>
      <tr><th>名前</th><th>コメント</th></tr>
      TABLE_HEAD
    @names.each do |id, name|
      print '<tr><td>'
      if id == myid
        print name
      else
        puts <<-CONTENT.unindent
          <label>
           <input type="radio" name="opponent" value="#{id}" onclick='onclick_radiobtn(event)'>#{name}
          </label>
          CONTENT
      end
      puts "</td><td>#{@comments[id]}</td></tr>"
    end
    puts '</table>'
  end
end
