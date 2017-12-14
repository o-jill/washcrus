# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'time'
require 'uri'
require 'logger'

require './file/chatfile.rb'
require './file/jsonkifu.rb'
require './file/jsonconsump.rb'
require './file/matchinfofile.rb'
require './file/pathlist.rb'
require './file/sfenstore.rb'
require './file/taikyokufile.rb'
require './file/userinfofile.rb'
require './game/gentaikyoku.rb'

# 対局情報クラス
class TaikyokuData
  # 初期化
  def initialize
    # @id1 = '', @player1 = '', @email1 = ''
    setplayer1('', '', '')
    # @id2 = '', @player2 = '', @email2 = ''
    setplayer2('', '', '')
    @creator = '' # "name(email)"
    @gid = 'ididididid'
    @datetime = 'yyyy/mm/dd hh:mm:ss'
    # @turn = "F"
    # @nthmove = -1
    @log = nil
  end

  attr_reader :id1, :player1, :email1, :id2, :player2, :email2, :gid, :datetime,
              :taikyokupath, :matchinfopath, :chatpath, :kifupath, :sfenpath,
              :mi, :jkf
  attr_accessor :creator, :log

  # DIRPATH = './taikyoku/'.freeze
  # CHATFILE = 'chat.txt'.freeze
  # MATCHFILE = 'matchinfo.txt'.freeze
  # KIFUFILE = 'kifu.jkf'.freeze
  # SFENFILE = 'sfenlog.txt'.freeze

  # 先手のセット
  #
  # @param id ID
  # @param nm 名前
  # @param em メールアドレス
  def setplayer1(id, nm, em)
    @id1 = id
    @player1 = nm
    @email1 = em
  end

  # 後手のセット
  #
  # @param id ID
  # @param nm 名前
  # @param em メールアドレス
  def setplayer2(id, nm, em)
    @id2 = id
    @player2 = nm
    @email2 = em
  end

  # 先後手の交換
  def switchplayers
    @id1, @id2 = @id2, @id1

    @player1, @player2 = @player2, @player1

    @email1, @email2 = @email2, @email1
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
  end

  # 対局情報のDBへの登録
  #
  # @param teban 手番
  # @param cmt コメント
  def register_taikyoku(teban = 'b', cmt = 'blank')
    # @log.debug('TaikyokuFile.new')
    tdb = TaikyokuFile.new
    tdb.read
    tdb.add([@gid, @id1, @id2, @player1, @player2, teban, @datetime, cmt])
    tdb.append(@gid)

    # @log.debug('TaikyokuChuFile.new')
    tcdb = TaikyokuChuFile.new
    tcdb.read
    tcdb.add([@gid, @id1, @id2, @player1, @player2, teban, @datetime, cmt])
    tcdb.append(@gid)
  end

  # 対局情報ファイルの初期情報の書き込み
  # 棋譜情報ファイルの初期情報の書き込み
  # チャットファイルの初期情報の書き込み
  # sfenログのの初期情報の書き込み
  def init_files
    # @log.debug('MatchInfoFile.new(gid)')
    # match information file
    @mi = MatchInfoFile.new(@gid)
    @mi.initial_write(@id1, @id2, @creator, @datetime, @matchinfopath)

    # kifu file
    @jkf = JsonKifu.new(@gid)
    @jkf.initial_write(@player1, @player2, @datetime, @kifupath)

    # chat file
    chat = ChatFile.new(@gid)
    chat.say_start(@player1)

    # sfen log
    sfs = SfenStore.new(@sfenpath)
    sfs.add(@mi.sfen)
  end

  # 対局情報の生成
  # ファイルなどの準備もします。
  def generate
    # @log.debug('Time.now.strftime')
    # 生成日時
    @datetime = Time.now.strftime('%Y/%m/%d %H:%M:%S')

    # @log.debug('id = genid')
    # 対局ID
    id = genid
    return print "generation failed...\n" if id.nil?
    setid(id)

    # @log.debug('GenTaikyokuData.new(self)')
    # フォルダとかファイルとかの生成
    gentd = GenTaikyokuData.new(self)
    # gentd.log = log
    gentd.generate

    # 対局情報のDBへの登録
    register_taikyoku

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

  # 先手の情報が正しいかの確認。nilとブランクチェック。
  #
  # @return 先手の情報が正しいときtrue
  def player1ng?
    player1.nil? || player1 == '' || email1.nil? || email1 == ''
  end

  # 後手の情報が正しいかの確認。nilとブランクチェック。
  #
  # @return 先手の情報が正しいときtrue
  def player2ng?
    player2.nil? || player2 == '' || email2.nil? || email2 == ''
  end

  # 対局IDの生成
  #
  # @return 対局ID
  def genid
    return nil if player1ng?
    return nil if player2ng?
    return nil if creator.nil? || creator == ''

    id_raw = "#{player1}_#{email1}_#{player2}_#{email2}_#{creator}_#{datetime}"
    id = Digest::SHA256.hexdigest id_raw
    id[0, 10]
  end

  # 対局情報の読み込み
  #
  # @return self
  def read
    # データを読み込んで
    @mi = MatchInfoFile.new(@gid)
    return nil if @mi.read(matchinfopath).nil?
    @id1 = @mi.idb
    @id2 = @mi.idw
    @jkf = JsonKifu.new(@gid)
    return nil if @jkf.read(kifupath).nil?
    # @chat = ChatFile.new(@gameid)
    # @chat.read()
    self
  end

  # 対局情報の書き出し
  def write
    # @log.debug('Move.mi.write')
    @mi.write(@matchinfopath)

    # @log.debug('Move.jkf.write')
    @jkf.write(@kifupath)
  end

  # ファイル名に使えない文字の変換
  # _に変換
  #
  # @param fname 対象文字列
  # @return 変換結果文字列
  def escape_fn(fname)
    path = fname.gsub(%r{[\\\/*:<>?|]}, '_')
    URI.escape(path)
  end

  # ファイル名に使えない文字の変換
  # 全角に変換
  #
  # @param fname 対象文字列
  # @return 変換結果文字列
  def escape_fnu8(fname)
    path = fname.gsub(%r{[\\/*:<>?|]},
                      '\\' => '￥', '/' => '／', '*' => '＊', ':' => '：',
                      '<' => '＜', '>' => '＞', '?' => '？', '|' => '｜')
    URI.escape(path)
  end

  # 棋譜のダウンロードページのヘッダ文字列の生成
  #
  # @param fn ファイル名
  # @return ヘッダ文字列
  def build_header2dl(fn)
    "Content-type: application/octet-stream\n" \
    "Content-Disposition: attachment; filename='#{escape_fn(fn)}'; " \
    "filename*=UTF-8''#{escape_fnu8(fn)}\n\n"
  end

  # CSA形式の棋譜のダウンロードページの出力
  def download_csa
    filename = @mi.build_fn2dl('csa')

    puts build_header2dl(filename)
    puts @jkf.to_csa
  end

  # KIF形式の棋譜のダウンロードページの出力
  def download_kif
    filename = @mi.build_fn2dl('kif')

    puts build_header2dl(filename)
    puts @jkf.to_kif
  end

  # １手指す
  #
  # @param sfen sfen文字列
  # @param jsmv JsonMoveオブジェクト
  # @param dt   着手時間オブジェクト
  #
  # @return nil if invalid, 1 if done, otherwise 0.
  def move(sfen, jsmv, dt)
    @log.debug("Taikyokudata.move(jsmv, #{dt})")

    sfs = SfenStore.new(@sfenpath)
    sfs.add(sfen)

    return finish_special(jsmv) if jsmv[:special]

    @mi.log = @log
    return if @mi.fromsfen_strict(sfen).nil?
    # return if @mi.fromsfen(sfen).nil?

    jc = calc_consumption(dt)

    # @log.debug("@jkf.move(jsmv, #{jc.genhash})")
    # @jkf.log = @log
    @jkf.move(jsmv, jc.genhash, ["着手日時：#{dt}"])
    # @log.debug('@jkf.moved(jsmv, jc.genhash)')

    finish_if_catch_gyoku(jsmv)
  end

  # 最新着手の更新
  # @param movestr 着手内容文字列
  # @param now 着手日時オブジェクト
  def setlastmove(movestr, now)
    @mi.setlastmove_dt(movestr[0, 7], now)
  end

  # 消費時間の計算
  #
  # @param dt 着手時間オブジェクト
  # @return 計算済み消費時間計算オブジェクト
  def calc_consumption(dt)
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
    jc
  end

  # 特殊文字での終局。投了とか。
  #
  # @param jsmv JsonMoveオブジェクト
  # @return 1:投了などで終局
  def finish_special(jsmv)
    @log.debug('if jsmv[:special]')
    @jkf.move(jsmv)
    @mi.done_game_sp(jsmv[:special])
    1
  end

  # 玉を取って終局の処理
  #
  # @param jsmv JsonMoveオブジェクト
  # @return 0:まだまだ続ける, 1:玉を取って終局
  def finish_if_catch_gyoku(jsmv)
    if JsonMove.catchOU?(jsmv)
      @mi.done_game_gyoku
      @jkf.resign
      1
    else
      0
    end
  end

  # 勝敗の記入(勝った方と負けた方に１加算)
  #
  # @param udb  ユーザDBオブジェクト
  # @param gwin 後手勝ちの時true
  def give_win_lose(udb, gwin)
    if gwin
      @log.debug("udb.win_lose(#{id2}, :gwin)")
      udb.win_lose(id1, :slose)
      udb.win_lose(id2, :gwin)
    else
      @log.debug("udb.win_lose(#{id1}, :swin)")
      udb.win_lose(id1, :swin)
      udb.win_lose(id2, :glose)
    end
  end

  # 対局の終了処理
  # 対局終了日時のセット
  # 勝敗の記入(勝った方と負けた方に１加算)
  #
  # @param dt [Time] 終局時刻
  # @param gwin [Boolean] 後手勝ちの時
  # @param turn [String] 終局情報文字
  def finished(dt, gwin, turn)
    # 対局終了日時のセット
    @log.debug('@jkf.setfinishdate()')
    @jkf.setfinishdate(dt.strftime('%Y/%m/%d %H:%M:%S'))

    @mi.turn = turn

    # 勝敗の記入(買った方と負けた方に１加算)
    # userdb読み込み
    @log.debug('userdb = UserInfoFile.new')
    userdb = UserInfoFile.new
    userdb.lock do
      userdb.read
      give_win_lose(userdb, gwin)
      # @log.debug('userdb.write')
      userdb.write
    end
  end

  # 内容のダンプ
  def dump
    print <<-DUMP
      taikyoku-id:#{@gid}\ncreator: #{@creator}\ndatetime: #{@datetime}
      id1:#{@id1}\nplayer1: #{@player1}\nemail1: #{@email1}
      id2:#{@id2}\nplayer2: #{@player2}\nemail2: #{@email2}
      DUMP
  end

  # table形式の内容のダンプ
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
