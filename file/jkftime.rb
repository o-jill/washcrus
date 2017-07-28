# -*- encoding: utf-8 -*-

# "total": {
#  "h": 0, "m": 0, "s": 0
# }

# TimeFormatter for JKF
class JkfTime
  def initialize
    @hour = 0
    @min = 0
    @sec = 0
  end

  attr_reader :hour, :min, :sec

  def genhash
    ret = { 's' => @sec, 'm' => @min }
    ret['h'] = @hour if @hour > 0
    ret
  end

  def fromsec(sec_)
    @hour = (sec_ / 3600).to_i
    sec_ -= @hour * 3600
    @min = (sec_ / 60).to_i
    sec_ -= @min * 60
    @sec = sec_
  end

  def normalize
    ketaagari_m = (@sec / 60).to_i
    @sec = @sec % 60
    ketaagari_h = ((@min + ketaagari_m) / 60).to_i
    @min = (@min + ketaagari_m) % 60
    @hour += ketaagari_h
  end

  def addsec(sec)
    @sec += sec

    normalize
  end

  def <<(hash)
    @hour += hash['h'] || 0
    @min += hash['m'] || 0
    @sec += hash['s'] || 0

    normalize
  end

  def add(rhs)
    @hour += rhs.hour
    @min += rhs.min
    @sec += rhs.sec

    normalize
  end
end
