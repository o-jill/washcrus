#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'digest/sha2'


# 対局情報クラス
class TaikyokuData
  def initialize()
    @player1 = ""
    @player2 = ""
    @email1 = ""
    @email2 = ""
    @creator = ""  # "name(email)"
    @id = "ididididid"
    @datetime = "yyyy/mm/dd hh:mm:ss"
    # @turn = "F"
    # @nthmove = -1
  end

  attr_accessor :player1, :email1, :player2, :email2, :creator, :id, :datetime,
    :taikyokupath, :matchinfopath, :chatpath, :csapath

  DIRPATH = './taikyoku/'
  CHATFILE = 'chat.txt'
  MATCHFILE = 'matchinfo.txt'
  KIFUFILE = 'kifu.csa'


  # 対局情報の生成
  # ファイルなどの準備もします。
  def generate()
    # 生成日時
    @datetime = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    # 対局ID
    @id = genid
    if id == nil
      print "generation failed...\n"
      return nil
    end

    # フォルダとかファイルとかの生成
    @taikyokupath = DIRPATH + id + '/'
    @matchinfopath = taikyokupath + MATCHFILE
    @chatpath = taikyokupath + CHATFILE
    @csapath = taikyokupath + KIFUFILE

    require './gentaikyoku.rb'
    gentd = GenTaikyokuData.new(self)
    gentd.generate

    require './taikyokufile.rb'
    tdb = TaikyokuFile.new
    tdb.read
    tdb.add(id, player1, player2, datetime, "")
    tdb.write

    tcdb = TaikyokuChuFile.new
    tcdb.read
    tcdb.add(id, player1, player2, datetime, "")
    tcdb.write
  end

  # 対局情報の生成
  # ファイルなどの準備はしません。
  def checkgenerate()
    if creator == nil
      @creator = "nanashi"
    end
    # 生成日時
    @datetime = Time.now.strftime("%Y/%m/%d %H:%M:%S")
    # 対局ID
    @id = genid
  end

  def genid
    if player1 == nil || player1 == "" || email1 == nil || email1 == "" \
      || player2 == nil || player2 == "" || email2 == nil || email2 == "" \
      || creator == nil || creator == ""
      return nil
    else
      id_raw = player1+'_'+email1+'_'+player2+'_'+email2+'_'+creator+'_'+datetime
      id = Digest::SHA256.hexdigest id_raw
      return id[0, 10]
    end
  end

  def dump()
    print <<-DUMP
taikyoku-id:#{@id}
creator: #{@creator}
datetime: #{@datetime}
player1: #{@player1}
email1: #{@email1}
player2: #{@player2}
email2: #{@email2}
DUMP
  end
  def dumptable()
    print <<-DUMP
<TABLE>
<TR><TD>taikyoku-id</TD><TD>#{@id}</TD></TR>
<TR><TD>creator</TD><TD>#{@creator}</TD></TR>
<TR><TD>datetime</TD><TD>#{@datetime}</TD></TR>
<TR><TD>player1</TD><TD>#{@player1}</TD></TR>
<TR><TD>email1</TD><TD>#{@email1}</TD></TR>
<TR><TD>player2</TD><TD>#{@player2}</TD></TR>
<TR><TD>email2</TD><TD>#{@email2}</TD></TR>
</TABLE>
DUMP
  end
end
