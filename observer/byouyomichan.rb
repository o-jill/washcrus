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

  # メールの件名の生成
  #
  # @param type 種類
  # @param mi MatchInfoFileオブジェクト
  # @return 件名用文字列
  def self.build_subject(type, mi)
    tbl_subject = [
      nil, # 対局者に知らせる必要なし
      "[reminder] it's your turn!!", # 対局者に1日経過を知らせる
      'main thinking time was run out!', # 対局者に持ち時間がなくなったことを知らせる
      'byo-yomi thinking time was run out!',
      # 対局者に秒読みが終わった/考慮時間を使ったことを知らせる
      'extra thinking time was run out!', # 対局者に最後の考慮時間を使ったことを知らせる
      'all thinking time was run out!' # 対局者に時間切れを知らせる
    ]
    subject = tbl_subject[type]
    subject += " (#{mi.to_vs})" if subject
    subject
  end

  def self.build_msg_abs(tmkp)
    case tmkp.houchi
    when TimeKeeper::HOUCHI_REMINDER # 対局者に1日経過を知らせる
      tdays = (tmkp.thinktime / 86_400).ceil
      bdays = (tmkp.byouyomi / 86_400).ceil
      "残り時間は、持ち時間約#{tdays}日、秒読み約#{bdays}日です。"
    when TimeKeeper::HOUCHI_NOTHINKINGTIME # 対局者に持ち時間がなくなったことを知らせる
      '持ち時間がなくなりました。秒読みに入ります。'
    when TimeKeeper::HOUCHI_USEEXTRA
      # 対局者に秒読みが終わった/考慮時間を使ったことを知らせる
      "秒読みが終わりました。考慮時間に入ります。\n残り考慮時間は#{tmkp.extracount}日です。"
    when TimeKeeper::HOUCHI_NOEXTRA # 対局者に最後の考慮時間を使ったことを知らせる
      '最後の考慮時間に入りました。残りはありません。'
    when TimeKeeper::HOUCHI_TMOUT # 対局者に時間切れを知らせる
      "時間がなくなりました。\n投了するか、対局相手と相談してください。"
    end
  end

  def build_msg(mi, nply, tmkp)
    pply = mi.getopponent(nply[:id])
    opp = pply[:name]

    msg = ByouyomiChan.build_msg_abs(tmkp)

    return unless msg

    ret =
      "#{nply[:name]}さん\n\n#{msg}\n\n" \
      "#{opp}さんは#{mi.dt_lastmove}に１手指されました。\n\n" \
      "#{@baseurl}washcrus.rb?game/#{mi.gid}\n\n"

    ret
  end

  # メールの送信
  #
  # @param mi MatchInfoFileオブジェクト
  # @param tmkp TimeKeeperオブジェクト
  def send_mail(mi, tmkp)
    nply = mi.getnextplayer

    subject = ByouyomiChan.build_subject(tmkp.houchi, mi)
    msg = build_msg(mi, nply, tmkp)

    return unless subject
    return unless msg

    msg += MailManager.footer

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
      tkd.lock do
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
