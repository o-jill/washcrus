# -*- encoding: utf-8 -*-

# require 'rubygems'
require 'unindent'

require './game/userinfo.rb'
require './views/common_ui.rb'
require './file/taikyokufile.rb'

#
# 検索結果画面
#
class SearchResultScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # 先手を検索
  #
  # @param tdb  対局情報オブジェクト
  # @param plyb 検索する先手の名前
  # @return 対局IDのリスト
  def findplyb(tdb, plyb)
    return [] if plyb.empty?

    res = tdb.findnameb(plyb)
    res.keys
  end

  # 後手を検索
  #
  # @param tdb  対局情報オブジェクト
  # @param plyw 検索する後手の名前
  # @return 対局IDのリスト
  def findplyw(tdb, plyw)
    return [] if plyw.empty?

    res = tdb.findnamew(plyw)
    res.keys
  end

  # ２つの対局IDのリストをマージする。(重複削除)
  #
  # @param idb 対局IDのリスト
  # @param idw 対局IDのリスト
  # @return マージしたリスト
  def merge2ids(idb, idw)
    if idb.empty? && idw.empty?
      []
    elsif idb.empty?
      idw
    elsif idw.empty?
      idb
    else
      idb.merge(idw)
    end
  end

  # 最終着手日から検索
  #
  # @param tdb  対局情報オブジェクト
  # @param from この日から
  # @param to   この日まで
  # @return 対局IDのリスト
  def findtime(tdb, from, to)
    return [] if from.empty? && to.empty?

    tdb.findtime(from, to).keys
  end

  # 最終着手日から検索
  #
  # @param tdb  対局情報オブジェクト
  # @param plyb 検索する先手の名前
  # @param plyw 検索する後手の名前
  # @param from この日から
  # @param to   この日まで
  # @return 対局IDのリスト。検索結果がない時nil。
  def findgameid(tdb, plyb, plyw, from, to)
    idb = findplyb(tdb, plyb)

    idw = findplyw(tdb, plyw)

    idt = findtime(tdb, from, to)

    idbw = merge2ids(idb, idw)
    ret = merge2ids(idbw, idt)

    return nil if ret.empty?
    ret
  end

  # 対局を検索
  #
  # @param params 検索条件
  # @return 対局IDのリスト
  def searchgames(plys, plyg, tffrom, tfto)
    searchgames_(plys[0], plyg[0], tffrom[0], tfto[0])
  end

  # 対局を検索
  #
  # @param plyb 検索する先手の名前
  # @param plyw 検索する後手の名前
  # @param from この日から
  # @param to   この日まで
  # @return 対局IDのリスト
  def searchgames_(plyb, plyw, from, to)
    tdb = TaikyokuFile.new
    tdb.read

    foundid = findgameid(tdb, plyb, plyw, from, to)
    return nil unless foundid

    foundid.map do |i|
      tdb.content.probe(i)
    end
  end

  # 対局情報の出力
  #
  # @param game 対局情報{id:, idb:, idw:, nameb:, namew:, time: , comment:}
  def resultrow(id: 'gid', nameb: 'b', namew: 'w', time: '0 0', **_other)
    arow = <<-GAMEINFO.unindent
      <tr>
       <td><a href='index.rb?game/#{id}'>
        <img src='image/right_fu.png' alt='#{id}' title='move to this game!'>
        <small>#{id}</small>
       </a></td>
       <td>#{nameb}</td><td>#{namew}</td><td>#{time}</td>
       <td><a href='index.rb?dlkifu/#{id}' target=_blank>
        <img src='image/dl_kif.png' alt='#{id}' title='download kif!'>
       </a></td>
      </tr>
    GAMEINFO
    arow
  end

  # 検索結果の出力
  def print_result(res)
    return '<p>not found ...</p>' unless res && res.size.nonzero?

    rows = res.map do |game|
      resultrow(**game)
    end

    str = <<-RESULT_TABLE.unindent
      <TABLE align='center' border='1'>
      <caption>検索結果</caption>
      <tr><th>ID</th><th>先手</th><th>後手</th>
      <th>着手日時</th><th>棋譜</th></tr>
      #{rows.join}
      </TABLE>
    RESULT_TABLE
    str
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    res = searchgames(
      params['player1'], params['player2'],
      params['time_frame_from'], params['time_frame_to']
    )

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    print print_result(res)

    CommonUI.html_foot
  end
end
