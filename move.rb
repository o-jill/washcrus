#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'logger'
require 'unindent'

require './file/jsonkifu.rb'
require './file/jsonmove.rb'
require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'
require './util/mailmgr.rb'
require './util/settings.rb'

#
# CGI本体
#
class Move
  TEXTPLAIN_HEAD = "Content-Type: text/plain; charset=UTF-8\n\n".freeze

  def initialize(cgi, stg)
    @log = Logger.new('./log/movelog.txt')
    # @log.level = Logger::INFO
    # @log.debug('Move.new()')
    @cgi = cgi
    @params = cgi.params
    @gameid = cgi.query_string
    # @stg = stg
    @baseurl = stg.value['base_url']
    @log.info("gameid:#{@gameid}")
    @sfen = @params['sfen'][0] unless @params['sfen'].nil?
    @move = @params['jsonmove'][0] unless @params['jsonmove'].nil?
    @log.info("sfen:#{@sfen}")
    @log.info("move:#{@move}")
    @jmv = JsonMove.fromtext(@move)
    @log.debug('Move.initialized')
  end

  attr_reader :log

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

  def put_illegal_access
    print TEXTPLAIN_HEAD + 'illegal access.'
  end

  def put_moved
    print TEXTPLAIN_HEAD + 'Moved.'
  end

  def put_invalid_move
    print TEXTPLAIN_HEAD + 'invalid move.'
  end

  def put_please_login
    print TEXTPLAIN_HEAD + 'please log in.'
  end

  def check_param
    # gameid が無いよ
    return put_illegal_access if @gameid.nil? || @gameid.empty?

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

  def build_finishedtitle
    "the game was over. (#{@tkd.to_vs})"
  end

  def build_finishedmsg(nowstr, filename)
    msg = <<-MSG_TEXT.unindent
      #{@tkd.mi.playerb}さん、 #{@tkd.mi.playerw}さん

      対局(#{@gameid})が#{nowstr}に終局しました。

      #{@baseurl}washcrus.rb?game/#{@gameid}

      attached:#{filename}

      MSG_TEXT
    msg += MailManager.footer
    msg
  end

  def build_attachfilename(dt)
    "#{@tkd.mi.playerb}_#{@tkd.mi.playerw}_#{dt}.kif"
  end

  def build_short_dt
    @tkd.mi.dt_lastmove.delete('/:').sub(' ', '_')
  end

  def send_mail_finished(nowstr)
    subject = build_finishedtitle
    # @log.debug("subject:#{subject}")

    dt = build_short_dt
    filename = build_attachfilename(dt)

    msg = build_finishedmsg(nowstr, filename)

    kifufile = {
      filename: @tkd.escape_fnu8(filename),
      content:  @tkd.to_kif
    }

    # @log.debug("msg:#{msg}")
    mmgr = MailManager.new
    mmgr.send_mailex(@tkd.mi.emailb, subject, msg, kifufile)
    mmgr.send_mailex(@tkd.mi.emailw, subject, msg, kifufile)
  end

  def build_nextturnmsg(name, nowstr)
    msg = <<-MSG_TEXT.unindent
      #{name}さん

      #{@userinfo.user_name}さんが#{nowstr}に１手指されました。

      #{@baseurl}washcrus.rb?game/#{@gameid}

      MSG_TEXT
    msg += MailManager.footer
    msg
  end

  def send_mail_next(nowstr)
    subject = "it's your turn!! (#{@tkd.to_vs})"
    # @log.debug("subject:#{subject}")
    opp = @tkd.mi.getopponent(@userinfo.user_id)
    # @log.debug("opp:#{opp}")

    msg = build_nextturnmsg(opp[:name], nowstr)

    mmgr = MailManager.new
    mmgr.send_mail(opp[:mail], subject, msg)
  end

  # @param finished [boolean] 終局したかどうか
  # @param now      [Time]    着手日時
  def send_mail(finished, nowstr)
    @log.debug('Move.sendmail')
    @tkd.read

    if finished == 1
      send_mail_finished(nowstr)
    else
      send_mail_next(nowstr)
    end
  end

  def update_taikyokuchu_dt(tcdb, nowstr)
    @log.debug('tcdb.updatedatetime')
    tcdb.lock do
      tcdb.read
      tcdb.updatedatetime(@gameid, nowstr)
      tcdb.write
    end
  end

  def update_taikyoku_dt(nowstr)
    @log.debug('tdb.updatedatetime')
    tdb = TaikyokuFile.new
    tdb.lock do
      tdb.read
      tdb.updatedatetime(@gameid, nowstr)
      tdb.write
    end
  end

  # 対局終了処理
  def finish_game(tcdb)
    # 終了日時の更新とか勝敗の記録とか
    @log.debug("tkd.finished(now, #{@tkd.mi.teban} == 'b')")
    @tkd.finished(now, @tkd.mi.teban == 'b')
    # 対局中からはずす
    @log.debug('tcdb.finished(@gameid)')
    tcdb.finished(@gameid)
  end

  #
  # 実行本体。
  #
  def perform
    # gameid が無いよ, userinfoが変だよ
    # moveが変だよ, 存在しないはずのIDだよ
    return if check_param.nil?

    # @log.debug('Move.read data')
    @tkd = TaikyokuData.new
    @tkd.setid(@gameid)
    @tkd.read

    now = Time.now
    nowstr = now.strftime('%Y/%m/%d %H:%M:%S')

    # 指し手を適用する
    @log.debug('Move.apply sfen, jmv')
    @tkd.log = @log
    # @tkd.move(@jmv, now)
    ret = @tkd.move(@sfen, @jmv, now)
    return put_invalid_move if ret.nil?

    tcdb = TaikyokuChuFile.new
    tcdb.read
    finish_game(tcdb) if ret == 1

    # @log.debug('Move.setlastmove')
    @tkd.mi.setlastmove_dt(@move[0, 7], now)

    # @log.debug('Move.mi.write')
    # @tkd.mi.write(@tkd.matchinfopath)
    # @log.debug('Move.jkf.write')
    # @tkd.jkf.write(@tkd.kifupath)
    @tkd.write

    update_taikyokuchu_dt(tcdb, nowstr) if ret != 1

    update_taikyoku_dt(nowstr)

    send_mail(ret, nowstr)

    put_moved

    @log.debug('Move.performed')
  end
end

# -----------------------------------
#   main
#

cgi = CGI.new
stg = Settings.new
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
