# -*- encoding: utf-8 -*-

require 'json'

#
# 指し手クラス
#
class JsonMove
  # 初期化
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

  # 駒を打つ
  #
  # to    {x: 1~9, y: 1~9}
  # koma  打つ駒
  # teban 0:sente, 1:gote
  def utu(to, koma, teban)
    move(nil, to, koma, teban)
  end

  # 駒を動かす
  #
  # from {x: 1~9, y: 1~9}
  # to   {x: 1~9, y: 1~9}
  # koma  動かす駒/打つ駒
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

  # 成る
  def nari
    @promote = true
  end

  # 取る
  #
  # @param koma 取られる駒
  def toru(koma)
    @capture = koma
  end

  # 同xxかどうか
  #
  # @param a {'from'=>{'x'=>x,'y'=>y},'to'=>{'x'=>x,'y'=>y}}
  # @return 同xxのときtrue
  def checkdou(a)
    # @same =
    # (@to['x'] == a['to']['x'] &&
    #  @to['y'] == a['to']['y'])
    @same = (@to == a['to'])
  end

  # 玉をとったかどうか
  #
  # @param a 取られた駒
  # @return 玉をとったらtrue
  def self.catchOU?(a)
    a['capture'] == 'OU'
  end

  # ハッシュの生成
  #
  # @return 指し手ハッシュ
  def genhash
    data = {
      'from' => @from, 'to' => @to, 'piece' => @piece, 'color' => @color
    }
    data['promote'] = @promote if @promote
    data['capture'] = @capture unless @capture.nil?
    data['same'] = @same if @same
    data
  end

  # 投了などの特別な手のハッシュ
  #
  # @param t 特別な手の文字列
  # @return 特別な手のハッシュ
  def self.fromtextspecial(t)
    { special: t[1, t.length - 1] }
  end

  Koma = %w[FU KY KE GI KI KA HI OU TO NY NK NG UM RY].freeze

  # 駒が有効かどうかの確認
  #
  # @param cc CSA駒文字
  # @return 駒が有効ならcc, 無効ならnil
  def self.checkpiece(cc)
    return if cc == '__'
    return if Koma.find_index(cc).nil?
    cc
  end

  # 先手か後手の読み取り
  #
  # @param c 先後を示す文字
  # @return 0:先手, 1:後手, nil:その他
  def self.read_sengo(c)
    case c
    when '+' then 0
    when '-' then 1
      # else          nil
    end
  end

  # 移動元座標をハッシュに変換
  #
  # @param x 移動元筋
  # @param y 移動元段
  # @return {ret:0(エラー)} or {ret:1, val:nil or {'x' => x, 'y'=>y}}
  def self.read_fromxy(x, y)
    return { ret: 0 } unless ('0'..'9').cover?(x) && ('0'..'9').cover?(y)
    ret = { ret: 1 }
    ret[:val] = x == '0' && y == '0' ? nil : { 'x' => x.to_i, 'y' => y.to_i }
    ret
  end

  # 行き先座標をハッシュに変換
  #
  # @param x 行き先筋
  # @param y 行き先段
  # @return {'x' => x, 'y'=>y}
  def self.read_toxy(x, y)
    { 'x' => x.to_i, 'y' => y.to_i } \
        if ('1'..'9').cover?(x) && ('1'..'9').cover?(y)
  end

  # 指し手文字列の読み取り
  #
  # @param t 指し手文字列[+-][0-9]{4}(?:FU|KY|KE|...)(?:__|FU|KY|KE|...)P?
  # @return 指し手ハッシュ
  def self.read_move(t)
    mycolor = read_sengo(t[0])
    txy = read_toxy(t[3], t[4])
    mypiece = checkpiece(t[5, 2])

    ret = {
      'to' => txy,
      'piece' => mypiece,
      'color' => mycolor
    }
    ret.values.each do |v|
      return nil if v.nil?
    end

    fxy = read_fromxy(t[1], t[2])
    return nil if fxy[:ret].zero?
    ret['from'] = fxy[:val]

    mycapture = checkpiece(t[7, 2])
    ret['capture'] = mycapture unless mycapture.nil?

    if t[9] == 'P'
      ret['promote'] = true
    elsif !t[9].nil?
      return nil
    end

    ret
  end

  # 指し手文字列から指し手ハッシュに変換
  #
  # @param t 指し手文字列[+-][0-9]{4}(?:FU|KY|KE|...)(?:__|FU|KY|KE|...)P?
  #          %TORYO, %SENNICHITEなど
  # @return エラー:nil, 正常終了:指し手ハッシュ
  def self.fromtext(t)
    return if t.nil?

    return fromtextspecial(t) if t[0] == '%'

    return unless (9..10).cover?(t.length)

    read_move(t)
  end
end
