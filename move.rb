#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'bundler/setup'

require 'cgi'
require 'cgi/session'
require 'logger'
require 'unindent'

require './file/chatfile.rb'
require './file/jsonkifu.rb'
require './file/jsonmove.rb'
require './file/matchinfofile.rb'
require './file/pathlist.rb'
require './file/taikyokufile.rb'
require './file/userchatfile.rb'
require './game/taikyokudata.rb'
require './game/taikyokumail.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './util/settings.rb'

#
# CGI本体
#
class Move
  # 初期化
  #
  # @param cgi CGIオブジェクト
  def initialize(cgi)
    @log = Logger.new(PathList::MOVELOG)
    # @log.level = Logger::INFO
    # @log.debug('Move.new()')
    readuserparam(cgi)
    read_cgiparam(cgi)
    @turn = '?'
    @finished = false
    @jmv = JsonMove.fromtext(move)
    @log.info("gameid:#{gameid}, sfen:#{sfen}, move:#{move}")
    # @log.debug('Move.initialized')
  end

  # @!attribute [r] gameid
  #   @return 対局ID
  # @!attribute [r] mif
  #   @return　MatchInfoFileオブジェクト
  # @!attribute [r] jmv
  #   @return JsonMoveオブジェクト
  # @!attribute [r] userinfo
  #   @return ユーザー情報
  # @!attribute [r] log
  #   @return ログオブジェクト
  attr_reader :finished, :gameid, :jmv, :log, :mif, :move,
              :sfen, :tkd, :turn, :userinfo

  # paramsから値の読み出し
  #
  # @param cgi CGIオブジェクト
  def read_cgiparam(cgi)
    @params = cgi.params
    @gameid = cgi.query_string
    @sfen = @params['sfen'][0] if @params['sfen']
    @move = @params['jsonmove'][0] if @params['jsonmove']
  end

  # sessionの取得と情報の読み取り
  #
  # @param cgi CGIオブジェクト
  def readuserparam(cgi)
    # @log.debug('Move.readuserparam')

    # check cookies
    # @log.debug("cookie:#{cgi.cookies}")

    begin
      session = CGI::Session.new(
        cgi,
        'new_session' => false,
        'session_key' => '_washcrus_session',
        'tmpdir' => './tmp'
      )
    rescue ArgumentError # => ae
      # session = nil
      @log.info('failed to find session')
      # @log.debug("#{ae.message}, (#{ae.class})")
      # @log.debug("sesionfiles:#{Dir['./tmp/*']}")
    end

    # check cookies
    # @log.debug("cookie:#{cgi.cookies}")

    @userinfo = UserInfo.new
    userinfo.readsession(session) if session
    session&.close

    @header = cgi.header('charset' => 'UTF-8')
    @header = @header.gsub("\r\n", "\n")
  end

  # 情報のチェック
  def check_param
    # gameid が無いよ
    # @log.debug "MyHtml.illegalaccess gid:#{gameid}" unless gameid
    return MyHtml.puts_textplain_illegalaccess unless gameid

    tcdb = TaikyokuChuFile.new
    tcdb.read
    # 存在しないはずのIDだよ
    # @log.debug "illegalaccess (tcdb.exist?(#{gameid}) =>" \
    #   " #{tcdb.exist?(gameid)})" unless tcdb.exist?(gameid)
    return MyHtml.puts_textplain_illegalaccess unless tcdb.exist?(gameid)

    # userinfoが変だよ
    # @log.debugpleaselogin(uid:#{userinfo.user_id})" unless userinfo.exist_indb
    return MyHtml.puts_textplain_pleaselogin unless userinfo.exist_indb

    # moveが変だよ
    # @log.debug "MyHtml.'invalid move.'" unless jmv
    return MyHtml.puts_textplain('invalid move.') unless jmv

    self
  end

  # メールの送信
  #
  # @param finished [boolean] 終局したかどうか
  # @param now      [Time]    着手日時オブジェクト
  def send_mail(finished, now)
    kifu = tkd.jkf.to_kif
    tmail = TaikyokuMail.new(gameid, userinfo, now, move)
    tmail.setmif(tkd.mif)
    finished ? tmail.send_mail_finished(kifu) : tmail.send_mail_next
    @log.debug('Move.sendmail')
  end

  # 発言者、対局者x2のデータにも書く
  #
  # @param addedmsg 発言
  def write2chatview(addedmsg)
    tkd.mif.getplayerids.each do |userid|
      uchat = UserChatFile.new(userid)
      uchat.read
      uchat.add(addedmsg, @gameid)
    end
  end

  # 引き分けで終局
  #
  # @param now [Time] 着手日時オブジェクト
  def finish_draw(now)
    @turn = 'd'
    tkd.finished(now, nil, turn)

    sayfinish('')
  end

  def winner
    return mif.playerb.name if turn == 'fb'
    return mif.playerw.name if turn == 'fw'
  end

  def sayfinish(winner)
    # chat file
    chat = ChatFile.new(gameid)
    write2chatview(chat.say_finish(winner, turn, mif.nth.to_i - 1))
  end

  # どちらかが勝って終局
  #
  # @param now [Time] 着手日時オブジェクト
  def finish_normal(now)
    gote_win = mif.senteban?
    @turn = gote_win ? 'fw' : 'fb'
    tkd.finished(now, gote_win, turn)

    sayfinish(winner)
  end

  # 対局終了処理
  #
  # @param tcdb   対局中データベース
  # @param now 現在の時刻オブジェクト
  #
  # @note draw非対応
  def finish_game(tcdb, now)
    # 終了日時の更新とか勝敗の記録とか
    @log.debug("tkd.finished(now, #{mif.teban} == 'b')")
    mif.turn == 'd' ? finish_draw(now) : finish_normal(now)

    # 対局中からはずす
    @log.debug('tcdb.finished(gameid)')
    tcdb.finished(gameid)
  end

  # 対局情報の読み出しなどといった準備
  def prepare_taikyokudata
    @tkd = TaikyokuData.new
    tkd.log = @log
    tkd.setid(gameid)

    # @mif = tkd.mif

    # tkd.read
  end

  # 終局していれば対局終了処理をする
  #
  # @param status TaikyokuData::RES_OVERとか
  # @param now 現在の時刻オブジェクト
  #
  # @return 対局中データベース
  def chkandupdtchu(status, now)
    tcdb = TaikyokuChuFile.new
    tcdb.read
    finish_game(tcdb, now) if status == TaikyokuData::RES_OVER
    tcdb
  end

  # 対局情報の更新
  #
  # @param status TaikyokuData::RES_OVERとか
  # @param now 現在の時刻オブジェクト
  def update_taikyokudata(status, now)
    tcdb = chkandupdtchu(status, now)

    # @log.debug('Move.updatelastmove')
    tkd.updatelastmove(move, now)
    # @log.debug('Move.mif.write')
    # @log.debug('Move.jkf.write')
    tkd.write

    @finished = status != TaikyokuData::RES_NEXT
    tcdb.update_dt_turn(gameid, now, turn) unless finished
  end

  # 対局情報の登録更新
  #
  # @param status [Integer] 終局したかどうか
  # @param now    [Time]    着手日時オブジェクト
  def register_move(status, now)
    @turn = mif.teban

    update_taikyokudata(status, now)

    TaikyokuFile.new.update_dt_turn(gameid, now, turn)

    send_mail(finished, now)

    # 移動完了の表示
    MyHtml.puts_textplain('Moved.')
  end

  # 指し手を適用する
  #
  # @param now [Time] 着手日時オブジェクト
  def applymove(now)
    @log.debug('Move.apply sfen, jmv')
    # tkd.move(@jmv, now)
    ret = tkd.move(sfen, jmv, now)
    @log.debug("tkd.move() = #{ret}")
    ret
  end

  # mif(MatchInfoFile)の読み取りと対局者名の読み取り
  def read_mif
    @mif = tkd.mif
  end

  #
  # 実行本体。
  #
  def perform
    # gameid が無いよ, userinfoが変だよ, moveが変だよ, 存在しないはずのIDだよ
    return unless check_param

    @log.debug('Move.read data')

    prepare_taikyokudata

    tkd.lockex do
      tkd.read

      read_mif

      now = Time.now

      # 指し手を適用する
      ret = applymove(now)

      # 違反移動の表示
      return MyHtml.puts_textplain('invalid move.') unless ret

      return MyHtml.puts_textplain('Draw suggestion.') \
        if ret == TaikyokuData::RES_DRAW

      register_move(ret, now)
    end
    # @log.debug('Move.performed')
  end
end

# エラー時のログ出力
#
# @param err エラーオブジェクト
# @param move Moveオブジェクト
def errtrace(err, move)
  move.log.warn("class=[#{err.class}] message=[#{err.message}] " \
                "stack=[#{err.backtrace.join("\n")}] in move")
end

# -----------------------------------
#   main
#

begin
  cgi = CGI.new
  # ブロック内の処理を計測
  # require 'stackprof'
  # StackProf.run(out: "./tmp/stackprof_move_#{Time.now.to_i}.dump") do
  move = Move.new(cgi)
  # move.readuserparam
  move.perform
  # end
rescue ScriptError => e
  errtrace(e, move)
rescue SecurityError => e
  errtrace(e, move)
rescue StandardError => e
  errtrace(e, move)
end
# -----------------------------------
#   testing
#
