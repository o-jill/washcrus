# -*- encoding: utf-8 -*-
# frozen_string_literal: true

# ユーザの戦績
class WinsLoses
  # @param wnls { swin:先手勝数, slose:先手負数, gwin:後手勝数, glose:後手負数 }
  def initialize(wnls)
    @seiseki = calc_sgtotal(wnls)
    @seiseki = calctotal(seiseki)
  end

  attr_reader :seiseki

  # 合計勝ち負けの計算
  #
  # @param wnls {swin:先手勝数, slose:先手負数, gwin:後手勝数, glose:後手負数}
  # @return wnlsに合計勝ち負け
  def calctotal(wnls)
    # wnls[:stotal] = wnls[:swin] + wnls[:slose]
    # wnls[:gtotal] = wnls[:gwin] + wnls[:glose]

    wnls[:wins] = wnls[:swin] + wnls[:gwin]
    wnls[:loses] = wnls[:slose] + wnls[:glose]

    wnls[:total] = wnls[:wins] + wnls[:loses] # + wnls[:draws]

    wnls
  end

  # 先手と後手の総対局数を計算
  #
  # @param wnls {swin:先手勝数, slose:先手負数, gwin:後手勝数, glose:後手負数}
  # @return wnlsに:stotal, :gtotalが追加された計算結果。
  def calc_sgtotal(wnls)
    wnls[:stotal] = wnls[:swin] + wnls[:slose]
    wnls[:gtotal] = wnls[:gwin] + wnls[:glose]
    wnls
  end

  # 勝率の文字列を生成
  #
  # @param total 局数
  # @param win   勝数
  # @return 勝率の文字列 '0.000'
  def calcratestr(total, win)
    format('%<rate>.3f', rate: total.zero? ? 0 : win / total.to_f)
  end

  # 勝ち負け一段分の出力
  #
  # @param title 項目名
  # @param win_sym 勝数
  # @param lose_sym 負数
  def put_seiseki(title, win_sym, lose_sym)
    win = seiseki[win_sym]
    lose = seiseki[lose_sym]
    rate = calcratestr(win + lose, win)
    puts "<tr><th>#{title}</th><td>#{win}勝#{lose}敗</td><td>#{rate}</td></tr>"
  end

  # 成績表の出力
  def put(name)
    puts "<table align='center' border='3'><caption>#{name}の戦績</caption>"
    put_seiseki('総合成績', :wins, :loses)
    put_seiseki('先手成績', :swin, :slose)
    put_seiseki('後手成績', :gwin, :glose)
    puts '</table>'
  end
end
