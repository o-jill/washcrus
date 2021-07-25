# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'time'
require './file/jkftime.rb'

# {
#  "time": {
#   "now": {
#     "m": 0, "s": 0
#    },
#    "total": {
#     "h": 0, "m": 0, "s": 0
#    }
# }

# 消費時間管理クラス
class JsonConsumption
  # 初期化
  #
  # @param itotal JkfTimeオブジェクト
  def initialize(itotal = {})
    @now = JkfTime.new
    @total = JkfTime.new
    @total << itotal
  end

  # ハッシュの生成
  #
  # @return {'now' => 今回の消費時間, 'total' => トータルの消費時間}
  def genhash
    { 'now' => @now.genhash, 'total' => @total.genhash }
  end

  # トータルの消費時間を増やす
  #
  # @param hash_t 消費時間
  def settotal(hash_t)
    @total << hash_t if hash_t
  end

  # 時間差を計算して消費時間を計算。
  # トータル消費時間にも適用。
  #
  # @param t_new [Time] 着手時刻
  # @param t_old [Time] 前回の着手時刻
  def diff(t_new, t_old)
    @now.fromsec((t_new - t_old).to_i)
    @total.add(@now)
  end

  # 時間差を計算して消費時間を計算。
  # トータル消費時間にも適用。
  #
  # @param t_new [String] 着手時刻
  # @param t_old [String] 前回の着手時刻
  def diff_t(t_new, t_old)
    diff(Time.parse(t_new), Time.parse(t_old))
  end
end
