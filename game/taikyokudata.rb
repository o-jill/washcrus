# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'digest/sha2'
require 'time'
require 'uri'
require 'logger'

require './file/chatfile.rb'
require './file/jsonkifu.rb'
require './file/jsonconsump.rb'
require './file/matchinfofile.rb'
require './file/mylock.rb'
require './file/pathlist.rb'
require './file/sfenstore.rb'
require './file/taikyokufile.rb'
require './file/userchatfile.rb'
require './file/userinfofile.rb'
require './game/gentaikyoku.rb'
require './game/timekeeper.rb'
require './util/myerror.rb'

# 対局情報クラス
class TaikyokuData
  include MyLock
  # 初期化
  def initialize
    # @idb = '', @playerb = '', @emailb = ''
    setplayerb('', '', '')
    # @idw = '', @playerw = '', @emailw = ''
    setplayerw('', '', '')
    @creator = '' # "name(email)"
    @gid = 'ididididid'
    @datetime = 'yyyy/mm/dd hh:mm:ss'
    # @turn = "F"
    # @nthmove = -1
    @log = nil
  end

  # @!attribute [r] idb
  #   @return 先手の対局者ID
  # @!attribute [r] idw
  #   @return 後手の対局者ID
  # @!attribute [r] playerb
  #   @return 先手の対局者名
  # @!attribute [r] playerw
  #   @return 後手の対局者名
  # @!attribute [r] emailb
  #   @return 先手の対局者メアド
  # @!attribute [r] emailw
  #   @return 後手の対局者メアド
  # @!attribute [r] gid
  #   @return 対局ID
  # @!attribute [r] datetime
  #   @return 生成日時文字列
  # @!attribute [r] taikyokupath
  #   @return 対局情報ディレクトリのパス
  # @!attribute [r] matchinfopath
  #   @return 対局情報ファイルのパス
  # @!attribute [r] chatpath
  #   @return チャットデータファイルのパス
  # @!attribute [r] kifupath
  #   @return jkfファイルのパス
  # @!attribute [r] sfenpath
  #   @return sfenファイルのパス
  # @!attribute [r] lockpath
  #   @return lockファイルのパス
  # @!attribute [r] mif
  #   @return　MatchInfoFileオブジェクト
  # @!attribute [r] jkf
  #   @return JsonKifuオブジェクト
  attr_reader :idb, :playerb, :emailb, :idw, :playerw, :emailw, :gid, :datetime,
              :taikyokupath, :matchinfopath, :chatpath, :kifupath, :sfenpath,
              :lockpath, :mif, :jkf

  # @!attribute [rw] log
  #   @return ログオブジェクト
  # @!attribute [rw] creator
  #   @return [String] 対局生成者情報 'name(email)'
  attr_accessor :creator, :log

  RES_NEXT = 0  # まだまだ続ける
  RES_OVER = 1  # 玉を取って終局
  RES_DRAW = -1 # 引き分け提案
  RES_ERR = -2  # エラー
  TXT_RES = %w[RES_ERR RES_DRAW RES_NEXT RES_OVER].freeze

  # 先手のセット
  #
  # @param id ID
  # @param name 名前
  # @param email メールアドレス
  def setplayerb(id, name, email)
    @idb = id
    @playerb = name
    @emailb = email
  end

  # 後手のセット
  #
  # @param id ID
  # @param name 名前
  # @param email メールアドレス
  def setplayerw(id, name, email)
    @idw = id
    @playerw = name
    @emailw = email
  end

  # 先後手の交換
  def switchplayers
    @idb, @idw = @idw, @idb

    @playerb, @playerw = @playerw, @playerb

    @emailb, @emailw = @emailw, @emailb
  end

  # 対局IDのセット
  #
  # @param id_ 対局ID
  def setid(id_)
    @gid = id_
    @taikyokupath = PathList::TAIKYOKUDIR + id_ + '/'
    @matchinfopath = @taikyokupath + PathList::MATCHFILE
    @chatpath = @taikyokupath + PathList::CHATFILE
    @kifupath = @taikyokupath + PathList::KIFUFILE
    @sfenpath = @taikyokupath + PathList::SFENFILE
    @lockpath = @taikyokupath + PathList::GAMELOCK
  end

  # 対局情報のDBへの登録
  #
  # @param teban 手番
  # @param cmt コメント
  def register_taikyoku(teban, cmt)
    newdt = [@gid, @idb, @idw, @playerb, @playerw, teban, @datetime, cmt]

    # @log.debug('TaikyokuFile.new')
    TaikyokuFile.new.newgame(newdt.dup)

    # @log.debug('TaikyokuChuFile.new')
    TaikyokuChuFile.new.newgame(newdt)
  end

  # 発言者、対局者x2のデータにも書く
  #
  # @param addedmsg 発言
  def write2chatview(addedmsg)
    mif.getplayerids.each do |userid|
      uchat = UserChatFile.new(userid)
      uchat.read
      uchat.add(addedmsg, @gid)
    end
  end

  # initialize match information file
  def init_mif
    # @log.debug('MatchInfoFile.new(gid)')
    @mif = MatchInfoFile.new(@gid)
    @mif.setplayers(@idb, @idw)
    @mif.setcreator(@creator, @datetime)
    @mif.initmochijikan(0, 259_200, 20, 86_400) # 持ち時間なし、1手3日、考慮日数20日
    @mif.write(@matchinfopath)
  end

  # 対局情報ファイルの初期情報の書き込み
  # 棋譜情報ファイルの初期情報の書き込み
  # チャットファイルの初期情報の書き込み
  # sfenログのの初期情報の書き込み
  def init_files
    # initialize match information file
    init_mif

    # kifu file
    @jkf = JsonKifu.new(@gid)
    @jkf.setheader('持ち時間', '持ち時間0秒、1手3日、考慮日数20日')
    @jkf.setbothsengo('考慮日数', '20日')
    @jkf.initial_write(@playerb, @playerw, @datetime, @kifupath)

    # chat file
    chat = ChatFile.new(@gid)
    write2chatview(chat.say_start(@playerb))

    # sfen log
    sfs = SfenStore.new(@sfenpath)
    sfs.add(@mif.sfen)
  end

  # 対局情報の生成
  # ファイルなどの準備もします。
  #
  # @param cmt コメント
  def generate(cmt)
    # @log.debug('Time.now.strftime')
    # 生成日時
    @datetime = Time.now.strftime('%Y/%m/%d %H:%M:%S')

    # @log.debug('id = genid')
    # 対局ID
    id = genid
    return print "generation failed...\n" unless id

    setid(id)

    # @log.debug('GenTaikyokuData.new(self)')
    # フォルダとかファイルとかの生成
    gentd = GenTaikyokuData.new(self)
    # gentd.log = log
    gentd.generate

    # 対局情報のDBへの登録
    register_taikyoku('b', cmt)

    init_files
  end

  # 対局情報の生成
  # ファイルなどの準備はしません。
  # def checkgenerate
  #   # 生成者
  #   @creator = 'nanashi' if creator.nil?
  #   # 生成日時
  #   @datetime = Time.now.strftime('%Y/%m/%d %H:%M:%S')
  #   # 対局ID
  #   setid(genid)
  # end

  # 先手の情報が正しいかの確認。ブランクチェック。
  #
  # @return 先手の情報が正しいときfalse
  def playerbng?
    @idb == '' || @playerb == '' || @emailb == ''
  end

  # 後手の情報が正しいかの確認。ブランクチェック。
  #
  # @return 後手の情報が正しいときfalse
  def playerwng?
    @idw == '' || @playerw == '' || @emailw == ''
  end

  # 対局IDの生成
  #
  # @return 対局ID
  def genid
    return nil if playerbng? || playerwng? || creator == ''

    id_raw = "#{playerb}_#{emailb}_#{playerw}_#{emailw}_#{creator}_#{datetime}"
    id = Digest::SHA256.hexdigest id_raw
    id[0, 10]
  end

  # usage:
  # lockex do
  #   do_something
  # end
  def lockex
    lock(lockpath) do
      yield
    end
  end

  # 対局情報の読み込み
  #
  # @return self
  def read
    # データを読み込んで
    @mif = MatchInfoFile.new(@gid)
    @mif.log = @log
    @mif.read(matchinfopath) # return nil unless @mif.read(matchinfopath)
    @idb = @mif.playerb.id
    @idw = @mif.playerw.id
    @jkf = JsonKifu.new(@gid)
    @jkf.read(kifupath) # return nil unless @jkf.read(kifupath)
    # @chat = ChatFile.new(@gameid)
    # @chat.read()
    # self
  end

  # 対局情報の書き出し
  def write
    # @log.debug('Move.mif.write')
    @mif.write(@matchinfopath)

    # @log.debug('Move.jkf.write')
    @jkf.write(@kifupath)
  end

  # 棋譜のの出力
  #
  # @param type 棋譜形式 'csa','kif','kifu'
  def show_converted_kifu(type)
    case type
    when 'kif'  then puts @jkf.to_kif  # KIF形式の棋譜の出力
    when 'kifu' then puts @jkf.to_kifu # KIFU形式の棋譜の出力
    when 'csa'  then puts @jkf.to_csa  # CSA形式の棋譜の出力
    end
  end

  # 棋譜のダウンロードページの出力
  #
  # @param type 棋譜形式 'csa','kif','kifu'
  def download_kifu_file(type)
    puts @mif.build_header2dl(type)
    show_converted_kifu(type)
  end

  # 引き分け提案の処理
  #
  # @param cmd 'DRAWYb'とか
  # @param datm 着手時間オブジェクト
  #
  # @return RES_DRAW:引き分け提案了承, RES_OVER:引き分け終局
  def procsystem_draw(cmd, datm)
    ret = RES_DRAW
    ret = RES_OVER if @mif.suggestdraw(cmd, datm)
    @mif.write(@matchinfopath)

    # chat file
    chat = ChatFile.new(@gid)
    @log.debug("chat.say_sugdraw(sente = #{cmd[-1]} == 'b')")
    write2chatview(
      chat.say_sugdraw(@mif.playername(cmd[-1] == 'b'), cmd[4] == 'Y')
    )

    ret
  end

  # 引き分け提案などを処理する
  #
  # @param jsmv JsonMoveオブジェクト
  # @param datm 着手時間オブジェクト
  #
  # @retval RES_DRAW 引き分け提案了承
  # @retval RES_OVER 引き分け終局
  # @return [true if ret is RES_ERR or RES_DRAW, RES_ERR, RES_DRAW or RES_OVER]
  def procsystem(jsmv, datm)
    @log.debug("procsystem(#{jsmv}, #{datm})")
    cmd = jsmv[:system]
    ret = RES_ERR
    ret = procsystem_draw(cmd, datm) if /^DRAW/ =~ cmd
    [[RES_ERR, RES_DRAW].include?(ret), ret]
  end

  # 指し手の記録。千日手のチェックとかもやる。
  #
  # @param sfen sfen文字列
  # @param jsmv JsonMoveオブジェクト
  # @param datm 着手時間オブジェクト
  #
  # @return nil if invalid, RES_OVER if done, otherwise RES_NEXT.
  def recordmove(sfen, jsmv, datm)
    sfs = SfenStore.new(@sfenpath)
    sfs.add(sfen)

    return unless @mif.fromsfen(sfen, true)

    jc = calc_consumption(datm)

    # @log.debug("@jkf.move(jsmv, #{jc.genhash})")
    # @jkf.log = @log
    @jkf.move(jsmv, jc.genhash, ["着手日時：#{datm}"])
    # @log.debug('@jkf.moved(jsmv, jc.genhash)')

    return finish_sennnichite if sfs.sennichite?(sfen)

    finish_if_catch_gyoku(jsmv)
  end

  # １手指す
  #
  # @param sfen sfen文字列
  # @param jsmv JsonMoveオブジェクト
  # @param datm 着手時間オブジェクト
  #
  # @return nil if invalid, RES_OVER if done, otherwise RES_NEXT.
  def move(sfen, jsmv, datm)
    @log.debug("Taikyokudata.move(jsmv, #{datm})")
    @mif.log = @log

    # 引き分け提案とか
    ret, status = procsystem(jsmv, datm) if jsmv[:system]
    @log.debug("ret:#{ret}, status:#{TXT_RES[status + 2]}") if status
    return status if ret

    jsmv[:special] = 'HIKIWAKE' if status == RES_OVER
    return finish_special(jsmv) if jsmv[:special]

    recordmove(sfen, jsmv, datm)
  end

  # 最新着手の更新
  # @param movestr 着手内容文字列
  # @param now 着手日時オブジェクト
  def updatelastmove(movestr, now)
    @mif.setlastmove(movestr[0, 7], now.strftime('%Y/%m/%d %H:%M:%S'))
    @mif.fill_byouyomi(now)
  end

  # 消費時間の計算
  #
  # @param datm 着手時間オブジェクト
  # @return 計算済み消費時間計算オブジェクト
  def calc_consumption(datm)
    jc = JsonConsumption.new
    # @log.debug('jc.settotal if @jkf.last_time')
    total = @jkf.last_time
    # totalstr = total.nil? ? 'nil' : total.to_s
    # @log.debug("total:#{totalstr}")
    jc.settotal(total['total']) if total
    # @log.debug("Time.parse(#{@mif.dt_lastmove})")
    t_last = Time.parse(@mif.dt_lastmove)
    # @log.debug('jc.diff(datm, t_last)')
    jc.diff(datm, t_last)
    jc
  end

  # 特殊文字での終局。投了とか。
  #
  # @param jsmv JsonMoveオブジェクト
  # @return 1:投了などで終局
  def finish_special(jsmv)
    @log.debug("if jsmv[:special](=#{jsmv[:special]})")
    @jkf.move(jsmv)
    @mif.done_game_sp(jsmv[:special])
    RES_OVER
  end

  # 千日手で終了
  def finish_sennnichite
    @mif.done_game_sp('SENNICHITE')
    @jkf.sennichite
    RES_OVER
  end

  # 玉を取って終局の処理
  #
  # @param jsmv JsonMoveオブジェクト
  # @return RES_NEXT:まだまだ続ける, RES_OVER:玉を取って終局
  def finish_if_catch_gyoku(jsmv)
    if JsonMove.catch_gyoku?(jsmv)
      @mif.done_game_gyoku
      @jkf.resign
      return RES_OVER
    end
    RES_NEXT
  end

  # 対局の終了処理
  # 対局終了日時のセット
  # 勝敗の記入(勝った方と負けた方に１加算)
  #
  # @param datm [Time] 終局時刻
  # @param gwin [Boolean] 後手勝ちの時true
  # @param turn [String] 終局情報文字
  #
  # @note draw非対応
  def finished(datm, gwin, turn)
    # 対局終了日時のセット
    @log.debug('@jkf.setfinishdate()')
    @jkf.setfinishdate(datm.strftime('%Y/%m/%d %H:%M:%S'))

    @mif.turn = turn

    # 勝敗の記入(買った方と負けた方に１加算)
    # userdb読み込み
    @log.debug('userdb = UserInfoFile.new')
    userdb = UserInfoFile.new
    return userdb.give_draw(@idb, @idw) if turn == 'd'

    userdb.give_win_lose(gwin, @idb, @idw)
  end

  # 対局の終了処理
  # 対局終了日時のセット
  # 勝敗の記入(勝った方と負けた方に１加算)
  #
  # @param datm [Time] 終局時刻
  # @param turn [String] 終局情報文字 fb fw d
  #
  # @note draw非対応
  def forcefinished(datm, turn)
    # 対局終了日時のセット
    # @log.debug('@jkf.setfinishdate()')
    @jkf.setfinishdate(datm.strftime('%Y/%m/%d %H:%M:%S'))

    @mif.turn = turn

    # 勝敗の記入(買った方と負けた方に１加算)
    # userdb読み込み
    # @log.debug('userdb = UserInfoFile.new')
    userdb = UserInfoFile.new
    return userdb.give_draw(@idb, @idw) if turn == 'd'

    userdb.give_win_lose(turn == 'fw', @idb, @idw)
  end

  # 持ち時間の更新
  #
  # @param tmkp TimeKeeperオブジェクト
  def update_time(tmkp)
    @mif.update_time(tmkp, @matchinfopath)

    if tmkp.houchi.nonzero?
      case @mif.turn
      when 'b'
        @jkf.setheader('先手考慮日数', "#{tmkp.extracount}日")
      when 'w'
        @jkf.setheader('後手考慮日数', "#{tmkp.extracount}日")
      else return
      end
    end

    @jkf.write(@kifupath)
  end

  # 時間の確認
  #
  # @param tmkp TimeKeeperオブジェクト
  def tick(tmkp)
    case @mif.turn
    when 'b' then ply = @mif.playerb
    when 'w' then ply = @mif.playerw
    else return
    end

    # puts "tmkp.read(#{ply.thinktime}, #{@mif.byouyomi}," \
    #                 "#{ply.extracount}, #{@mif.dt_lasttick})"
    tmkp.read(ply.thinktime, @mif.byouyomi, ply.extracount, @mif.dt_lasttick)

    # puts "tmkp.tick(Time.now #{Time.now})"
    tmkp.tick(Time.now)

    update_time(tmkp)
  end

  # 内容のダンプ
  def dump
    print <<-DUMP
      taikyoku-id:#{@gid}\ncreator: #{@creator}\ndatetime: #{@datetime}
      idb:#{@idb}\nplayerb: #{@playerb}\nemailb: #{@emailb}
      idw:#{@idw}\nplayerw: #{@playerw}\nemailw: #{@emailw}
    DUMP
  end

  # table形式の内容のダンプ
  def dumptable
    print <<-DUMP
      <TABLE>
      <TR><TD>taikyoku-id</TD><TD>#{@gid}</TD></TR>
      <TR><TD>creator</TD><TD>#{@creator}</TD></TR>
      <TR><TD>datetime</TD><TD>#{@datetime}</TD></TR>
      <TR><TD>playerb</TD><TD>#{@playerb}</TD></TR>
      <TR><TD>emailb</TD><TD>#{@emailb}</TD></TR>
      <TR><TD>playerw</TD><TD>#{@playerw}</TD></TR>
      <TR><TD>emailw</TD><TD>#{@emailw}</TD></TR>
      </TABLE>
    DUMP
  end

  # table形式の内容のダンプ
  def dumptableex
    print <<-DUMP
      <TABLE>
      <TR><TD>対局ID</TD><TD>#{@gid}</TD></TR>
      <TR><TD>対局生成者</TD><TD>#{@creator}</TD></TR>
      <TR><TD>生成日時</TD><TD>#{@datetime}</TD></TR>
      <TR><TD>先手</TD><TD>#{@playerb}</TD></TR>
      <TR><TD>後手</TD><TD>#{@playerw}</TD></TR>
      </TABLE>
    DUMP
  end
end
