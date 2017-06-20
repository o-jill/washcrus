#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'json'

#
# 指し手クラス
#
class JsonMove
  def initialize
    @from = { 'x' => -1, 'y' => -1 }
    @to   = { 'x' => -1, 'y' => -1 }
    @piece = 'OU'
    @color = 0
    @promote = false
    @capture = nil # 'OU'
  end

  attr_reader :from, :to, :piece, :color, :promote, :capture

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
    data = {
      'from' => @from, 'to' => @to, 'piece' => @piece, 'color' => @color
    }
    data['promote'] = @promote if @promote
    data['capture'] = @capture unless @capture.nil?
    data
  end

  def self.fromtextspecital(t)
    { special: t[1, t.length - 1] }
  end

  Koma = %w[FU KY KE GI KI KA HI OU TO NY NK NG UM RY].freeze

  def self.checkpiece(cc)
    return if cc == '__'
    return if Koma.find_index(cc).nil?
    cc
  end

  # [+-][0-9][0-9][0-9][0-9]{FU|KY|KE|...}{__|FU|KY|KE|...}P?
  # %TORYO, %SENNICHITEなど
  def self.fromtext(t)
    return fromtextspecital(t) if t[0] == '%'

    return unless (9..10).include?(t.length)

    if t[0] == '+'
      mycolor = 0
    elsif t[0] == '-'
      mycolor = 1
    else
      return nil
    end
    ret = { 'color' => mycolor }

    x = t[1]
    y = t[2]
    return nil unless ('0'..'9').include?(x)
    return nil unless ('0'..'9').include?(y)
    if x == '0' && y == '0'
      ret['from'] = nil
    else
      ret['from'] = { 'x' => x.to_i, 'y' => y.to_i }
    end

    x = t[3]
    y = t[4]
    return nil unless ('1'..'9').include?(x)
    return nil unless ('1'..'9').include?(y)
    ret['to'] = { 'x' => x.to_i, 'y' => y.to_i }

    mypiece = checkpiece(t[5, 2])
    return nil if mypiece.nil?
    ret['piece'] = mypiece

    mycapture = checkpiece(t[7, 2])
    ret['capture'] = mycapture unless mycapture.nil?

    case t[9]
    when 'P' then ret['promote'] = true
    when nil then
    else return nil
    end

    ret
  end
end
