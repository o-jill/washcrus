#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

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
  def initialize
    stg = Settings.new
    @baseurl = stg.value['base_url']
  end

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

  def getlist2send(list, tm)
    list.select do |id, t|
      et = getelapsed(Time.parse(t), tm)
      et[:day] > 0 && et[:hour].zero? && et[:min] / 10 < 1
      # bmail = et[:day] > 0 && et[:hour].zero? && et[:min] / 10 < 1
      # puts "#{id} | #{t} | #{et[:total]} | " \
      #      "#{et[:day]}:#{et[:hour]}:#{et[:min]}:#{et[:sec]} | #{bmail}"
      # bmail
    end
  end

  def send_mail(mi)
    subject = "[reminder] it's your turn!! (#{mi.playerb} vs #{mi.playerw})"
    # @log.debug("subject:#{subject}")
    nply = mi.getnextplayer()
    pply = mi.getopponent(nply[:id])
    # @log.debug("opp:#{opp}")
    msg = <<-MSG_TEXT.unindent
      #{nply[:name]}さん

      #{pply[:name]}さんが#{mi.dt_lastmove}に１手指されました。

      #{@baseurl}game.rb?#{mi.gid}

      MSG_TEXT
    msg += MailManager.footer
    # @log.debug("msg:#{msg}")

    mmgr = MailManager.new
    # mmgr.send_mail(nply[:mail], subject, msg)
    print <<-FAKE_MAIL.unindent
      to:#{nply[:name]}
      subject:#{subject}
      msg:#{msg}
      FAKE_MAIL
  end

  def perform
    tcdb = TaikyokuChuFile.new
    tcdb.read
    list = tcdb.checkelapsed

    now = Time.now
    list2send = getlist2send(list, now)

    puts '# list 2 be sent'
    list2send.each do |id, t|
      puts "#{id} | #{t}"
      tkd =TaikyokuData.new
      tkd.setid(id)
      tkd.read
      send_mail(tkd.mi)
    end
  end
end

# -----------------------------------
#   main
#
if $PROGRAM_NAME == __FILE__
  bc = ByouyomiChan.new
  bc.perform
end
