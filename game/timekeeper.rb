# -*- encoding: utf-8 -*-

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

  # 最終確認時刻
  attr_reader :dt_lasttick
  # 持ち時間
  attr_reader :thinktime
  # 秒読み
  attr_reader :byouyomi
  # 考慮時間回数
  attr_reader :extracount
  # 考慮時間１回の時間[sec]
  attr_reader :sec_extracount
  # 報知が必要かどうかの状態
  attr_reader :houchi

  # 時間の設定(途中から用？)
  #
  # @param tt 持ち時間
  # @param by 秒読み
  # @param ex 考慮時間
  # @param lt 最終確認時刻
  def read(tt, by, ex, lt)
    @thinktime = tt
    @byouyomi = by
    @extracount = ex
    @dt_lasttick = lt
  end

  # 何日分の秒
  #
  # @param sec 秒数
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
    if @byouyomi > 0
      @houchi = HOUCHI_REMINDER if bef != aft
      return
    end

    @extracount -= 1 # 考慮時間を１回消費
    @byouyomi += @sec_extracount

    case @extracount <=> 0
    when 1 then @houchi = HOUCHI_USEEXTRA
    when 0 then @houchi = HOUCHI_NOEXTRA
    else return @houchi = HOUCHI_TMOUT
    end
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
end
