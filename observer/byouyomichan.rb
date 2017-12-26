#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

# commandline:
#     ruby observer/byouyomichan.rb <period in minutes>
#

require 'rubygems'

require 'time'
require 'unindent'

require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/timekeeper.rb'
require './game/userinfo.rb'
require './util/mailmgr.rb'
require './util/settings.rb'

#
# 経過時間監視クラス
#
class ByouyomiChan
  # 初期化
  def initialize
    stg = Settings.instance
    @baseurl = stg.value['base_url']

    @min_period = ARGV[0].to_i || 0
    raise StandardError.new('period shoud be more than zero!') \
        if @min_period < 1
  end

  # 経過時間の計算
  #
  # @param from ここから
  # @param to   ここまで
  #
  # @return 経過時間ハッシュオブジェクト
  #         { day: day, hour: hour, min: min, sec: sec, total: totalsec }
  def getelapsed(from, to)
    totalsec = to - from
    res = totalsec.divmod(60)
    sec = res[1].to_i
    res = res[0].divmod(60)
    min = res[1]
    res = res[0].divmod(24)
    day = res[0]
    hour = res[1]

    { day: day, hour: hour, min: min, sec: sec, total: totalsec }
  end

  # メールを送る対局リストの取得
  #
  # @param list 対局リスト
  # @param tm   時刻
  def getlist2send(list, tm)
    list.select do |_id, tt|
      et = getelapsed(Time.parse(tt), tm)
      et[:day] > 0 && et[:hour].zero? && et[:min] / @min_period < 1
      # bmail = et[:day] > 0 && et[:hour].zero? && et[:min] / @min_period < 1
      # puts "#{_id} | #{tt} | #{et[:total]} | " \
      #      "#{et[:day]}:#{et[:hour]}:#{et[:min]}:#{et[:sec]} | #{bmail}"
      # bmail
    end
  end

  # 対局者に持ち時間がなくなったことを知らせる
  def build_subj_reminder(mi)
    "[reminder] it's your turn!! (#{mi.to_vs})"
  end

  # メール本文の生成
  #
  # @param me   手番プレイヤーの情報
  # @param opp  相手の情報
  # @param dt   最終着手日時
  # @param gid  対局ID
  # @param days 経過日数
  # @return メール本文文字列
  def build_msg_reminder(me, opp, dt, gid, remains)
    days = (remains / 86_400).ceil
    msg = <<-MSG_TEXT.unindent
      #{me[:name]}さん

      残り時間は#{days}日です。

      #{opp[:name]}さんは#{dt}に１手指されました。

      #{@baseurl}washcrus.rb?game/#{gid}

      MSG_TEXT
    msg += MailManager.footer
    msg
  end

  # 対局者に持ち時間がなくなったことを知らせる
  def build_subj_nothinktime(mi)
    "main thinking time was run out! (#{mi.to_vs})"
  end

  # 対局者に持ち時間がなくなったことを知らせる
  def build_msg_nothinktime(me, opp, dt, gid)
    msg = <<-MSG_TEXT.unindent
      #{me[:name]}さん

      持ち時間がなくなりました。秒読みに入ります。

      #{opp[:name]}さんは#{dt}に１手指されました。

      #{@baseurl}washcrus.rb?game/#{gid}

      MSG_TEXT
    msg
  end

  # 対局者に秒読みが終わった/考慮時間を使ったことを知らせる
  def build_subj_useextra(mi)
    "byo-yomi thinking time was run out! (#{mi.to_vs})"
  end

  # 対局者に秒読みが終わった/考慮時間を使ったことを知らせる
  def build_msg_useextra(me, opp, dt, gid, extra)
    msg = <<-MSG_TEXT.unindent
      #{me[:name]}さん

      秒読みが終わりました。考慮時間に入ります。
      残り考慮時間は#{extra}日です。

      #{opp[:name]}さんは#{dt}に１手指されました。

      #{@baseurl}washcrus.rb?game/#{gid}

      MSG_TEXT
    msg
  end

  # 対局者に最後の考慮時間を使ったことを知らせる
  def build_subj_noextra(mi)
    "extra thinking time was run out! (#{mi.to_vs})"
  end

  # 対局者に最後の考慮時間を使ったことを知らせる
  def build_msg_noextra(me, opp, dt, gid)
    msg = <<-MSG_TEXT.unindent
      #{me[:name]}さん

      最後の考慮時間に入りました。残りはありません。

      #{opp[:name]}さんは#{dt}に１手指されました。

      #{@baseurl}washcrus.rb?game/#{gid}

      MSG_TEXT
    msg
  end

  # 対局者に時間切れを知らせる
  def build_subj_tmout
    "all thinking time was run out! (#{mi.to_vs})"
  end

  # 対局者に時間切れを知らせる
  def build_msg_tmout(me, opp, dt, gid)
    msg = <<-MSG_TEXT.unindent
      #{me[:name]}さん

      時間がなくなりました。
      投了するか、対局相手と相談してください。

      #{opp[:name]}さんは#{dt}に１手指されました。

      #{@baseurl}washcrus.rb?game/#{gid}

      MSG_TEXT
    msg
  end

  # メールの送信
  #
  # @param mi MatchInfoFileオブジェクト
  # @param tmkp TimeKeeperオブジェクト
  def send_mail(mi, tmkp)
    nply = mi.getnextplayer
    pply = mi.getopponent(nply[:id])

    gid = mi.gid
    dtlm = mi.dt_lastmove
    case tmkp.houchi
    when TimeKeeper::HOUCHI_REMINDER # 対局者に1日経過を知らせる
      subject = build_subj_reminder(mi)
      msg = build_msg_reminder(nply, pply, dtlm, gid, mi.byouyomi)
    when TimeKeeper::HOUCHI_NOTHINKINGTIME # 対局者に持ち時間がなくなったことを知らせる
      subject = build_subj_nothinktime
      msg = build_msg_nothinktime(nply, pply, dtlm, gid)
    when TimeKeeper::HOUCHI_USEEXTRA
      # 対局者に秒読みが終わった/考慮時間を使ったことを知らせる
      subject = build_subj_useextra
      msg = build_msg_useextra(nply, pply, dtlm, gid, tmkp.extracount)
    when TimeKeeper::HOUCHI_NOEXTRA # 対局者に最後の考慮時間を使ったことを知らせる
      subject = build_subj_noextra
      msg = build_msg_noextra(nply, pply, dtlm, gid)
    when TimeKeeper::HOUCHI_TMOUT # 対局者に時間切れを知らせる
      subject = build_subj_tmout
      msg = build_msg_tmout(nply, pply, dtlm, gid)
    else return
    end
    msg += MailManager.footer

    # @log.debug("subject:#{subject}")
    # @log.debug("msg:#{msg}")

    mmgr = MailManager.new
    # mmgr.send_mail(nply[:mail], subject, msg)
    print <<-FAKE_MAIL.unindent
      to:#{nply[:name]}
      subject:#{subject}
      msg:#{msg}
      FAKE_MAIL
  end

  # logのヘッダの出力
  #
  # @param t 時刻オブジェクト
  def put_log_header(tm)
    puts "# list 2 be sent (#{tm.strftime('%Y/%m/%d %H:%M:%S')})"
    puts "# #{@min_period} minutes period."
  end

  # 実行本体。
  def perform
    tcdb = TaikyokuChuFile.new
    tcdb.read
    list = tcdb.content.gameids

    list.each do |id|
      tkd = TaikyokuData.new
      tkd.setid(id)
      tkd.read
      mi = tkd.mi

      next if mi.finished
      puts "id:#{id}"
      tmkp = TimeKeeper.new

      tkd.tick(tmkp)

      send_mail(mi, tmkp)
    end
  end
end

# -----------------------------------
#   main
#
if $PROGRAM_NAME == __FILE__
  begin
    bc = ByouyomiChan.new
    bc.perform
  rescue StandardError => e
    puts e
  end
end
