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

  # メール本文の生成
  #
  # @param me   手番プレイヤーのの情報
  # @param opp  相手の情報
  # @param dt   最終着手日時
  # @param gid  対局ID
  # @param days 経過日数
  # @return メール本文文字列
  def build_msg(me, opp, dt, gid, days)
    msg = <<-MSG_TEXT.unindent
      #{me[:name]}さん

      #{opp[:name]}さんが#{dt}に１手指してから#{days}日経過しました。

      #{@baseurl}washcrus.rb?game/#{gid}

      MSG_TEXT
    msg += MailManager.footer
    msg
  end

  # メールの送信
  #
  # @param mi MatchInfoFileオブジェクト
  def send_mail(mi, sec)
    days = (sec / 86_400).floor

    subject = "[reminder]#{days} day(s) passed! (#{mi.to_vs})"
    # @log.debug("subject:#{subject}")

    nply = mi.getnextplayer
    pply = mi.getopponent(nply[:id])
    # @log.debug("opp:#{opp}")

    msg = build_msg(nply, pply, mi.dt_lastmove, mi.gid, days)
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
    list = tcdb.checkelapsed

    now = Time.now
    list2send = getlist2send(list, now)

    put_log_header(now)

    list2send.each do |id, tk|
      puts "#{id} | #{tk}"
      tkd = TaikyokuData.new
      tkd.setid(id)
      tkd.read
      send_mail(tkd.mi, tk)
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
