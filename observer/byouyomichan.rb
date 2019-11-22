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
  # @param mif MatchInfoFileオブジェクト
  # @return 件名用文字列
  def self.build_subject(type, mif)
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
    subject += " (#{mif.to_vs})" if subject
    subject
  end

  def build_msg(mif, nply, tmkp)
    pply = mif.getopponent(nply[:id])
    opp = pply[:name]

    msg = tmkp.build_msg

    return unless msg

    ret =
      "#{nply[:name]}さん\n\n#{msg}\n\n" \
      "#{opp}さんは#{mif.dt_lastmove}に１手指されました。\n\n" \
      "#{@baseurl}index.rb?game/#{mif.gid}\n\n"

    ret
  end

  # メールの送信
  #
  # @param mif MatchInfoFileオブジェクト
  # @param tmkp TimeKeeperオブジェクト
  def send_mail(mif, tmkp)
    nply = mif.getnextplayer

    subject = ByouyomiChan.build_subject(tmkp.houchi, mif)
    msg = build_msg(mif, nply, tmkp)

    return unless subject
    return unless msg

    mmgr = MailManager.new
    mmgr.send_mail_withfooter(nply[:mail], subject, msg)
    print <<-FAKE_MAIL.unindent
      to:#{nply[:name]}
      subject:#{subject}
      msg:#{msg}
    FAKE_MAIL
  end

  # logのヘッダの出力
  #
  # @param t 時刻オブジェクト
  def put_log_header(tim)
    puts "# list 2 be checked (#{tim.strftime('%Y/%m/%d %H:%M:%S')})"
    puts "# #{@min_period} minutes period."
  end

  # 秒読みの確認と必要があればメール送信
  #
  # @param gid gameid
  def validate(gid)
    tkd = TaikyokuData.new
    tkd.setid(gid)
    tkd.lock do
      tkd.read

      mif = tkd.mif
      return if mif.finished

      puts "id:#{gid}"
      tmkp = TimeKeeper.new

      tkd.tick(tmkp)
      send_mail(mif, tmkp)
    end
  end

  # 実行本体。
  def perform
    put_log_header(Time.now)

    tcdb = TaikyokuChuFile.new
    tcdb.read
    list = tcdb.content.gameids

    list.each do |gid|
      validate(gid)
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
    puts "error:#{e}\nstack:#{e.backtrace.join("\n")}"
  end
end
