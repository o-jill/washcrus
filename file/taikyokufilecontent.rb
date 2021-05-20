# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'
require 'time'
require 'unindent'
require './views/common_ui.rb'

# Contents management of TaikyokuFiles
class TaikyokuFileContent
  # 初期化
  def initialize
    @idbs = {}
    @idws = {}
    @namebs = {}
    @namews = {}
    @turns = {}
    @times = {}
    @comments = {}
  end

  # @!attribute [r] idbs
  #   @return 対局ID: 先手の対局者ID
  # @!attribute [r] idws
  #   @return 対局ID: 後手の対局者ID
  # @!attribute [r] namebs
  #   @return 対局ID: 先手の対局者名
  # @!attribute [r] namews
  #   @return 対局ID: 後手の対局者名
  # @!attribute [r] turns
  #   @return 対局ID: 手番
  # @!attribute [r] times
  #   @return 対局ID: 最終着手日時
  # @!attribute [r] comments
  #   @return 対局ID: コメント
  attr_reader :idbs, :idws, :namebs, :namews, :turns, :times, :comments

  # ファイルに出力
  #
  # @param file ファイルオブジェクト
  # @param a_id 対局IDのリスト。nilならすべて。
  def put(file, a_id)
    a_id ||= @idbs.keys
    a_id.each do |id|
      file.puts "#{id},#{@idbs[id]},#{@idws[id]},#{@namebs[id]}," \
                "#{@namews[id]},#{@turns[id]},#{@times[id]},#{@comments[id]}"
    end
  end

  # get game info by game id
  #
  # @param id 対局ID
  # @return hash{id:, idb:, idw:, nameb:, namew:, turn:, time:, comment:}
  def probe(id)
    {
      id: id,
      idb: @idbs[id],
      idw: @idws[id],
      nameb: @namebs[id],
      namew: @namews[id],
      turn: @turns[id],
      time: @times[id],
      comment: @comments[id]
    }
  end

  # get game info by game ids
  #
  # @param array_id 対局IDの配列
  # @return array of probe(i)
  def probeex(array_id)
    games = []
    array_id.each do |id|
      games << probe(id)
    end
    games
  end

  # remove taikyoku information
  #
  # @param nid 対局ID
  def remove(nid)
    @idbs.delete(nid)
    @idws.delete(nid)
    @namebs.delete(nid)
    @namews.delete(nid)
    @turns.delete(nid)
    @times.delete(nid)
    @comments.delete(nid)
  end

  # add taikyoku information
  #
  # @param arr [nid, idb, idw, ply1, ply2, turn, dt, cmt]
  def add_array(nid, arr)
    # add(arr[0], arr[1], arr[2], arr[3], arr[4], arr[5], arr[6])
    (idb, idw, nmb, nmw, turn, time, cmt) = arr
    @idbs[nid]     = idb
    @idws[nid]     = idw
    @namebs[nid]   = nmb
    @namews[nid]   = nmw
    @turns[nid]    = turn
    @times[nid]    = time
    @comments[nid] = cmt
  end

  # 対局IDを返す
  #
  # @return 対局IDのリスト
  def gameids
    @idbs.keys
  end

  # get taikyoku information by id
  #
  # @param id 対局ID
  # @return nil or probe(id)
  def findid(id)
    probe(id) if exist_id(id)
  end

  # duplication check
  #
  # @param nid 対局ID
  # @return true if nid exists.
  def exist_id(nid)
    @namebs.key?(nid)
  end

  # get taikyoku information by name
  #
  # @param name 先手の対局者名
  # @return 対局IDと先手の対局者名のハッシュリスト
  def findnameb(name)
    @namebs.select { |_ky, vl| vl == name }
  end

  # get taikyoku information by name
  #
  # @param name 後手の対局者名
  # @return 対局IDと後手の対局者名のハッシュリスト
  def findnamew(name)
    @namews.select { |_ky, vl| vl == name }
  end

  # get taikyoku information by name
  #
  # @param name 対局者名
  # @return array of probe(i)
  def findname(name)
    foundid = findnameb(name)
    foundid.merge!(findnamew(name))
    probeex(foundid.keys)
  end

  # get taikyoku information by user-id
  #
  # @param nid 先手の対局者のID
  # @return 対局IDと先手のIDのハッシュリスト
  def finduidb(nid)
    @idbs.select { |_ky, vl| vl == nid }
  end

  # get taikyoku information by user-id
  #
  # @param nid 後手の対局者のID
  # @return 対局IDと後手のIDのハッシュリスト
  def finduidw(nid)
    @idws.select { |_ky, vl| vl == nid }
  end

  # get taikyoku information by user-id
  #
  # @param nid 対局者のID
  # @return 対局情報リスト
  def finduid(nid)
    foundid = finduidb(nid)
    foundid.merge!(finduidw(nid))
    probeex(foundid.keys)
  end

  # 指定時刻までに着手した対局の取得
  #
  # @param to 時刻文字列
  # @return 対局IDと着手時刻のハッシュリスト
  def findtime_to(to)
    tto = Time.parse(to)
    @times.select do |_ky, vl|
      tm = Time.parse(vl)
      (tto <=> tm) > 0 # toの日は含まない
    end
  end

  # 指定時刻以降に着手した対局の取得
  #
  # @param from 時刻文字列
  # @return 対局IDと着手時刻のハッシュリスト
  def findtime_from(from)
    tfrom = Time.parse(from)
    @times.select do |_ky, vl|
      tm = Time.parse(vl)
      (tm <=> tfrom) >= 0
    end
  end

  # 指定時刻間に着手した対局の取得
  #
  # @param to 時刻文字列
  # @param from 時刻文字列
  # @return 対局IDと着手時刻のハッシュリスト
  def findtime_both(from, to)
    tfrom = Time.parse(from)
    tto = Time.parse(to)
    tmpid = @times.select do |_ky, vl|
      tm = Time.parse(vl)
      (tm <=> tfrom) >= 0
    end
    tmpid.select do |_ky, vl|
      tm = Time.parse(vl)
      (tto <=> tm) > 0 # toの日は含まない
    end
  end

  # 指定時刻間に着手した対局の取得
  #
  # @param to 時刻文字列。null文字列可
  # @param from 時刻文字列。null文字列可
  # @return 対局IDと着手時刻のハッシュリスト
  def findtime(from, to)
    return findtime_to(to) if from.empty?

    return findtime_from(from) if to.empty?

    findtime_both(from, to)
  end

  # 着手日時の更新
  #
  # @param nid    対局ID
  # @param dt_str 時刻文字列
  def updatedatetime(nid, dt_str)
    @times[nid] = dt_str
  end

  # 手番の更新
  #
  # @param nid 対局ID
  # @param trn 手番
  def updateturn(nid, trn)
    @turns[nid] = trn
  end

  # １日以上経過した対局のIDを返す。
  #
  # @return 対局IDと着手時刻のハッシュリスト
  def checkelapsed
    limit = Time.now - 86_400 # 24*3600
    @times.select do |_key, val|
      # val + 24h > now
      # val > now - 24h
      Time.parse(val) <= limit
    end
  end

  # HTML形式(TABLE)に変換して出力
  #
  # @param title テーブルのキャプション
  def to_html(title)
    print <<-FNAME_AND_TABLE.unindent
      <table border=1 align=center> <Caption>#{title}</caption>
      <tr><th>ID</th><TH>先手</TH><TH>後手</TH><TH>手番</TH><TH>着手日時</TH><TH>コメント</TH></TR>
    FNAME_AND_TABLE
    @namebs.each do |id, name|
      puts <<-LINE.unindent
        <TR>
         <TD><a href='./index.rb?game/#{id}'>
          <img src='image/right_fu.png' alt='#{id}' title='move to this game!'>
          <small>#{id}</small>
         </a></TD>
         <TD>#{name}</TD><TD>#{@namews[id]}</TD>
         <TD>#{CommonUI.turn2str(@turns[id])}</TD>
         <TD>#{@times[id]}</TD><TD>#{@comments[id]}</TD>
        </TR>
      LINE
    end
    puts '</table>'
  end
end
