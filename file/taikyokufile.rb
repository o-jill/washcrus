# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'

#
# 対局情報DB管理クラス
#
class TaikyokuFile
  def initialize(name = './db/taikyoku.csv')
    @fname = name
    @idbs = {}
    @idws = {}
    @namebs = {}
    @namews = {}
    @times = {}
    @comments = {}
  end

  attr_accessor :fname, :idbs, :idws, :namebs, :namews, :times, :comments

  def read
    File.open(@fname, 'r:utf-8') do |file|
      file.flock File::LOCK_EX

      file.each_line do |line|
        # comment
        next if line =~ /^#/

        # id, nameb, namew, time, comment
        elem = line.chomp.split(',')
        if elem.length == 7
          add_array(elem)
        elsif elem.length == 6
          add(elem[0], elem[1], elem[2], elem[3], elem[4], elem[5],
              '&lt;blank&gt;')
        # else
          # skip
        end
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in read"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in read"
  end

  def write
    File.open(@fname, 'w') do |file|
      file.flock File::LOCK_EX
      file.puts '# taikyoku information' + Time.now.to_s
      file.puts '# id, idb, idw, nameb, namew, time, comment'
      namebs.each do |id, name|
        file.puts "#{id},#{@idbs[id]},#{@idws[id]}," \
                  "#{name},#{namews[id]},#{times[id]},#{comments[id]}"
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  # get taikyoku information by id
  def findid(id)
    [@namebs[id], @namebs[id], @times[id], @comments[id]] if exist_id(id)
  end

  # get taikyoku information by name
  def findnameb(name)
    namebs.find { |_k, v| v == name }
  end

  # get taikyoku information by name
  def findnamew(name)
    namews.find { |_k, v| v == name }
  end

  # get taikyoku information by name
  def findname(name)
    foundid = findnameb(name) + findnamew(name)
    res = []
    foundid.each do |i|
      res << [i, idbs[i], idws[i], namebs[i], namebs[i], times[i], comments[i]]
    end
    res
  end

  # get taikyoku information by user-id
  def finduidb(nid)
    idbs.find { |_k, v| v == nid }
  end

  # get taikyoku information by user-id
  def finduidw(nid)
    idws.find { |_k, v| v == nid }
  end

  # get taikyoku information by user-id
  def finduid(name)
    foundid = finduidb(name) + finduidw(name)
    res = []
    foundid.each do |i|
      res << [i, idbs[i], idws[i], namebs[i], namebs[i], times[i], comments[i]]
    end
    res
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

  def dumphtml
    print <<-FNAME_AND_TABLE
      <table border=1> <Caption>path:#{fname}</caption>
      <tr><th>ID</th><TH>Black</TH><TH>White</TH><TH>Time</TH><TH>Comment</TH></TR>
      FNAME_AND_TABLE
    namebs.each do |id, name|
      puts "<TR><TD><a href='./game.rb?#{id}' target='_blank'>#{id}</a></TD>" \
           "<TD>#{name}#{@idbs[id]})</TD><TD>#{namews[id]}(#{@idws[id]})</TD>" \
           "<TD>#{times[id]}</TD><TD>#{comments[id]}</TD></TR>\n"
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
  def initialize(name = './db/taikyokuchu.csv')
    super
  end

  def finished(gid)
    remove(gid)
    write
  end
end
