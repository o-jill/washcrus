# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'
require 'time'
require 'timeout'
require 'unindent'

require './util/myerror.rb'

#
# 対局情報DB管理クラス
#
class TaikyokuFile
  LOCKFILE = './db/taikyokufile.lock'.freeze

  def initialize(name = './db/taikyoku.csv', lockfn = LOCKFILE)
    @fname = name
    @lockfn = lockfn
    @idbs = {}
    @idws = {}
    @namebs = {}
    @namews = {}
    @times = {}
    @comments = {}
  end

  attr_accessor :fname, :idbs, :idws, :namebs, :namews, :times, :comments

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

  def read_element(elem)
    if elem.length == 7
      add_array(elem)
    elsif elem.length == 6
      add(elem[0], elem[1], elem[2], elem[3], elem[4], elem[5],
          '&lt;blank&gt;')
    # else
      # skip
    end
  end

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

  def build_line(id)
    "#{id},#{@idbs[id]},#{@idws[id]}," \
    "#{namebs[id]},#{namews[id]},#{times[id]},#{comments[id]}"
  end

  def put_header(file)
    file.puts '# taikyoku information' + Time.now.to_s
    file.puts '# id, idb, idw, nameb, namew, time, comment'
  end

  def write
    File.open(@fname, 'w') do |file|
      file.flock File::LOCK_EX
      put_header(file)
      namebs.each do |id, _name|
        file.puts build_line(id)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  def append(id)
    lock do
      File.open(@fname, 'a') do |file|
        file.flock File::LOCK_EX
        file.puts build_line(id)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  # get game info by game id
  def probe(id)
    {
      id: id,
      idb: idbs[id],
      idw: idws[id],
      nameb: namebs[id],
      namew: namews[id],
      time: times[id],
      comment: comments[id]
    }
  end

  # get taikyoku information by id
  def findid(id)
    probe(id) if exist_id(id)
  end

  # get taikyoku information by name
  def findnameb(name)
    namebs.select { |_k, v| v == name }
  end

  # get taikyoku information by name
  def findnamew(name)
    namews.select { |_k, v| v == name }
  end

  # get taikyoku information by name
  def findname(name)
    foundid = findnameb(name)
    foundid.merge!(findnamew(name))
    res = []
    foundid.each do |i, _uid|
      res << probe(i)
    end
    res
  end

  # get taikyoku information by user-id
  def finduidb(nid)
    idbs.select { |_k, v| v == nid }
  end

  # get taikyoku information by user-id
  def finduidw(nid)
    idws.select { |_k, v| v == nid }
  end

  # get taikyoku information by user-id
  def finduid(name)
    foundid = finduidb(name)
    foundid.merge!(finduidw(name))
    res = []
    foundid.each do |i, _uid|
      res << probe(i)
    end
    res
  end

  def findtime_to(to)
    tto = Time.parse(to)
    @times.select do |_k, v|
      t = Time.parse(v)
      (tto <=> t) > 0 # toの日は含まない
    end
  end

  def findtime_from(from)
    tfrom = Time.parse(from)
    @times.select do |_k, v|
      t = Time.parse(v)
      (t <=> tfrom) >= 0
    end
  end

  def findtime_both(from, to)
    tfrom = Time.parse(from)
    tto = Time.parse(to)
    tmpid = @times.select do |_k, v|
      t = Time.parse(v)
      (t <=> tfrom) >= 0
    end
    tmpid.select do |_k, v|
      t = Time.parse(v)
      (tto <=> t) > 0 # toの日は含まない
    end
  end

  def findtime(from, to)
    return findtime_to(to) if from.empty?

    return findtime_from(from) if to.empty?

    findtime_both(from, to)
  end

  # add taikyoku information
  # [nid]     taikyoku id.
  # [idb]     player1's id.
  # [idw]     player2's id.
  # [ply1]    player1's name.
  # [ply2]    player2's name.
  # [dt]      date time.
  # [comment] comment.
  def add(nid, idb, idw, ply1, ply2, dt, cmt)
    @idbs[nid]     = idb
    @idws[nid]     = idw
    @namebs[nid]   = ply1
    @namews[nid]   = ply2
    @times[nid]    = dt
    @comments[nid] = cmt
  end

  def add_array(arr)
    add(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6])
  end

  # remove taikyoku information
  def remove(nid)
    @idbs.delete(nid)
    @idws.delete(nid)
    @namebs.delete(nid)
    @namews.delete(nid)
    @times.delete(nid)
    @comments.delete(nid)
  end

  # duplication check
  def exist_id(nid)
    @namebs.key?(nid)
  end

  def updatedatetime(nid, dt_str)
    @times[nid] = dt_str
  end

  def to_html(title)
    print <<-FNAME_AND_TABLE.unindent
      <table border=1 align=center> <Caption>#{title}</caption>
      <tr><th>ID</th><TH>先手</TH><TH>後手</TH><TH>着手日時</TH><TH>コメント</TH></TR>
      FNAME_AND_TABLE
    namebs.each do |id, name|
      puts <<-LINE.unindent
        <TR>
         <TD><a href='./washcrus.rb?game/#{id}'>#{id}</a></TD>
         <TD>#{name}</TD><TD>#{namews[id]}</TD>
         <TD>#{times[id]}</TD><TD>#{comments[id]}</TD>
        </TR>
        LINE
    end
    puts '</table>'
  end

  def dumphtml
    print <<-FNAME_AND_TABLE
      <table border=1> <Caption>path:#{fname}</caption>
      <tr><th>ID</th><TH>Black</TH><TH>White</TH><TH>Time</TH><TH>Comment</TH></TR>
      FNAME_AND_TABLE
    namebs.each do |id, name|
      puts <<-DUMPCONTENT
        <TR>
         <TD><a href='./washcrus.rb?game/#{id}'>#{id}</a></TD>
         <TD>#{name}(#{@idbs[id]})</TD><TD>#{namews[id]}(#{@idws[id]})</TD>
         <TD>#{times[id]}</TD><TD>#{comments[id]}</TD>
        </TR>
        DUMPCONTENT
    end
    puts '</table>'
  end
end

#
# 対局中情報DB管理クラス
#
# 終わった対局は、ここから消してTaikyokuFileへ
#
class TaikyokuChuFile < TaikyokuFile
  LOCKFILE = './db/taikyokuchufile.lock'.freeze

  def initialize(name = './db/taikyokuchu.csv', lockfn = LOCKFILE)
    super
  end

  def finished(gid)
    lock do
      read
      remove(gid)
      write
    end
  end

  # １日以上経過した対局のIDを返す。
  def checkelapsed
    limit = Time.now - 86_400 # 24*3600
    @times.select do |_key, val|
      # val + 24h > now
      # val > now - 24h
      Time.parse(val) <= limit
    end
  end
end
