# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'time'
require 'uri'
require 'logger'

require './file/chatfile.rb'
require './file/jsonkifu.rb'
require './file/jsonconsump.rb'
require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/gentaikyoku.rb'

# 対局情報クラス
class TaikyokuData
  def initialize
    @id1 = ''
    @id2 = ''
    @player1 = ''
    @player2 = ''
    @email1 = ''
    @email2 = ''
    @creator = '' # "name(email)"
    @gid = 'ididididid'
    @datetime = 'yyyy/mm/dd hh:mm:ss'
    # @turn = "F"
    # @nthmove = -1
    @log = nil
  end

  attr_reader :player1, :email1, :player2, :email2, :creator, :gid, :datetime,
              :taikyokupath, :matchinfopath, :chatpath, :kifupath, :mi, :jkf
  attr_accessor :log

  DIRPATH = './taikyoku/'.freeze
  CHATFILE = 'chat.txt'.freeze
  MATCHFILE = 'matchinfo.txt'.freeze
  KIFUFILE = 'kifu.jkf'.freeze

  def setplayer1(id, nm, em)
    @id1 = id
    @player1 = nm
    @email1 = em
  end

  def setplayer2(id, nm, em)
    @id2 = id
    @player2 = nm
    @email2 = em
  end

  def swtichplayers
    idt = @id1
    @id1 = @id2
    @id2 = idt

    playert = @player1
    @player1 = @player2
    @player2 = playert

    emailt = @email1
    @email1 = @email2
    @email2 = emailt
  end

  def setid(id_)
    @gid = id_
    @taikyokupath = DIRPATH + id_ + '/'
    @matchinfopath = @taikyokupath + MATCHFILE
    @chatpath = @taikyokupath + CHATFILE
    @kifupath = @taikyokupath + KIFUFILE
  end

  # 対局情報の生成
  # ファイルなどの準備もします。
  def generate
    # 生成日時
    @datetime = Time.now.strftime('%Y/%m/%d %H:%M:%S')

    # 対局ID
    id = genid
    return print "generation failed...\n" if id.nil?
    setid(id)

    # フォルダとかファイルとかの生成
    gentd = GenTaikyokuData.new(self)
    gentd.generate

    tdb = TaikyokuFile.new
    tdb.read
    tdb.add(gid, player1, player2, datetime, '')
    tdb.write

    tcdb = TaikyokuChuFile.new
    tcdb.read
    tcdb.add(gid, player1, player2, datetime, '')
    tcdb.write

    # match information file
    @mi = MatchInfoFile.new(gid)
    @mi.initial_write(@id1, @id2, @creator, @datetime, @matchinfopath)

    # kifu file
    @jkf = JsonKifu.new(gid)
    @jkf.initial_write(@player1, @player2, @datetime, @kifupath)

    # chat file
    chat = ChatFile.new(gid)
    chat.sayex("<span id='chatadmin'>Witness</span>",
               "it's on time. please start your move as SENTE, #{player1}-san.")
  end

  # 対局情報の生成
  # ファイルなどの準備はしません。
  def checkgenerate
    # 生成者
    @creator = 'nanashi' if creator.nil?
    # 生成日時
    @datetime = Time.now.strftime('%Y/%m/%d %H:%M:%S')
    # 対局ID
    setid(genid)
  end

  def player1ng?
    player1.nil? || player1 == '' || email1.nil? || email1 == ''
  end

  def player2ng?
    player2.nil? || player2 == '' || email2.nil? || email2 == ''
  end

  def genid
    return nil if player1ng?
    return nil if player2ng?
    return nil if creator.nil? || creator == ''

    id_raw = "#{player1}_#{email1}_#{player2}_#{email2}_#{creator}_#{datetime}"
    id = Digest::SHA256.hexdigest id_raw
    id[0, 10]
  end

  def read
    # データを読み込んで
    @mi = MatchInfoFile.new(@gid)
    return nil if @mi.read(matchinfopath).nil?
    @jkf = JsonKifu.new(@gid)
    return nil if @jkf.read(kifupath).nil?
    # @chat = ChatFile.new(@gameid)
    # @chat.read()
    self
  end

  def escape_fn(fname)
    path = fname.gsub(%r{[\\\/*:<>?|]}, '_')
    URI.escape(path)
  end

  def escape_fnu8(fname)
    path = fname.gsub(%r{[\\/*:<>?|]},
                      '\\' => '￥', '/' => '／', '*' => '＊', ':' => '：',
                      '<' => '＜', '>' => '＞', '?' => '？', '|' => '｜')
    URI.escape(path)
  end

  def download_csa
    dt = @mi.dt_lastmove.delete('/:').sub(' ', '_')
    filename = "#{@mi.playerb}_#{@mi.playerw}_#{dt}.csa"

    puts 'Content-type: application/octet-stream'
    puts 'Content-Disposition: attachment; ' \
         "filename='#{escape_fn(filename)}'; " \
         "filename*=UTF-8''#{escape_fnu8(filename)}\n\n"
    puts @jkf.to_csa
  end

  def download_kif
    dt = @mi.dt_lastmove.delete('/:').sub(' ', '_')
    filename = "#{@mi.playerb}_#{@mi.playerw}_#{dt}.kif"

    puts 'Content-type: application/octet-stream'
    puts 'Content-Disposition: attachment; ' \
         "filename='#{escape_fn(filename)}'; " \
         "filename*=UTF-8''#{escape_fnu8(filename)}\n\n"
    puts @jkf.to_kif.encode('Shift_JIS')
  end

  def move(sfen, jsmv, dt)
    @log.debug("Taikyokudata.move(jsmv, #{dt})")

    return if @mi.fromsfen(sfen).nil?

    jc = JsonConsumption.new
    # @log.debug('jc.settotal if @jkf.last_time')
    total = @jkf.last_time
    # totalstr = total.nil? ? 'nil' : total.to_s
    # @log.debug("total:#{totalstr}")
    jc.settotal(total['total']) unless total.nil?
    # @log.debug("Time.parse(#{@mi.dt_lastmove})")
    t_last = Time.parse(@mi.dt_lastmove)
    # @log.debug('jc.diff(dt, t_last)')
    jc.diff(dt, t_last)
    # @log.debug("@jkf.move(jsmv, #{jc.genhash})")
    # @jkf.log = @log
    @jkf.move(jsmv, jc.genhash)
    # @log.debug('@jkf.moved(jsmv, jc.genhash)')

    if JsonMove.catchOU?(jsmv)
      @mi.done_game
      @jkf.resign
    end

    self
  end

  def dump
    print <<-DUMP
      taikyoku-id:#{@gid}
      creator: #{@creator}
      datetime: #{@datetime}
      player1: #{@player1}
      email1: #{@email1}
      player2: #{@player2}
      email2: #{@email2}
      DUMP
  end

  def dumptable
    print <<-DUMP
      <TABLE>
      <TR><TD>taikyoku-id</TD><TD>#{@gid}</TD></TR>
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
