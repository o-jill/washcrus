# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'
require 'time'
require 'timeout'
require 'unindent'

require './file/pathlist.rb'
require './file/taikyokufilecontent.rb'
require './util/myerror.rb'

#
# 対局情報DB管理クラス
#
class TaikyokuFile
  # 初期化
  #
  # @param name   データベースファイルのパス
  # @param lockfn 同期用ファイルのパス
  def initialize(name = PathList::TAIKYOKUFILE,
                 lockfn = PathList::TAIKYOKULOCKFILE)
    @fname = name
    @lockfn = lockfn
    @content = TaikyokuFileContent.new
  end

  # @!attribute [rw] fname
  #   @return ファイル名
  # @!attribute [rw] content
  #   @return 中身
  attr_accessor :fname, :content

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

  # 要素の並びを古いものから新しいものに合わせる
  #
  # @param elem 1要素
  #
  # @return 並べ直した要素
  def adjustelem(elem)
    elem[5] = elem[4] # time
    elem[4] = '?' # turn
    elem
  end

  # 要素の読み込み
  #
  # @param elem 1要素
  def read_element(elem)
    len = elem.length
    id = elem.shift
    if len == 8
      @content.add_array(id, elem)
    elsif len == 7
      elem[6] = elem[5] # comment
      @content.add_array(id, adjustelem(elem))
    elsif len == 6
      elem[6] = '&lt;blank&gt;' # comment
      @content.add_array(id, adjustelem(elem))
      # else
      #   skip
    end
  end

  # ファイルから1行読み込み
  #
  # @param file ファイルオブジェクト
  def read_lines(file)
    file.each_line do |line|
      # comment
      next if line =~ /^#/

      # id, nameb, namew, time, comment
      elem = line.chomp.split(',')

      read_element(elem)
    end
  end

  # ファイルの読み込み
  def read
    File.open(@fname, 'r:utf-8') do |file|
      file.flock File::LOCK_EX
      read_lines(file)
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
    file.puts "# taikyoku information#{Time.now}\n" \
              "# id, idb, idw, nameb, namew, turn, time, comment\n"
  end

  # ファイルへの書き出し
  def write
    File.open(@fname, 'w') do |file|
      file.flock File::LOCK_EX
      TaikyokuFile.put_header(file)
      @content.put(file, nil)
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
      @content.put(file, [id])
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  end

  # 対局の追加、ファイルへの追加書き出し
  #
  # @param data 対局情報
  def newgame(data)
    lock do
      read
      id = data.shift
      @content.add_array(id, data)
      append(id)
    end
  end

  # 手番情報の書き換え
  #
  # @param gid 対局ID
  # @param trn 手番
  def updateturn(gid, trn)
    lock do
      read
      @content.updateturn(gid, trn)
      write
    end
  end

  # duplication check
  #
  # @param nid 対局ID
  # @return true if nid exists.
  def exist_id(nid)
    @content.exist_id(nid)
  end

  # get taikyoku information by id
  #
  # @param id 対局ID
  # @return nil or probe(id)
  def findid(id)
    @content.findid(id)
  end

  # get taikyoku information by name
  #
  # @param name 先手の対局者名
  # @return 対局IDと先手の対局者名のハッシュリスト
  def findnameb(name)
    @content.findnameb(name)
  end

  # get taikyoku information by name
  #
  # @param name 後手の対局者名
  # @return 対局IDと後手の対局者名のハッシュリスト
  def findnamew(name)
    @content.findnamew(name)
  end

  # get taikyoku information by name
  #
  # @param name 対局者名
  # @return 対局情報リスト
  def findname(name)
    @content.findname(name)
  end

  # get taikyoku information by user-id
  #
  # @param nid 対局者のID
  # @return 対局情報リスト
  def finduid(nid)
    @content.finduid(nid)
  end

  # 指定時刻間に着手した対局の取得
  #
  # @param to 時刻文字列。null文字列可
  # @param from 時刻文字列。null文字列可
  # @return 対局IDと着手時刻のハッシュリスト
  def findtime(from, to)
    @content.findtime(from, to)
  end

  # remove taikyoku information
  #
  # @param nid 対局ID
  def remove(nid)
    @content.remove(nid)
  end

  # 着手日時と手番の更新
  #
  # @param gid 対局ID
  # @param now 現在の時刻オブジェクト
  # @param trn 手番
  def update_dt_turn(gid, now, trn)
    nowstr = now.strftime('%Y/%m/%d %H:%M:%S')
    lock do
      read
      @content.updatedatetime(gid, nowstr)
      @content.updateturn(gid, trn)
      write
    end
  end

  # HTML形式(TABLE)に変換して出力
  #
  # @param title テーブルのキャプション
  def to_html(title)
    @content.to_html(title)
  end
end

#
# 対局中情報DB管理クラス
#
# 終わった対局は、ここから消してTaikyokuFileへ
#
class TaikyokuChuFile < TaikyokuFile
  # 初期化
  #
  # @param name   データベースファイルのパス
  # @param lockfn 同期用ファイルのパス
  def initialize(name = PathList::TAIKYOKUCHUFILE,
                 lockfn = PathList::TAIKYOKUCHULOCKFILE)
    super
  end

  # 終局処理
  #
  # @param gid 対局ID
  def finished(gid)
    lock do
      read
      remove(gid)
      write
    end
  end

  # １日以上経過した対局のIDを返す。
  #
  # @return 対局IDと着手時刻のハッシュリスト
  def checkelapsed
    @content.checkelapsed
  end
end
