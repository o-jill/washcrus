# -*- encoding: utf-8 -*-

require 'yaml'

require './file/userinfofile.rb'
require './game/taikyokudata.rb'

#
# 対局情報ファイル管理クラス
#
class MatchInfoFile
  def initialize(gameid)
    @gid = gameid # 'ididididid'
    # @idb = '', @playerb = '', @emailb = ''
    setplayerb('', ['', '', ''])
    # @idw = '', @playerw = '', @emailw = ''
    setplayerw('', ['', '', ''])
    # @creator = '', @dt_created = ''
    setcreator('', '')
    fromsfen('lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1')
    @lastmove = '-9300FU'
    @dt_lastmove = 'yyyy/mm/dd hh:mm:ss'
    @finished = false
  end

  attr_reader :gid, :idb, :playerb, :emailb, :idw, :playerw, :emailw,
              :creator, :dt_created, :teban, :tegoma, :nth, :sfen,
              :lastmove, :dt_lastmove, :finished

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
      setplayerb(id, user)
    else
      setplayerw(id, user)
    end
  end

  # 対局者のセット
  #
  # id_b 対局者のID
  def setplayerb(id_b, userinfo)
    return if userinfo.nil?
    @idb = id_b
    @playerb = userinfo[0]
    @emailb = userinfo[2]
  end

  # 対局者のセット
  #
  # id_w 対局者のID
  def setplayerw(id_w, userinfo)
    return if userinfo.nil?
    @idw = id_w
    @playerw = userinfo[0]
    @emailw = userinfo[2]
  end

  # 対局者のセット
  #
  # id_b 対局者のID
  # id_w 対局者のID
  def setplayers(id_b, id_w)
    db = UserInfoFile.new
    db.read

    setplayerb(id_b, db.findid(id_b))
    setplayerw(id_w, db.findid(id_w))
  end

  def setcreator(name, dt)
    @creator = name
    @dt_created = dt
  end

  # 着手情報のセット
  #
  # @param dt [Time] 着手日時
  def setlastmove_dt(mv, dt)
    @lastmove = mv
    @dt_lastmove = dt.strftime('%Y/%m/%d %H:%M:%S')
  end

  # 着手情報のセット
  #
  # @param dt [String] 着手日時文字列 'yyyy/mm/dd hh:mm:dd'
  def setlastmove(mv, dt)
    @lastmove = mv
    @dt_lastmove = dt
  end

  # def setsfen(board, teban, tegoma, nth)
  #   @sfen = "#{board} #{teban} #{tegoma} #{nth}"
  #   @teban = teban
  #   @tegoma = tegoma
  #   @nth = nth
  # end

  def checksfen(sfenstr)
    dan = sfenstr.split('/')
    return nil if dan.length != 9
    dan.each do |line|
      nine = 9
      line.each_char do |chr|
        case chr
        when '1'..'9' then nine -= chr.to_i
        when '+' then next
        else nine -= 1
        end
      end
      return nil unless nine.zero?
    end
  end

  def fromsfen(sfenstr)
    item = sfenstr.split(' ')

    return if item.length != 4
    return if checksfen(item[0]).nil?

    @sfen = sfenstr
    @teban = item[1]
    @tegoma = item[2]
    @nth = item[3]
  end

  def done_game
    @finished = true
    @teban = 'f'
  end

  def read(path)
    data = YAML.load_file(path)

    @gid = data[:gid]
    return nil if @gid.nil?

    setcreator(data[:creator], data[:dt_created])
    setplayers(data[:idb], data[:idw])
    fromsfen(data[:sfen])
    setlastmove(data[:lastmove], data[:dt_lastmove])
    @finished = data[:finished] || false
    @teban = 'f' if @finished
  rescue
    return nil
  end

  def initial_write(id_b, id_w, creator, cdt, path)
    setplayers(id_b, id_w)
    setcreator(creator, cdt)
    write(path)
  end

  def genhash
    {
      gid: gid, creator: creator, dt_created: dt_created,
      idb: idb, playerb: playerb, idw: idw, playerw: playerw, sfen: sfen,
      lastmove: lastmove, dt_lastmove: dt_lastmove, finished: finished
    }
  end

  def write(path)
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
