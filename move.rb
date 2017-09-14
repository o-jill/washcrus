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
    @log = Logger.new('./tmp/movelog.txt')
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

  def check_param
    # gameid が無いよ
    return print TEXTPLAIN_HEAD + 'illegal access.' \
        if @gameid.nil? || @gameid.empty?

    # userinfoが変だよ
    return print TEXTPLAIN_HEAD + 'please log in.' \
        unless @userinfo.nil? || @userinfo.exist_indb

    # moveが変だよ
    return print TEXTPLAIN_HEAD + 'invalid move.' if @jmv.nil?

    self
  end

  def send_mail_finished(nowstr)
    subject = "the game was over. (#{@tkd.mi.playerb} vs #{@tkd.mi.playerw})"
    # @log.debug("subject:#{subject}")

    dt = @tkd.mi.dt_lastmove.delete('/:').sub(' ', '_')
    filename = "#{@tkd.mi.playerb}_#{@tkd.mi.playerw}_#{dt}.kif"

    msg = <<-MSG_TEXT.unindent
      #{@tkd.mi.playerb}さん、 #{@tkd.mi.playerw}さん

      対局(#{@gameid})が#{nowstr}に終局しました。

      #{@baseurl}game.rb?#{@gameid}

      attached:#{filename}

      MSG_TEXT
    msg += MailManager.footer

    kifufile = {
      filename: @tkd.escape_fnu8(filename),
      content:   @tkd.jkf.to_kif.encode('Shift_JIS')
    }

    # @log.debug("msg:#{msg}")
    mmgr = MailManager.new
    mmgr.send_mailex(@tkd.mi.emailb, subject, msg, kifufile)
    mmgr.send_mailex(@tkd.mi.emailw, subject, msg, kifufile)
  end

  def send_mail_next(nowstr)
    subject = "it's your turn!! (#{@tkd.mi.playerb} vs #{@tkd.mi.playerw})"
    # @log.debug("subject:#{subject}")
    opp = @tkd.mi.getopponent(@userinfo.user_id)
    # @log.debug("opp:#{opp}")
    msg = <<-MSG_TEXT.unindent
      #{opp[:name]}さん

      #{@userinfo.user_name}さんが#{nowstr}に１手指されました。

      #{@baseurl}game.rb?#{@gameid}

      MSG_TEXT
    msg += MailManager.footer
    # @log.debug("msg:#{msg}")

    mmgr = MailManager.new
    mmgr.send_mail(opp[:mail], subject, msg)
  end

  # @param finished [boolean] 終局したかどうか
  # @param now      [Time]    着手日時
  def send_mail(finished, nowstr)
    if finished
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

  #
  # 実行本体。
  #
  def perform
    # @log.debug('Move.perform')
    # gameid が無いよ
    # userinfoが変だよ
    # moveが変だよ
    return if check_param.nil?

    # @log.debug('Move.check gameid')
    tcdb = TaikyokuChuFile.new
    tcdb.read

    # 存在しないはずのIDだよ
    return print TEXTPLAIN_HEAD + 'illegal access.' \
      unless tcdb.exist_id(@gameid)

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
    return print TEXTPLAIN_HEAD + 'invalid move.' if ret.nil?

    if ret == 1
      # 終了日時の更新とか勝敗の記録とか
      @log.debug("tkd.finished(now, #{@tkd.mi.teban} == 'b')")
      @tkd.finished(now, @tkd.mi.teban == 'b')
      # 対局中からはずす
      @log.debug('tcdb.finished(@gameid)')
      tcdb.finished(@gameid)
    end

    # @log.debug('Move.setlastmove')
    @tkd.mi.setlastmove_dt(@move[0, 7], now)

    # @log.debug('Move.mi.write')
    @tkd.mi.write(@tkd.matchinfopath)

    # @log.debug('Move.jkf.write')
    @tkd.jkf.write(@tkd.kifupath)

    update_taikyokuchu_dt(tcdb, nowstr) if ret != 1

    update_taikyoku_dt(nowstr)

    @log.debug('Move.sendmail')
    @tkd.read
    send_mail(ret == 1, nowstr)

    print TEXTPLAIN_HEAD + 'Moved.'

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
