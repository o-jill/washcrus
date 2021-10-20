# -*- encoding: utf-8 -*-
# frozen_string_literal: true

# 対局時間管理クラス
class TimeKeeper
  # 対局者に知らせる必要なし
  HOUCHI_NONE = 0
  # 対局者に1日経過を知らせる
  HOUCHI_REMINDER = 1
  # 対局者に持ち時間がなくなったことを知らせる
  HOUCHI_NOTHINKINGTIME = 2
  # 対局者に秒読みが終わった/考慮時間を使ったことを知らせる
  HOUCHI_USEEXTRA = 3
  # 対局者に最後の考慮時間を使ったことを知らせる
  HOUCHI_NOEXTRA = 4
  # 対局者に時間切れを知らせる
  HOUCHI_TMOUT = 5

  # 初期化
  def initialize
    @dt_lasttick = nil

    @thinktime = 0
    @byouyomi = 0
    @extracount = 0
    @sec_extracount = 86_400 # 1day
    @houchi = HOUCHI_NONE
  end

  # @!attribute [r] dt_lasttick
  #   @return 最終確認時刻
  attr_reader :dt_lasttick
  # @!attribute [r] thinktime
  #   @return 持ち時間
  attr_reader :thinktime
  # @!attribute [r] byouyomi
  #   @return 秒読み
  attr_reader :byouyomi
  # @!attribute [r] extracount
  #   @return 考慮時間回数
  attr_reader :extracount
  # @!attribute [r] sec_extracount
  #   @return 考慮時間１回の時間[sec]
  attr_reader :sec_extracount
  # @!attribute [r] houchi
  #   @return 報知が必要かどうかの状態
  attr_reader :houchi

  # 時間の設定(途中から用？)
  #
  # @param ttm 持ち時間
  # @param byou 秒読み
  # @param exc 考慮時間
  # @param ltc 最終確認時刻
  def read(ttm, byou, exc, ltc)
    @thinktime = ttm
    @byouyomi = byou
    @extracount = exc
    @dt_lasttick = ltc
  end

  # 何日分の秒
  #
  # @param sec 秒数
  #
  # @return 何日分
  def self.sec2day(sec)
    # (sec / 86_400).floor
    day, hour = sec.divmod(86_400)
    day -= 1 if hour.zero?
    day
  end

  # 持ち時間の計算
  # 報知が必要かどうかが@houchiに入る。
  #
  # @param elapsed 経過時間[sec]マイナス値
  #
  # @return 持ち時間から引いた余り(秒読みから減らす分)
  def tick_thinktime(elapsed)
    @houchi = HOUCHI_NONE

    return elapsed if @thinktime.zero?

    bef = TimeKeeper.sec2day(@thinktime)
    @thinktime += elapsed
    aft = TimeKeeper.sec2day(@thinktime)

    puts "bef:#{bef}, aft:#{aft}}, byou:#{@byouyomi}"

    if @thinktime <= 0
      remain = @thinktime
      @thinktime = 0
      @houchi = HOUCHI_NOTHINKINGTIME
      remain
    else
      @houchi = HOUCHI_REMINDER if bef != aft
      0
    end
  end

  # 秒読みの計算、考慮時間の計算
  # 報知が必要かどうかが@houchiに入る。
  #
  # @param elapsed 持ち時間から引いた余り(秒読みから減らす分)マイナス値
  def tick_byouyomi(elapsed)
    bef = TimeKeeper.sec2day(@byouyomi)
    @byouyomi += elapsed
    aft = TimeKeeper.sec2day(@byouyomi)
    puts "bbef:#{bef}, aft:#{aft}}, byou:#{@byouyomi}"
    if @byouyomi.positive?
      @houchi = HOUCHI_REMINDER if bef != aft
      return
    end

    @extracount -= 1 # 考慮時間を１回消費
    @byouyomi += @sec_extracount

    return @houchi = HOUCHI_USEEXTRA if @extracount.positive?

    return @houchi = HOUCHI_NOEXTRA if @extracount.zero?

    @houchi = HOUCHI_TMOUT
  end

  # 時間の確認
  # 報知が必要かどうかが@houchiに入る。
  #
  # @param now Timeオブジェクト
  def tick(now)
    elapsed = @dt_lasttick - now
    puts "#{@dt_lasttick} - #{now} = #{elapsed}"
    @dt_lasttick = now

    # 持ち時間の計算
    elapsed = tick_thinktime(elapsed)

    # 秒読みの計算、考慮時間の計算
    tick_byouyomi(elapsed) if elapsed.nonzero?
    puts "houch:#{@houchi}"
  end

  # メッセージ文の生成
  #
  # @return メッセージ文
  def build_msg
    case houchi
    when HOUCHI_REMINDER # 対局者に1日経過を知らせる
      tdays = (thinktime / 86_400).ceil
      bdays = (byouyomi / 86_400).ceil
      "残り時間は、持ち時間約#{tdays}日、秒読み約#{bdays}日です。"
    when HOUCHI_NOTHINKINGTIME # 対局者に持ち時間がなくなったことを知らせる
      '持ち時間がなくなりました。秒読みに入ります。'
    when HOUCHI_USEEXTRA
      # 対局者に秒読みが終わった/考慮時間を使ったことを知らせる
      "秒読みが終わりました。考慮時間に入ります。\n残り考慮時間は#{extracount}日です。"
    when HOUCHI_NOEXTRA # 対局者に最後の考慮時間を使ったことを知らせる
      '最後の考慮時間に入りました。残りはありません。'
    when HOUCHI_TMOUT # 対局者に時間切れを知らせる
      "時間がなくなりました。\n投了するか、対局相手と相談してください。"
    end
  end
end
