# -*- encoding: utf-8 -*-

require 'json'

#
# 指し手モジュール
#
# 指し手ハッシュ:
#  data = {
#    'from' => @from, 'to' => @to, 'piece' => @piece, 'color' => @color
#  }
#  data['promote'] = @promote if @promote
#  data['capture'] = @capture unless @capture.nil?
#  data['same'] = @same if @same
#
module JsonMove
  # 玉をとったかどうか
  #
  # @param ha 取られた駒
  # @return 玉をとったらtrue
  def self.catch_gyoku?(ha)
    ha['capture'] == 'OU'
  end

  # 投了などの特別な手のハッシュ
  #
  # @param tx 特別な手の文字列
  # @return 特別な手のハッシュ
  def self.fromtextspecial(tx)
    { special: tx[1, tx.length - 1] }
  end

  Koma = %w[FU KY KE GI KI KA HI OU TO NY NK NG UM RY].freeze

  # 駒が有効かどうかの確認
  #
  # @param cc CSA駒文字
  # @return 駒が有効ならcc, 無効ならnil
  def self.checkpiece(cc)
    return if cc == '__'
    return unless Koma.find_index(cc)
    cc
  end

  # 先手か後手の読み取り
  #
  # @param ch 先後を示す文字
  # @return 0:先手, 1:後手, nil:その他
  def self.read_sengo(ch)
    case ch[0]
    when '+' then 0
    when '-' then 1
      # else          nil
    end
  end

  # 移動元座標をハッシュに変換
  #
  # @param xy 移動元
  # @return nil:エラー or ret[val:]:nil or {'x' => x, 'y'=>y}
  def self.read_fromxy(xy)
    x = xy[1]
    y = xy[2]
    return nil unless ('0'..'9').cover?(x) && ('0'..'9').cover?(y)
    { val: x == '0' && y == '0' ? nil : { 'x' => x.to_i, 'y' => y.to_i } }
  end

  # 行き先座標をハッシュに変換
  #
  # @param xy 行き先
  # @return {'x' => x, 'y'=>y}
  def self.read_toxy(xy)
    x = xy[3]
    y = xy[4]
    { 'x' => x.to_i, 'y' => y.to_i } \
        if ('1'..'9').cover?(x) && ('1'..'9').cover?(y)
  end

  # 取った駒の読み取り
  #
  # @param cap 取った駒
  # @param data 指し手ハッシュ
  # @return 指し手ハッシュ
  def self.read_capture(cap, data)
    mycapture = checkpiece(cap[7, 2])
    data['capture'] = mycapture if mycapture
    data
  end

  # 成ったかどうかの確認
  # 成っていればdata['capture']がtrueになる。
  #
  # @param ch 成ったかどうかを表す文字
  # @param data 指し手ハッシュ
  # @return nil:エラー or 指し手ハッシュ
  def self.read_promote(ch, data)
    if ch[9] == 'P'
      data['promote'] = true
    elsif ch[9]
      return nil
    end

    data
  end

  # 指し手文字列の読み取り
  #
  # @param tx 指し手文字列[+-][0-9]{4}(?:FU|KY|KE|...)(?:__|FU|KY|KE|...)P?
  # @return エラー:nil, 正常終了:指し手ハッシュ
  def self.read_move(tx)
    mycolor = read_sengo(tx)
    txy = read_toxy(tx)
    mypiece = checkpiece(tx[5, 2])

    ret = {
      'to' => txy,
      'piece' => mypiece,
      'color' => mycolor
    }
    ret.each_value do |vl|
      return nil unless vl
    end

    fxy = read_fromxy(tx)
    return unless fxy
    ret['from'] = fxy[:val]

    ret = read_capture(tx, ret)

    ret = read_promote(tx, ret)

    ret
  end

  # 指し手文字列から指し手ハッシュに変換
  #
  # @param tx 指し手文字列[+-][0-9]{4}(?:FU|KY|KE|...)(?:__|FU|KY|KE|...)P?
  #          %TORYO, %SENNICHITEなど
  # @return エラー:nil, 正常終了:指し手ハッシュ
  def self.fromtext(tx)
    return unless tx

    return fromtextspecial(tx) if tx[0] == '%'

    return unless (9..10).cover?(tx.length)

    read_move(tx)
  end
end
