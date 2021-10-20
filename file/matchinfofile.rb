# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'yaml'
require 'logger'

require './file/userinfofile.rb'
require './game/player.rb'
require './game/taikyokudata.rb'
require './game/timekeeper.rb'

#
# 対局情報ファイル管理クラス他クラスから必要ない奴ら
#
module MatchInfoFileUtil
  # count # of pieces on a line.
  #
  # @param sfenstr sfen文字列
  # @return # of pieces
  def self.checksfen_line(line)
    nkoma = 0
    line.each_char do |chr|
      case chr
      when '1'..'9' then nkoma += chr.to_i
      when '+' then next
      else nkoma += 1
      end
    end
    nkoma
  end

  # minimal sfen board syntax check
  #
  # @param sfenstr sfen文字列
  # @return nil if invalid, otherwise successful.
  def self.checksfen(sfenstr)
    dan = sfenstr.split('/')
    return nil if dan.length != 9

    dan.each do |line|
      nkoma = checksfen_line(line)
      return nil if nkoma != 9
    end
  end

  # sfenの内容の確認
  #
  # @param item sfenを空白でsplitしたArray
  # @return true if invalid
  def self.invalid_sfenitem?(item, tbn, nth)
    # @log.debug('return unless @teban =~ /[bw]/')
    # @log.debug('return if @teban == item[1]')
    # @log.debug("return if #{@nth.to_i}+1 != #{item[3]}")

    !%w[b w].include?(tbn) || tbn == item[1] || nth.to_i + 1 != item[3].to_i
  end

  # ファイル名に使えない文字の変換
  # _に変換
  #
  # @param fname 対象文字列
  # @return 変換結果文字列
  def self.escape_fn(fname)
    path = fname.gsub(%r{[\\\/*:<>?|]}, '_')
    URI.encode_www_form_component(path)
  end

  # ファイル名に使えない文字の変換
  # 全角に変換
  #
  # @param fname 対象文字列
  # @return 変換結果文字列
  def self.escape_fnu8(fname)
    path = fname.gsub(%r{[\\/*:<>?|]},
                      '\\' => '￥', '/' => '／', '*' => '＊', ':' => '：',
                      '<' => '＜', '>' => '＞', '?' => '？', '|' => '｜')
    URI.encode_www_form_component(path)
  end
end

#
# 対局情報ファイル管理クラス
#
class MatchInfoFile
  include MatchInfoFileUtil
  # 初期化
  #
  # @param gameid 対局ID
  def initialize(gameid)
    @gid = gameid # 'ididididid'
    @playerb = Player.new('', '', '')
    @playerw = Player.new('', '', '')
    # @creator = '', @dt_created = ''
    setcreator('', '')
    fromsfen('lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1')
    @lastmove = '-9300FU'
    @dt_lastmove = 'yyyy/mm/dd hh:mm:ss'
    @finished = false
    @turn = 'b'

    @dt_lasttick = Time.now
    @maxbyouyomi = 259_200 # 3days
    @extratime = 86_400 # 考慮時間１回の時間 1day
    @byouyomi = 259_200 # 秒読み残り時間 3days

    @log = nil
  end

  # 勝ち負けを含む手番文字列
  #
  # @return 手番文字列(b, w, fb, fw)
  def turnex
    (@finished ? 'f' : '') + @turn
  end

  # @!attribute [r] gid
  #   @return 対局ID
  # @!attribute [r] playerb
  #   @return 先手の対局者
  # @!attribute [r] playerw
  #   @return 後手の対局者
  # @!attribute [r] creator
  #   @return [String] 対局生成者情報 'name(email)'
  # @!attribute [r] dt_created
  #   @return 生成日時文字列
  # @!attribute [r] teban
  #   @return sfen文字列の手番部分
  # @!attribute [r] tegoma
  #   @return sfen文字列の手駒部分
  # @!attribute [r] nth
  #   @return sfen文字列の何手目かの部分
  # @!attribute [r] sfen
  #   @return sfen文字列
  # @!attribute [r] lastmove
  #   @return 最終着手
  # @!attribute [r] dt_lastmove
  #   @return 最終着手日時
  # @!attribute [r] finished
  #   @return 終局したらtrue
  # @!attribute [r] byouyomi
  #   @return カウント中の秒読み
  # @!attribute [r] dt_lasttick
  #   @return 持ち時間最終確認時刻
  attr_reader :gid, :playerb, :playerw, :creator, :dt_created,
              :teban, :tegoma, :nth, :sfen, :lastmove, :dt_lastmove, :finished,
              :byouyomi, :dt_lasttick

  # @!attribute [rw] log
  #   @return ログオブジェクト
  # @!attribute [rw] turn
  #   @return 手番とか結果を表す文字列
  attr_accessor :log, :turn

  # 対局者のセット
  #
  # id_b 対局者のID
  # userinfo 対局者の情報
  def setplayerb(id_b, userinfo)
    @playerb = Player.new(id_b, userinfo[:name], userinfo[:email]) if userinfo
  end

  # 対局者のセット
  #
  # @param id_w 対局者のID
  # @param userinfo 対局者の情報
  def setplayerw(id_w, userinfo)
    @playerw = Player.new(id_w, userinfo[:name], userinfo[:email]) if userinfo
  end

  # 対局者のセット
  #
  # @param id_b 対局者のID
  # @param id_w 対局者のID
  def setplayers(id_b, id_w)
    db = UserInfoFile.new
    db.read
    cnt = db.content
    setplayerb(id_b, cnt.findid(id_b)) if id_b
    setplayerw(id_w, cnt.findid(id_w)) if id_w
  end

  # 対局者のセット
  #
  # @param data ハッシュオブジェクト
  # @option idb 先手対局者のID
  # @option idw 後手対局者のID
  def setplayers_d(data)
    setplayers(data[:idb], data[:idw])
  end

  # 対戦相手の情報を得る
  #
  # @param id_ ユーザーID
  # @return 対戦相手の情報 { id: id, name: nm, mail: em }
  def getopponent(id_)
    return @playerw.genhash if @playerb.myid?(id_)

    return @playerb.genhash if @playerw.myid?(id_)
  end

  # 対局者の名前を得る
  #
  # @param sente true: 先手名, false: 後手名
  def playername(sente)
    sente ? @playerb.name : @playerw.name
  end

  # 手番の対局者の情報を得る
  #
  # @return 対局者の情報 { id: id, name: nm, mail: em }
  def getnextplayer
    return @playerb.genhash if senteban?

    return @playerw.genhash if goteban?
  end

  # 対局生成者名と生成日時のセット
  #
  # @param data 対局設定者の情報
  # @option creator 対局生成者名
  # @option dt_created 生成日時
  def setcreator_d(data)
    setcreator(data[:creator], data[:dt_created])
  end

  # 対局設定者の情報のセットと初期最終着手日時のセット
  #
  # @param name 対局設定者の名前
  # @param datm 生成時刻
  def setcreator(name, datm)
    @creator = name
    @dt_created = datm
    @dt_lastmove = datm
  end

  # 着手情報のセット
  #
  # @param data ハッシュ
  # @option lastmove 着手情報文字列
  # @option dt_lastmove [String] 着手日時文字列 'yyyy/mm/dd hh:mm:dd'
  def setlastmove_d(data)
    setlastmove(data[:lastmove], data[:dt_lastmove])
  end

  # 着手情報のセット
  #
  # @param mov 着手情報文字列
  # @param datm [String] 着手日時文字列 'yyyy/mm/dd hh:mm:dd'
  def setlastmove(mov, datm)
    @lastmove = mov unless mov !~ /^[+-]/
    @dt_lastmove = datm
  end

  # sfenから得られる情報のセット
  #
  # @param sfenstr sfen文字列
  # @param items   [teban, tegoma, nth]
  def setsfen(sfenstr, items)
    @sfen = sfenstr
    @turn = @teban = items[1]
    @tegoma = items[2]
    @nth = items[3]
  end

  # sfen to parameters with minimal syntax check.
  # teban and nth are also checked if strict is true.
  #
  # @param sfenstr sfen文字列
  # @param strict trueのとき厳しくチェック
  def fromsfen(sfenstr, strict = false)
    item = sfenstr.split(' ')

    return if item.length != 4

    return unless MatchInfoFileUtil.checksfen(item[0])

    return if strict && MatchInfoFileUtil.invalid_sfenitem?(item, @teban, @nth)

    setsfen(sfenstr, item)
  end

  # 持ち時間の初期化
  #
  # @param ttm 持ち時間
  # @param byou 秒読み
  # @param exc 考慮時間回数
  # @param ext 考慮時間/回
  def initmochijikan(ttm, byou, exc, ext)
    @playerb.setmochijikan(thinktime: ttm, extracount: exc)
    @playerw.setmochijikan(thinktime: ttm, extracount: exc)
    @maxbyouyomi = byou
    @byouyomi = byou
    @extratime = ext
  end

  # 先手の持ち時間の設定
  #
  # @param ttm 持ち時間
  # @param exc 考慮時間回数
  def setmochijikanb(ttm, exc)
    @playerb.setmochijikan(thinktime: ttm, extracount: exc)
  end

  # 後手の持ち時間の設定
  #
  # @param ttm 持ち時間
  # @param exc 考慮時間回数
  def setmochijikanw(ttm, exc)
    @playerw.setmochijikan(thinktime: ttm, extracount: exc)
  end

  # 先手番かどうか
  # @return teban == 'b'
  def senteban?
    teban == 'b'
  end

  # 後手番かどうか
  # @return teban == 'w'
  def goteban?
    teban == 'w'
  end

  # 持ち時間の設定
  #
  # @param data 持ち時間情報
  def setmochijikans(data)
    @dt_lasttick = data[:dt_lasttick] # 持ち時間最終確認時刻
    @maxbyouyomi = data[:maxbyouyomi] # 秒読み設定
    @extratime = data[:extratime] # 考慮時間１回の時間
    @byouyomi = data[:byouyomi]
    @playerb.setmochijikan(data[:thinktimeb])
    @playerw.setmochijikan(data[:thinktimew])
  end

  # 秒読みと最終確認時間の設定
  #
  # @param byou 秒読み
  # @param dt_lt 最終確認時間
  def setlasttick(byou, dt_lt)
    @byouyomi = byou
    @dt_lasttick = dt_lt
  end

  # 秒読みの充填と最終確認時間の設定
  #
  # @param dt_lt 最終確認時間
  def fill_byouyomi(dt_lt)
    setlasttick(@maxbyouyomi, dt_lt)
  end

  # 対局終了フラグのセットと勝ち負けの記入
  #
  # @param per100_text %から始まる文字列。%は抜き。
  #        %TORYOであれば'TORYO'など。
  #        %TORYOであれば@tebanにより勝敗を@turnに、
  #        それ以外であれば@turnに。引き分けを入れる。
  def done_game_sp(per100_text)
    @log.debug("done_game_sp(#{per100_text})")
    @finished = true
    return @turn = 'd' if per100_text != 'TORYO' # 引き分け

    # @log.debug("if per100_text != 'TORYO' -> 'd'")
    @turn = 'fb' # 先手勝ち
    @turn = 'fw' if senteban? # 後手勝ち
    # @teban = 'f'
  end

  # 対局終了フラグのセットと勝ち負けの記入
  def done_game_gyoku
    @finished = true
    # @teban = 'f'
    # 後手勝ち 'fw'  先手勝ち 'fb'
    @turn = senteban? ? 'fw' : 'fb'
  end

  # 引き分けの提案の情報を処理する
  #
  # @param txt DRAW(YES|NO)(b|w),
  # @param datm [String] 着手日時文字列 'yyyy/mm/dd hh:mm:dd'
  #
  # @return true when both @drawb and draww are 'YES'
  def suggestdraw(txt, datm)
    @log.debug("suggestdraw(#{txt}, #{datm})")
    res = txt[4]
    @drawb = res if txt[-1] == 'b'
    @draww = res if txt[-1] == 'w'
    @log.debug("suggestdraw(#{@drawb}, #{@draww}), #{res}")
    @drawb == 'Y' && @draww == 'Y'
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
  # @param data ハッシュオブジェクト { gid:, creator:, dt_created:, idb:, playerb:,
  #         idw:, playerw:, sfen:, lastmove:, dt_lastmove:, finished:, turn:,
  #         byouyomi: { dt_lasttick:, maxbyouyomi: , extratime:, byouyomi:,
  #         thinktimeb: { thinktime:, extracount: }, thinktimew:{ thinktime:,
  #         extracount: } } }
  def read_data(data)
    setcreator_d(data)
    setplayers_d(data)
    fromsfen(data[:sfen])
    setlastmove_d(data)
    @finished = data[:finished] || false
    # @teban = 'f' if @finished
    # @turn = data[:turn] || @teban
    @drawb = data[:drawb] || 'N'
    @draww = data[:draww] || 'N'
    byou = data[:byouyomi]
    setmochijikans(byou) if byou

    # @log.debug(data) if @log
    # @log.debug(genhash) if @log
  end

  # ファイルからデータの読み込み
  #
  # @param path ファイルパス
  #
  # @return nil if invalid, otherwise successful.
  def read(path)
    data = YAML.load_file(path)

    @gid = data[:gid]
    return nil unless @gid

    read_data(data)

    # self
    # rescue
    # nil
  end

  # ハッシュにして返す
  #
  # @return ハッシュオブジェクト { gid:, creator:, dt_created:, idb:, playerb:,
  #         idw:, playerw:, sfen:, lastmove:, dt_lastmove:, finished:, turn:,
  #         byouyomi: { dt_lasttick:, maxbyouyomi: , extratime:, byouyomi:,
  #         thinktimeb: { thinktime:, extracount: }, thinktimew:{ thinktime:,
  #         extracount: } } }
  def genhash
    {
      gid: @gid, creator: @creator, dt_created: @dt_created,
      idb: @playerb.id, playerb: @playerb.name,
      idw: @playerw.id, playerw: @playerw.name, sfen: @sfen,
      lastmove: @lastmove, dt_lastmove: @dt_lastmove, finished: @finished,
      turn: @turn,
      drawb: @drawb, draww: @draww,
      byouyomi: {
        dt_lasttick: @dt_lasttick, # 持ち時間最終確認時刻
        maxbyouyomi: @maxbyouyomi, # 秒読みの設定時間
        extratime: @extratime, # 考慮時間１回の設定時間
        byouyomi: @byouyomi, # カウント中の秒読み
        thinktimeb: @playerb.gentimehash,
        thinktimew: @playerw.gentimehash
      }
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

  # 持ち時間の更新
  #
  # @param tmkp TimeKeeperオブジェクト
  # @param path 保存ファイルパス
  def update_time(tmkp, path)
    setlasttick(tmkp.byouyomi, tmkp.dt_lasttick)
    puts "@mif.setlasttick(#{tmkp.byouyomi}, #{tmkp.dt_lasttick})"
    case @turn
    when 'b' then setmochijikanb(tmkp.thinktime, tmkp.extracount)
    when 'w' then setmochijikanw(tmkp.thinktime, tmkp.extracount)
    else return
    end

    write(path)
  end

  # vs形式の文字列の生成
  #
  # @return vs形式の文字列
  def to_vs
    "#{@playerb.name} vs #{@playerw.name}"
  end

  # ダウンロードファイル名の生成と
  # 棋譜のダウンロードページのヘッダ文字列の生成
  #
  # @param ext 拡張子
  # @return ヘッダ文字列
  def build_header2dl(ext)
    dt = @dt_lastmove.delete('/:').sub(' ', '_')
    fn = "#{@playerb.name}_#{@playerw.name}_#{dt}.#{ext}"

    "Content-type: application/octet-stream\n" \
    "Content-Disposition: attachment; filename='" \
    "#{MatchInfoFileUtil.escape_fn(fn)}'; " \
    "filename*=UTF-8''#{MatchInfoFileUtil.escape_fnu8(fn)}\n\n"
  end
end
