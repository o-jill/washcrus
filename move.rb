#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'bundler/setup'

require 'cgi'
require 'cgi/session'
require 'erb'
require 'logger'
require 'unindent'

require './file/jsonkifu.rb'
require './file/jsonmove.rb'
require './file/matchinfofile.rb'
require './file/pathlist.rb'
require './file/taikyokufile.rb'
require './file/chatfile.rb'
require './game/taikyokudata.rb'
require './game/sfenkyokumentxt.rb'
require './game/userinfo.rb'
require './util/mailmgr.rb'
require './util/myhtml.rb'
require './util/settings.rb'

#
# CGI本体
#
class Move
  # 初期化
  #
  # @param cgi CGIオブジェクト
  # @param stg グローバル設定
  def initialize(cgi, stg)
    @log = Logger.new(PathList::MOVELOG)
    # @log.level = Logger::INFO
    # @log.debug('Move.new()')
    readuserparam(cgi)
    read_cgiparam(cgi)
    # @stg = stg
    load_settings(stg)
    @turn = '?'
    @finished = false
    @jmv = JsonMove.fromtext(move)
    @log.info("gameid:#{gameid}, sfen:#{sfen}, move:#{move}")
    # @log.debug('Move.initialized')
  end

  # @!attribute [r] plysnm
  #   @return 先手の対局者名
  # @!attribute [r] plygnm
  #   @return 後手の対局者名
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
  attr_reader :baseurl, :finished, :gameid, :jmv, :log, :mif, :move,
              :plysnm, :plygnm, :sfen, :tkd, :turn, :userinfo, :usehtml

  # paramsから値の読み出し
  #
  # @param cgi CGIオブジェクト
  def read_cgiparam(cgi)
    @params = cgi.params
    @gameid = cgi.query_string
    @sfen = @params['sfen'][0] if @params['sfen']
    @move = @params['jsonmove'][0] if @params['jsonmove']
  end

  # 設定値の読み込み
  #
  # @param stg 設定
  def load_settings(stg)
    @baseurl = stg.value['base_url']
    @usehtml = stg.value['mailformat'] == 'html'
  end

  # sessionの取得と情報の読み取り
  #
  # @param cgi CGIオブジェクト
  def readuserparam(cgi)
    # @log.debug('Move.readuserparam')

    # check cookies
    @log.debug("cookie:#{cgi.cookies}")

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
      @log.debug("sesionfiles:#{Dir['./tmp/*']}")
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
    # @log.debug "illegalaccess (tcdb.exist_id(#{gameid}) =>" \
    #   " #{tcdb.exist_id(gameid)})" unless tcdb.exist_id(gameid)
    return MyHtml.puts_textplain_illegalaccess unless tcdb.exist_id(gameid)

    # userinfoが変だよ
    # @log.debugpleaselogin(uid:#{userinfo.user_id})" unless userinfo.exist_indb
    return MyHtml.puts_textplain_pleaselogin unless userinfo.exist_indb

    # moveが変だよ
    # @log.debug "MyHtml.'invalid move.'" unless jmv
    return MyHtml.puts_textplain('invalid move.') unless jmv

    self
  end

  # 対局終了メールのタイトルの生成
  def build_finishedtitle
    "the game was over. (#{mif.to_vs})"
  end

  # 対局終了メールの本文の生成
  #
  # @param nowstr   現在の時刻の文字列
  # @param filename 添付ファイル名
  def build_finishedmsg(nowstr, filename)
    msg = ERB.new(
      File.read('./mail/finishedmsg.erb', encoding: 'utf-8')
    ).result(binding)

    msg += build_kyokumenzu

    chat = ChatFile.new(gameid).read
    msg + msginchat(chat.stripped_msg)
  end

  # メール用チャット文の生成
  #
  # @param msg チャット内容
  # @param tag 行の先頭に付加するhtmlタグ
  # @param taglast 終端htmlタグ
  #
  # @return メール用チャット文
  def msginchat(msg, tag = '', taglast = '')
    "#{tag}---- messages in chat ----\n#{tag}#{msg}" \
    "#{tag}---- messages in chat ----\n#{taglast}\n"
  end

  # 対局終了メールの本文の生成
  #
  # @param nowstr   現在の時刻の文字列
  # @param filename 添付ファイル名
  #
  # @return 対局終了メールの本文
  def build_finishedhtmlmsg(nowstr, filename)
    url = "#{baseurl}index.rb?game/#{gameid}"

    msg = ERB.new(
      File.read('./mail/finishedhtml.erb', encoding: 'utf-8')
    ).result(binding)

    chat = ChatFile.new(gameid).read
    msg + msginchat(chat.msg, '<p>')
  end

  # 添付ファイル名の生成
  #
  # @return 添付ファイル名
  def build_attachfilename
    # 数字だけの時刻の文字列の生成
    dt = mif.dt_lastmove.delete('/:').sub(' ', '_')

    fname = "#{plysnm}_#{plygnm}_#{dt}.kif"

    fname.gsub(%r{[\\/*:<>?|]},
               '\\' => '￥', '/' => '／', '*' => '＊', ':' => '：',
               '<' => '＜', '>' => '＞', '?' => '？', '|' => '｜')
  end

  # 署名をつけてHTMLメールを送信
  #
  # @param subject 題名
  # @param msg 本文テキスト
  # @param html 本文テキスト
  # @param kifufile 棋譜ファイル
  def send_htmlmailex_withfooter(subject, msg, html, kifufile)
    bemail = mif.playerb.email
    wemail = mif.playerw.email

    mmgr = MailManager.new
    mmgr.send_htmlmailex_withfooter(bemail, subject, msg, html, kifufile)
    mmgr.send_htmlmailex_withfooter(wemail, subject, msg, html, kifufile)
  end

  # 署名をつけてテキストメールを送信
  #
  # @param subject 題名
  # @param msg 本文テキスト
  # @param kifufile 棋譜ファイル
  def send_mailex_withfooter(subject, msg, kifufile)
    bemail = mif.playerb.email
    wemail = mif.playerw.email

    mmgr = MailManager.new
    mmgr.send_mailex_withfooter(bemail, subject, msg, kifufile)
    mmgr.send_mailex_withfooter(wemail, subject, msg, kifufile)
  end

  # 終局メールの生成と送信
  def send_mail_finished(nowstr)
    subject = build_finishedtitle
    # @log.debug("subject:#{subject}")

    # dt = build_short_dt
    filename = build_attachfilename

    # filename: tkd.escape_fnu8(filename),
    kifufile = { filename: filename, content: tkd.jkf.to_kif }

    # mif = tkd.mif

    msg = build_finishedmsg(nowstr, filename)
    # @log.debug("msg:#{msg}")

    return send_mailex_withfooter(subject, msg, kifufile) unless usehtml

    html = build_finishedhtmlmsg(nowstr, filename)
    send_htmlmailex_withfooter(subject, msg, html, kifufile)
  end

  # 局面図の生成
  def build_kyokumenzu
    skt = SfenKyokumenTxt.new(mif.sfen)
    skt.settitle('タイトル')
    skt.setmoveinfo(move)
    skt.setnames(plysnm, plygnm)
    skt.gen + "\n"
  end

  # 局面図のURLの生成
  def bulid_svgurl
    "#{baseurl}sfenimage.rb?" \
    "sfen=#{mif.sfen.gsub('+', '%2B')}&lm=#{mif.lastmove[3, 2]}&" \
    "sname=#{mif.playerb.name}&gname=#{mif.playerw.name}"
  end

  # 指されましたメールの本文の生成
  #
  # @param name   手番の人の名前
  # @param nowstr   現在の時刻の文字列
  def build_nextturnmsg(name, nowstr)
    msg = ERB.new(
      File.read('./mail/nextturn.erb', encoding: 'utf-8')
    ).result(binding)

    msg += build_kyokumenzu

    chat = ChatFile.new(gameid).read
    msg + msginchat(chat.stripped_msg)
  end

  # 指されましたメールの本文の生成
  #
  # @param name   手番の人の名前
  # @param nowstr   現在の時刻の文字列
  def build_nextturnhtmlmsg(name, nowstr)
    url = "#{baseurl}index.rb?game/#{gameid}"

    msg = ERB.new(
      File.read('./mail/nextturnhtml.erb', encoding: 'utf-8')
    ).result(binding)

    chat = ChatFile.new(gameid).read
    msg + "<pre>\n" + msginchat(chat.stripped_msg, '', '</pre>')
  end

  # 対戦相手の情報を取得
  #
  # @return [名前, メールアドレス]
  def getopponentinfo
    opp = mif.getopponent(userinfo.user_id)
    [opp[:name], opp[:mail]]
    # opnm = opp[:name]
    # opem = opp[:mail]
    # @log.debug("opp:#{opp}")
  end

  # 指されましたメールの生成と送信
  #
  # @param nowstr 現在の時刻の文字列
  def send_mail_next(nowstr)
    subject = "it's your turn!! (#{mif.to_vs})"
    # @log.debug("subject:#{subject}")

    (opnm, opem) = getopponentinfo

    msg = build_nextturnmsg(opnm, nowstr)

    mmgr = MailManager.new

    return mmgr.send_mail_withfooter(opem, subject, msg) unless usehtml

    mmgr.send_htmlmail_withfooter(
      opem, subject, msg,
      build_nextturnhtmlmsg(opnm, nowstr)
    )
  end

  # メールの送信
  #
  # @param finished [boolean] 終局したかどうか
  # @param now      [Time]    着手日時オブジェクト
  def send_mail(finished, now)
    @log.debug('Move.sendmail')
    tkd.read # これいるの？
    nowstr = now.strftime('%Y/%m/%d %H:%M:%S')
    finished ? send_mail_finished(nowstr) : send_mail_next(nowstr)
  end

  # 引き分けで終局
  #
  # @param now [Time] 着手日時オブジェクト
  def finish_draw(now)
    @turn = 'd'
    tkd.finished(now, nil, turn)
  end

  # どちらかが勝って終局
  #
  # @param now [Time] 着手日時オブジェクト
  def finish_normal(now)
    gote_win = (mif.teban == 'b')
    @turn = gote_win ? 'fw' : 'fb'
    tkd.finished(now, gote_win, turn)
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

    # @plysnm = mif.playerb.name
    # @plygnm = mif.playerw.name
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
    @plysnm = mif.playerb.name
    @plygnm = mif.playerw.name
  end

  #
  # 実行本体。
  #
  def perform
    # gameid が無いよ, userinfoが変だよ, moveが変だよ, 存在しないはずのIDだよ
    return unless check_param

    @log.debug('Move.read data')

    prepare_taikyokudata

    tkd.lock do
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
  stg = Settings.instance
  move = Move.new(cgi, stg)
  # move.readuserparam
  move.perform
  # end
rescue ScriptError => err
  errtrace(err)
rescue SecurityError => err
  errtrace(err)
rescue StandardError => err
  errtrace(err)
end
# -----------------------------------
#   testing
#
