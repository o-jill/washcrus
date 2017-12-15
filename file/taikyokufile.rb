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

  # 要素の読み込み
  #
  # @param elem 1要素
  def read_element(elem)
    if elem.length == 8
      @content.add_array(elem)
    elsif elem.length == 7
      elem[7] = elem[6]
      elem[6] = elem[5]
      elem[5] = '?'
      @content.add_array(elem)
    elsif elem.length == 6
      elem[7] = '&lt;blank&gt;'
      elem[6] = elem[5]
      elem[5] = '?'
      @content.add_array(elem)
    # else
      # skip
    end
  end

  # ファイルの読み込み
  def read
    File.open(@fname, 'r:utf-8') do |file|
      file.flock File::LOCK_EX

      file.each_line do |line|
        # comment
        next if line =~ /^#/

        # id, nameb, namew, time, comment
        elem = line.chomp.split(',')

        read_element(elem)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in read"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in read"
  end

  # ファイルのヘッダのコメント文の生成
  #
  # @param file Fileオブジェクト
  def put_header(file)
    file.puts '# taikyoku information' + Time.now.to_s
    file.puts '# id, idb, idw, nameb, namew, turn, time, comment'
  end

  # ファイルへの書き出し
  def write
    File.open(@fname, 'w') do |file|
      file.flock File::LOCK_EX
      put_header(file)
      @content.put(file, nil)
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  # ファイルへの追加書き出し
  #
  # @param id 対局ID
  def append(id)
    lock do
      File.open(@fname, 'a') do |file|
        file.flock File::LOCK_EX
        @content.put(file, [id])
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
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

  # 着手日時の更新
  #
  # @param dt_str 時刻文字列
  # @param nid    対局ID
  def updatedatetime(nid, dt_str)
    @content.updatedatetime(nid, dt_str)
  end

  # 手番の更新
  #
  # @param nid 対局ID
  # @param trn 手番
  def updateturn(nid, trn)
    @content.updateturn(nid, trn)
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
