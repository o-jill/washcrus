#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'

class TaikyokuFile
  def initialize(name = "./taikyoku.csv")
    @fname = name;
    @namebs = Hash.new
    @namews = Hash.new
    @times = Hash.new
    @comments = Hash.new
  end

  attr_accessor :fname, :namebs, :namews, :times, :comments

  def read
    begin
      File.open(@fname, "r:utf-8") do |file|
        file.flock File::LOCK_EX

        file.each_line do |line|
          if line =~ /^#/
            # comment
          else
            # id, nameb, namew, time, comment
            elements = line.chomp.split(',')
            if elements.length != 5
              if elements.length != 4
                # invalid line
              else
                id = elements[0];
                @namebs[id]   = elements[1]
                @namews[id]   = elements[2]
                @times[id]    = elements[3]
                @comments[id] = "&lt;blank&gt;"
              end
            else
              id = elements[0];
              @namebs[id]   = elements[1]
              @namews[id]   = elements[2]
              @times[id]    = elements[3]
              @comments[id] = elements[4]
            end
          end
        end
      end
    # 例外は小さい単位で捕捉する
    rescue SystemCallError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}] in read)
    rescue IOError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}] in read)
    end
  end
  def write
    begin
      File.open(@fname, "w") do |file|
        file.flock File::LOCK_EX
        file.puts "# taikyoku information "+ Time.now.to_s
        file.puts "# id, nameb, namew, time, comment"
        namebs.each{ |id, name|
          file.puts id+","+name+","+namews[id]+","+times[id]+","+comments[id]
        }
      end
    # 例外は小さい単位で捕捉する
    rescue SystemCallError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}] in write)
    rescue IOError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}] in write)
    end
  end
  # get taikyoku information by id
  def findid(id)
    if exist_id(id)
      return [@namebs[id], @namebs[id], @times[id], @comments[id]]
    else
      return nil
    end
  end
  # get taikyoku information by name
  def findname(name)
    foundb = namebs.find {|k, v| v == name}
    foundw = namews.find {|k, v| v == name}
    foundid = foundb+foundw
    res = []
    foundid.each{ |i|
      res << [i, namebs[i], namebs[i], times[i], comments[i]]
    }
    return res
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
    found = @namebs.find {|k, v| k == id}
    return found != nil
  end
  def dumphtml
    print <<FNAME_AND_TABLE
<table border=1>
<Caption>path:#{fname}</caption>
<tr><th>ID</th><TH>Black</TH><TH>White</TH><TH>Time</TH><TH>Comment</TH></TR>
FNAME_AND_TABLE
    namebs.each{ |id, name|
      puts "<TR><TD>"+id+"</TD><TD>"+name+"</TD><TD>"+namews[id]+"</TD><TD>"+times[id]+"</TD><TD>"+comments[id]+"</TD></TR>"
    }
    puts "</table>"
  end
end

class TaikyokuChuFile < TaikyokuFile
  def initialize(name = "./taikyokuchu.csv")
    super
  end
end
