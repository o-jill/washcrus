#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'json'

#
# 指し手クラス
#
class JsonMove
  def initialize
    @from = { x: -1, y: -1 }
    @to   = { x: -1, y: -1 }
    @piece = 'OU'
    @color = 0
    @promote = false
    @capture = nil # 'OU'
  end

  # to    {x: 1~9, y: 1~9}
  # teban 0:sente, 1:gote
  def utu(to, koma, teban)
    move(nil, to, koma, teban)
  end

  # from {x: 1~9, y: 1~9}
  # to   {x: 1~9, y: 1~9}
  # teban 0:sente, 1:gote
  def move(from, to, koma, teban)
    @from = from
    @to = to
    @piece = koma
    @color = teban
    @promote = false
    @capture = nil
  end

  def nari
    @promote = true
  end

  def toru(koma)
    @capture = koma
  end

  def genhash
    data = { from: @from, to: @to, piece: @piece, color: @color }
    data['promote'] = @promote if @promote
    data['capture'] = @capture unless @capture.nil?
    data
  end
end
