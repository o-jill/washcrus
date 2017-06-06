#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'yaml'

require './userinfofile.rb'
require './taikyokudata.rb'

#
# 対局情報ファイル管理クラス
#
class MatchInfoFile
  def initialize(gameid)
    @gid = gameid # 'ididididid'
    @idb = 'idbidbidb', @playerb = '+先手', @emailb = 'm@i.lb'
    @idw = 'idwidwidw', @playerw = '-gote', @emailw = 'm@i.lw'
    @creator = 'creator', @dt_created = 'yyyy/mm/dd hh:mm:ss'
    @teban = '+B', @tegoma = '-', @nth = 1
    @sfen = 'lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1'
    @lastmove = '-9300FU'
    @dt_lastmove = 'yyyy/mm/dd hh:mm:ss'
  end

  attr_reader :gid, :idb, :playerb, :emailb, :idw, :playerw, :emailw,
              :creator, :dt_created, :teban, :tegoma, :nth, :sfen,
              :lastmove, :dt_lastmove

  # 対局者のセット
  #
  # id     対局者のID
  # bsente true:先手, false:後手
  def setplayer(id, bsente)
    db = UserInfoFile.new
    db.read
    user = db.findid(id)
    return if user.nil?
    if bsente
      @idb = id, @playerb = user[0], @emailb = user[2]
    else
      @idw = id, @playerw = user[0], @emailw = user[2]
    end
  end

  # 対局者のセット
  #
  # id_b 対局者のID
  # id_w 対局者のID
  def setplayers(id_b, id_w)
    db = UserInfoFile.new
    db.read

    user = db.findid(id_b)
    @idb = id_b, @playerb = user[0], @emailb = user[2] unless user.nil?

    user = db.findid(id_w)
    @idw = id_w, @playerw = user[0], @emailw = user[2] unless user.nil?
  end

  def setcreator(name, dt)
    @creator = name
    @dt_created = dt
  end

  def setlastmove(mv, dt)
    @lastmove = mv
    @dt_lastmove = dt
  end

  def setsfen(board, teban, tegoma, nth)
    @sfen = "#{board} #{teban} #{tegoma} #{nth}"
    @teban = teban
    @tegoma = tegoma
    @nth = nth
  end

  def fromsfen(sfenstr)
    item = sfenstr.split(' ')

    @sfen = item[0]
    @teban = item[1]
    @tegoma = item[2]
    @nth = item[3]
  end

  def read(path)
    data = YAML.load_file(path)

    @gid = data['gid']

    setcreator(data['creator'], data['dt_created'])

    setplayers(data['idb'], data['idw'])

    fromsfen(data['sfen'])

    setlastmove(data['lastmove'], data['dt_lastmove'])
  end

  def initial_write(td, id_b, id_w)
    setplayers(id_b, id_w)
    setcreator(td.creator, td.datetime)
    write(td.matchinfopath)
  end

  def genhash
    {
      gid: gid, creator: creator, dt_created: dt_created,
      idb: idb, playerb: playerb, idw: idw, playerw: playerw, sfen: sfen,
      lastmove: lastmove, dt_lastmove: dt_lastmove
    }
  end

  def write(path)
    begin
      File.open(path, 'wb') do |file|
        file.flock File::LOCK_EX
        file.puts YAML.dump(genhash, file)
      end
    # 例外は小さい単位で捕捉する
    rescue SystemCallError => e
      puts "class=[#{e.class}] message=[#{e.message}] in yaml write"
    rescue IOError => e
      puts "class=[#{e.class}] message=[#{e.message}] in yaml write"
    end
  end
end
