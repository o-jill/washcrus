# -*- encoding: utf-8 -*-

# "total": {
#  "h": 0, "m": 0, "s": 0
# }

# TimeFormatter for JKF
class JkfTime
  # 初期化
  def initialize
    @hour = 0
    @min = 0
    @sec = 0
  end

  # @!attribute [r] hour
  #   @return 時間
  # @!attribute [r] min
  #   @return 分
  # @!attribute [r] sec
  #   @return 秒
  attr_reader :hour, :min, :sec

  # ハッシュオブジェクトの生成
  #
  # @return {'s'=>秒, 'm'=>分, 'h'=>時間(ゼロならnil)}
  def genhash
    ret = { 's' => @sec, 'm' => @min }
    ret['h'] = @hour if @hour > 0
    ret
  end

  # 秒から変換
  #
  # @param sec_ トータル秒数
  def fromsec(sec_)
    @hour = (sec_ / 3600).to_i
    sec_ -= @hour * 3600
    @min = (sec_ / 60).to_i
    sec_ -= @min * 60
    @sec = sec_
  end

  # 秒や分を60単位で整える
  def normalize
    ketaagari_m = (@sec / 60).to_i
    @sec = @sec % 60
    ketaagari_h = ((@min + ketaagari_m) / 60).to_i
    @min = (@min + ketaagari_m) % 60
    @hour += ketaagari_h
  end

  # 指定した秒数だけ増やす
  #
  # @param sec_ 秒数
  def addsec(sec_)
    @sec += sec_

    normalize
  end

  # 指定した時間だけ増やす
  #
  # @param hash {'s'=>秒(nil可), 'm'=>分(nil可), 'h'=>時間(nil可)}
  def <<(hash)
    @hour += hash['h'] || 0
    @min += hash['m'] || 0
    @sec += hash['s'] || 0

    normalize
  end

  # 指定した時間だけ増やす
  #
  # @param rhs JkfTimeオブジェクト
  def add(rhs)
    @hour += rhs.hour
    @min += rhs.min
    @sec += rhs.sec

    normalize
  end
end
