# -*- encoding: utf-8 -*-

require 'yaml'
require 'logger'

require './file/userinfofile.rb'
require './game/taikyokudata.rb'

#
# 対局情報ファイル管理クラス
#
class MatchInfoFile
  # 初期化
  #
  # @param gameid 対局ID
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
    @turn = 'b'
    @log = nil
  end

  attr_reader :gid, :idb, :playerb, :emailb, :idw, :playerw, :emailw,
              :creator, :dt_created, :teban, :tegoma, :nth, :sfen,
              :lastmove, :dt_lastmove, :finished
  attr_accessor :log, :turn

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
  # userinfo 対局者の情報
  def setplayerb(id_b, userinfo)
    return if userinfo.nil?
    @idb = id_b
    @playerb = userinfo[0]
    @emailb = userinfo[2]
  end

  # 対局者のセット
  #
  # id_w 対局者のID
  # userinfo 対局者の情報
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

  # 対戦相手の情報を得る
  #
  # @param id_ ユーザーID
  # @return 対戦相手の情報 { id: id, name: nm, mail: em }
  def getopponent(id_)
    if @idb == id_
      { id: @idw, name: @playerw, mail: @emailw }
    elsif @idw == id_
      { id: @idb, name: @playerb, mail: @emailb }
    end
  end

  # 手番の対局者の情報を得る
  #
  # @return 対局者の情報 { id: id, name: nm, mail: em }
  def getnextplayer
    if @teban == 'b'
      { id: @idb, name: @playerb, mail: @emailb }
    elsif @teban == 'w'
      { id: @idw, name: @playerw, mail: @emailw }
    end
  end

  # 対局設定者の情報のセット
  #
  # @param name 対局設定者の名前
  # @param dt   生成時刻
  def setcreator(name, dt)
    @creator = name
    @dt_created = dt
  end

  # 着手情報のセット
  #
  # @param mv 着手情報文字列
  # @param dt [Time] 着手日時オブジェクト
  def setlastmove_dt(mv, dt)
    @lastmove = mv
    @dt_lastmove = dt.strftime('%Y/%m/%d %H:%M:%S')
  end

  # 着手情報のセット
  #
  # @param mv 着手情報文字列
  # @param dt [String] 着手日時文字列 'yyyy/mm/dd hh:mm:dd'
  def setlastmove(mv, dt)
    @lastmove = mv
    @dt_lastmove = dt
  end

  # sfenから得られる情報のセット
  #
  # @param sfenstr sfen文字列
  # @param items   [teban, tegoma, nth]
  def setsfen(sfenstr, items)
    @sfen = sfenstr
    @teban = items[1]
    @tegoma = items[2]
    @nth = items[3]
  end

  # minimal syntax check
  #
  # @param sfenstr sfen文字列
  # @return nil if invalid, otherwise successful.
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

  # sfenの内容の確認
  #
  # @param item sfenを空白でsplitしたArray
  # @return true if invalid
  def invalid_sfenitem?(item)
    # @log.debug('return if @teban == item[1]')
    # @log.debug("return if #{@nth.to_i}+1 != #{item[3]}")
    # @log.debug('return if checksfen(item[0]).nil?')
    item.length != 4 || @teban == item[1] \
      || @nth.to_i + 1 != item[3].to_i || checksfen(item[0]).nil?
  end

  # sfen to parameters with minimal syntax check.
  # teban and nth are also checked.
  #
  # @param sfenstr sfen文字列
  def fromsfen_strict(sfenstr)
    # @log.debug('return unless @teban =~ /[bw]/')
    return unless @teban =~ /[bw]/

    item = sfenstr.split(' ')

    # return if item.length != 4
    # # @log.debug('return if @teban == item[1]')
    # return if @teban == item[1]
    # # @log.debug("return if #{@nth.to_i}+1 != #{item[3]}")
    # return if @nth.to_i + 1 != item[3].to_i
    # # @log.debug('return if checksfen(item[0]).nil?')
    # return if checksfen(item[0]).nil?
    return if invalid_sfenitem?(item)

    setsfen(sfenstr, item)
  end

  # sfen to parameters with minimal syntax check.
  #
  # @param sfenstr sfen文字列
  def fromsfen(sfenstr)
    item = sfenstr.split(' ')

    return if item.length != 4
    return if checksfen(item[0]).nil?

    setsfen(sfenstr, item)
  end

  # 対局終了フラグのセットと勝ち負けの記入
  #
  # @param per100_text %から始まる文字列。%TORYOなど。
  #        %TORYOであれば@tebanにより勝敗を@turnに、
  #        それ以外であれば@turnに。引き分けを入れる。
  def done_game_sp(per100_text)
    @finished = true
    @turn =
      if per100_text == '%TORYO'
        if @teban == 'b'
          'fw'  # 後手勝ち
        else
          'fb'  # 先手勝ち
        end
      else
        'd'  # 引き分け
      end
    # @teban = 'f'
  end

  # 対局終了フラグのセットと勝ち負けの記入
  def done_game_gyoku
    @finished = true
    # @teban = 'f'
    @turn =
      if @teban == 'b'
        'fw'  # 後手勝ち
      else
        'fb'  # 先手勝ち
      end
  end

  # 手番文字を返す
  #
  # @return 'b':先手の手番, 'w':後手の手番, 'f':対局終了
  def teban_ex
    @finished ? 'f' : @teban
  end

  # 手番情報の更新
  #
  # @param trn 手番文字。nilならば@tebanがコピーされる。
  def setturn(trn)
    @turn = trn || @teban
  end

  # ハッシュを読み取る
  #
  # @param data ハッシュオブジェクト{gid:, creator:, dt_created:,
  #  idb:, playerb:, idw:, playerw:, sfen:, lastmove:, dt_lastmove:, finished: }
  def read_data(data)
    setcreator(data[:creator], data[:dt_created])
    setplayers(data[:idb], data[:idw])
    fromsfen(data[:sfen])
    setlastmove(data[:lastmove], data[:dt_lastmove])
    @finished = data[:finished] || false
    # @teban = 'f' if @finished
    # @turn = data[:turn] || @teban
  end

  # ファイルからデータの読み込み
  #
  # @param path ファイルパス
  # @return nil if invalid, otherwise successful.
  def read(path)
    data = YAML.load_file(path)

    @gid = data[:gid]
    return nil if @gid.nil?

    read_data(data)

    self
  rescue
    return nil
  end

  # 初期化データの書き込み
  #
  # @param id_b    先手のID
  # @param id_w    後手のID
  # @param creator 生成者
  # @param path    ファイルパス
  def initial_write(id_b, id_w, creator, cdt, path)
    setplayers(id_b, id_w)
    setcreator(creator, cdt)
    @dt_lastmove = cdt
    write(path)
  end

  # ハッシュにして返す
  #
  # @return ハッシュオブジェクト
  def genhash
    {
      gid: gid, creator: creator, dt_created: dt_created,
      idb: idb, playerb: playerb, idw: idw, playerw: playerw, sfen: sfen,
      lastmove: lastmove, dt_lastmove: dt_lastmove, finished: finished,
      turn: turn
    }
  end

  # 情報の書き出し
  #
  # @param path ファイルパス
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

  # vs形式の文字列の生成
  #
  # @return vs形式の文字列
  def to_vs
    "#{playerb} vs #{playerw}"
  end

  # ダウンロードファイル名の生成
  #
  # @param ext 拡張子
  # @return ダウンロードファイル名文字列
  def build_fn2dl(ext)
    dt = @dt_lastmove.delete('/:').sub(' ', '_')
    "#{@playerb}_#{@playerw}_#{dt}.#{ext}"
  end
end
