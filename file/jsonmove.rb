# -*- encoding: utf-8 -*-

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
    @same = false
  end

  attr_reader :from, :to, :piece, :color, :promote, :capture, :same

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
    @same = false
  end

  def nari
    @promote = true
  end

  def toru(koma)
    @capture = koma
  end

  def checkdou(a)
    @same = (@to == a.to)
  end

  def genhash
    data = {
      'from' => @from, 'to' => @to, 'piece' => @piece, 'color' => @color
    }
    data['promote'] = @promote if @promote
    data['capture'] = @capture unless @capture.nil?
    data['same'] = @same if @same
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

  def self.read_sengo(c)
    case c
    when '+' then 0
    when '-' then 1
      # else          nil
    end
  end

  def self.read_fromxy(x, y)
    return { rt: 0 } unless ('0'..'9').cover?(x) && ('0'..'9').cover?(y)
    ret = { rt: 1 }
    ret[:vl] = x == '0' && y == '0' ? nil : { 'x' => x.to_i, 'y' => y.to_i }
    ret
  end

  def self.read_toxy(x, y)
    { 'x' => x.to_i, 'y' => y.to_i } \
        if ('1'..'9').cover?(x) && ('1'..'9').cover?(y)
  end

  # [+-][0-9][0-9][0-9][0-9]{FU|KY|KE|...}{__|FU|KY|KE|...}P?
  # %TORYO, %SENNICHITEなど
  def self.fromtext(t)
    return if t.nil?

    return fromtextspecital(t) if t[0] == '%'

    return unless (9..10).cover?(t.length)

    mycolor = read_sengo(t[0])
    return nil if mycolor.nil?
    ret = { 'color' => mycolor }

    fxy = read_fromxy(t[1], t[2])
    return nil if fxy[:rt].zero?
    ret['from'] = fxy[:vl]

    txy = read_toxy(t[3], t[4])
    return nil if txy.nil?
    ret['to'] = txy

    mypiece = checkpiece(t[5, 2])
    return nil if mypiece.nil?
    ret['piece'] = mypiece

    mycapture = checkpiece(t[7, 2])
    ret['capture'] = mycapture unless mycapture.nil?

    return nil unless t[9].nil? || t[9] == 'P'
    ret['promote'] = true if t[9] == 'P'

    ret
  end
end
