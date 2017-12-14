#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'logger'
require 'unindent'

require './file/jsonkifu.rb'
require './file/jsonmove.rb'
require './file/matchinfofile.rb'
require './file/pathlist.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'
require './util/mailmgr.rb'
require './util/settings.rb'

#
# CGI本体
#
class Move
  TEXTPLAIN_HEAD = "Content-Type: text/plain; charset=UTF-8\n\n".freeze

  # 初期化
  #
  # @param cgi CGIオブジェクト
  # @param stg グローバル設定
  def initialize(cgi, stg)
    @log = Logger.new(PathList::MOVELOG)
    # @log.level = Logger::INFO
    # @log.debug('Move.new()')
    @cgi = cgi
    read_cgiparam
    # @stg = stg
    @baseurl = stg.value['base_url']
    @turn = '?'
    @log.info("gameid:#{@gameid}")
    @log.info("sfen:#{@sfen}")
    @log.info("move:#{@move}")
    @jmv = JsonMove.fromtext(@move)
    @log.debug('Move.initialized')
  end

  # logging
  attr_reader :log

  # paramsから値の読み出し
  def read_cgiparam
    @params = @cgi.params
    @gameid = @cgi.query_string
    @sfen = @params['sfen'][0] unless @params['sfen'].nil?
    @move = @params['jsonmove'][0] unless @params['jsonmove'].nil?
  end

  # sessionの取得と情報の読み取り
  def readuserparam
    # @log.debug('Move.readuserparam')
    begin
      @session = CGI::Session.new(@cgi,
                                  'new_session' => false,
                                  'session_key' => '_washcrus_session',
                                  'tmpdir' => './tmp')
    rescue ArgumentError
      # @session = nil
      @log.info('failed to find session')
    end

    @userinfo = UserInfo.new
    @userinfo.readsession(@session) unless @session.nil?

    @header = @cgi.header('charset' => 'UTF-8')
    @header = @header.gsub("\r\n", "\n")
  end

  # 不正アクセスの表示
  def put_illegal_access
    print TEXTPLAIN_HEAD + 'illegal access.'
  end

  # 移動完了の表示
  def put_moved
    print TEXTPLAIN_HEAD + 'Moved.'
  end

  # 違反移動の表示
  def put_invalid_move
    print TEXTPLAIN_HEAD + 'invalid move.'
  end

  # ログインしてないエラーの表示
  def put_please_login
    print TEXTPLAIN_HEAD + 'please log in.'
  end

  # 情報のチェック
  def check_param
    tcdb = TaikyokuChuFile.new
    tcdb.read
    # 存在しないはずのIDだよ
    return put_illegal_access unless tcdb.exist_id(@gameid)

    # userinfoが変だよ
    return put_please_login unless @userinfo.exist_indb

    # moveが変だよ
    return put_invalid_move if @jmv.nil?

    self
  end

  # 対局終了メールのタイトルの生成
  def build_finishedtitle
    "the game was over. (#{@tkd.mi.to_vs})"
  end

  # 対局終了メールの本文の生成
  #
  # @param nowstr   現在の時刻の文字列
  # @param filename 添付ファイル名
  def build_finishedmsg(nowstr, filename)
    msg = <<-MSG_TEXT.unindent
      #{@tkd.mi.playerb.name}さん、 #{@tkd.mi.playerw.name}さん

      対局(#{@gameid})が#{nowstr}に終局しました。

      #{@baseurl}washcrus.rb?game/#{@gameid}

      attached:#{filename}

      MSG_TEXT
    msg += MailManager.footer
    msg
  end

  # 添付ファイル名の生成
  #
  # @param dt   現在の時刻の文字列
  def build_attachfilename(dt)
    "#{@tkd.mi.playerb.name}_#{@tkd.mi.playerw.name}_#{dt}.kif"
  end

  # 数字だけの時刻の文字列の生成
  def build_short_dt
    @tkd.mi.dt_lastmove.delete('/:').sub(' ', '_')
  end

  # 終局メールの生成と送信
  def send_mail_finished(nowstr)
    subject = build_finishedtitle
    # @log.debug("subject:#{subject}")

    dt = build_short_dt
    filename = build_attachfilename(dt)

    msg = build_finishedmsg(nowstr, filename)

    kifufile = {
      filename: @tkd.escape_fnu8(filename),
      content:  @tkd.jkf.to_kif
    }

    # @log.debug("msg:#{msg}")
    mi = @tkd.mi
    mmgr = MailManager.new
    mmgr.send_mailex(mi.playerb.email, subject, msg, kifufile)
    mmgr.send_mailex(mi.playerw.email, subject, msg, kifufile)
  end

  # 指されましたメールの本文の生成
  #
  # @param name   手番の人の名前
  # @param nowstr   現在の時刻の文字列
  def build_nextturnmsg(name, nowstr)
    msg = <<-MSG_TEXT.unindent
      #{name}さん

      #{@userinfo.user_name}さんが#{nowstr}に１手指されました。

      #{@baseurl}washcrus.rb?game/#{@gameid}

      MSG_TEXT
    msg += MailManager.footer
    msg
  end

  # 指されましたメールの生成と送信
  #
  # @param nowstr   現在の時刻の文字列
  def send_mail_next(nowstr)
    subject = "it's your turn!! (#{@tkd.mi.to_vs})"
    # @log.debug("subject:#{subject}")
    opp = @tkd.mi.getopponent(@userinfo.user_id)
    # @log.debug("opp:#{opp}")

    msg = build_nextturnmsg(opp[:name], nowstr)

    mmgr = MailManager.new
    mmgr.send_mail(opp[:mail], subject, msg)
  end

  # メールの送信
  #
  # @param finished [boolean] 終局したかどうか
  # @param now      [Time]    着手日時オブジェクト
  def send_mail(finished, now)
    @log.debug('Move.sendmail')
    @tkd.read
    nowstr = now.strftime('%Y/%m/%d %H:%M:%S')
    if finished
      send_mail_finished(nowstr)
    else
      send_mail_next(nowstr)
    end
  end

  # 対局中データベースの着手日時の更新
  #
  # @param tcdb   対局中データベース
  # @param now 現在の時刻オブジェクト
  def update_taikyokuchu_dt(tcdb, now)
    nowstr = now.strftime('%Y/%m/%d %H:%M:%S')
    @log.debug('tcdb.updatedatetime')
    tcdb.lock do
      tcdb.read
      tcdb.updatedatetime(@gameid, nowstr)
      tcdb.updateturn(@gameid, @turn)
      tcdb.write
    end
  end

  # 対局データベースの着手日時の更新
  #
  # @param now 現在の時刻オブジェクト
  def update_taikyoku_dt(now)
    @log.debug('tdb.updatedatetime')
    nowstr = now.strftime('%Y/%m/%d %H:%M:%S')
    tdb = TaikyokuFile.new
    tdb.lock do
      tdb.read
      tdb.updatedatetime(@gameid, nowstr)
      tdb.updateturn(@gameid, @turn)
      tdb.write
    end
  end

  # 対局終了処理
  #
  # @param tcdb   対局中データベース
  # @param now 現在の時刻オブジェクト
  def finish_game(tcdb, now)
    # 終了日時の更新とか勝敗の記録とか
    @log.debug("tkd.finished(now, #{@tkd.mi.teban} == 'b')")
    gote_win = (@tkd.mi.teban == 'b')
    @turn = gote_win ? 'fw' : 'fb'
    @tkd.finished(now, gote_win, @turn)
    # 対局中からはずす
    @log.debug('tcdb.finished(@gameid)')
    tcdb.finished(@gameid)
  end

  # 対局情報の読み出しなどといった準備
  def prepare_taikyokudata
    @tkd = TaikyokuData.new
    @tkd.log = @log
    @tkd.setid(@gameid)
    @tkd.read
  end

  # 対局情報の登録更新
  #
  # @param finished [boolean] 終局したかどうか
  # @param now      [Time]    着手日時オブジェクト
  def register_move(finished, now)
    @turn = @tkd.mi.teban

    tcdb = TaikyokuChuFile.new
    tcdb.read

    finish_game(tcdb, now) if finished

    # @log.debug('Move.setlastmove')
    @tkd.setlastmove(@move, now)

    # @log.debug('Move.mi.write')
    # @log.debug('Move.jkf.write')
    @tkd.write

    update_taikyokuchu_dt(tcdb, now) unless finished

    update_taikyoku_dt(now)

    send_mail(finished, now)

    put_moved
  end

  #
  # 実行本体。
  #
  def perform
    # gameid が無いよ
    return put_illegal_access if @gameid.nil?

    # userinfoが変だよ, moveが変だよ, 存在しないはずのIDだよ
    return if check_param.nil?

    @log.debug('Move.read data')
    prepare_taikyokudata

    now = Time.now

    # 指し手を適用する
    @log.debug('Move.apply sfen, jmv')
    # @tkd.move(@jmv, now)
    ret = @tkd.move(@sfen, @jmv, now)
    @log.debug("@tkd.move() = #{ret}")

    return put_invalid_move if ret.nil?

    register_move(ret == 1, now)

    @log.debug('Move.performed')
  end
end

# -----------------------------------
#   main
#

cgi = CGI.new
stg = Settings.instance
begin
  move = Move.new(cgi, stg)
  move.readuserparam
  move.perform
rescue ScriptError => e
  move.log.warn("class=[#{e.class}] message=[#{e.message}] in move")
rescue SecurityError => e
  move.log.warn("class=[#{e.class}] message=[#{e.message}] in move")
rescue => e
  move.log.warn("class=[#{e.class}] message=[#{e.message}] in move")
end
# -----------------------------------
#   testing
#
