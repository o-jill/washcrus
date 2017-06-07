#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'

#
# 対局情報DB管理クラス
#
class TaikyokuFile
  def initialize(name = './taikyoku.csv')
    @fname = name
    @namebs = {}
    @namews = {}
    @times = {}
    @comments = {}
  end

  attr_accessor :fname, :namebs, :namews, :times, :comments

  def read
    begin
      File.open(@fname, 'r:utf-8') do |file|
        file.flock File::LOCK_EX

        file.each_line do |line|
          # comment
          next if line =~ /^#/

          # id, nameb, namew, time, comment
          elem = line.chomp.split(',')
          if elem.length == 5
            add(elem[0], elem[1], elem[2], elem[3], elem[4])
          elsif elem.length == 4
            add(elem[0], elem[1], elem[2], elem[3], '&lt;blank&gt;')
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
  end

  def write
    begin
      File.open(@fname, 'w') do |file|
        file.flock File::LOCK_EX
        file.puts '# taikyoku information' + Time.now.to_s
        file.puts '# id, nameb, namew, time, comment'
        namebs.each do |id, name|
          file.puts "#{id},#{name},#{namews[id]},#{times[id]},#{comments[id]}"
        end
      end
    # 例外は小さい単位で捕捉する
    rescue SystemCallError => e
      puts "class=[#{e.class}] message=[#{e.message}] in write"
    rescue IOError => e
      puts "class=[#{e.class}] message=[#{e.message}] in write"
    end
  end

  # get taikyoku information by id
  def findid(id)
    [@namebs[id], @namebs[id], @times[id], @comments[id]] if exist_id(id)
  end

  # get taikyoku information by name
  def findname(name)
    foundb = namebs.find { |_k, v| v == name }
    foundw = namews.find { |_k, v| v == name }
    foundid = foundb + foundw
    res = []
    foundid.each { |i| res << [i, namebs[i], namebs[i], times[i], comments[i]] }
    res
  end

  # add taikyoku information
  # [nid]     taikyoku id.
  # [player1] player1's name.
  # [player2] player2's name.
  # [dt]      date time.
  # [comment] comment.
  def add(nid, ply1, ply2, dt, cmt)
    @namebs[nid]   = ply1
    @namews[nid]   = ply2
    @times[nid]    = dt
    @comments[nid] = cmt
  end

  # remove taikyoku information
  def remove(nid)
    @namebs.delete(nid)
    @namews.delete(nid)
    @times.delete(nid)
    @comments.delete(nid)
  end

  # duplication check
  def exist_id(id)
    found = @namebs.find { |k, _v| k == id }
    !found.nil?
  end

  def dumphtml
    print <<-FNAME_AND_TABLE
      <table border=1>
      <Caption>path:#{fname}</caption>
      <tr><th>ID</th><TH>Black</TH><TH>White</TH><TH>Time</TH><TH>Comment</TH></TR>
      FNAME_AND_TABLE
    namebs.each do |id, name|
      puts "<TR><TD>#{id}</TD><TD>#{name}</TD><TD>#{namews[id]}</TD>",
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
  def initialize(name = './taikyokuchu.csv')
    super
  end
end
