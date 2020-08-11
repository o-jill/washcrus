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

    res = tdb.findtime(from, to)
    res.keys
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
    return nil if idb.empty?

    idw = findplyw(tdb, plyw)
    return nil if idw.empty?

    idt = findtime(tdb, from, to)
    return nil if idt.empty?

    idbw = merge2ids(idb, idw)
    ret = merge2ids(idbw, idt)

    return nil if ret.empty?
    ret
  end

  # 対局を検索
  #
  # @param params 検索条件
  # @return 対局IDのリスト
  def searchgames(params)
    searchgames_(params['player1'][0], params['player2'][0],
                 params['time_frame_from'][0], params['time_frame_to'][0])
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

    res = []
    foundid.each do |i|
      res << tdb.content.probe(i)
    end
    res
  end

  # 対局情報の出力
  #
  # @param game 対局情報{id:, idb:, idw:, nameb:, namew:, time: , comment:}
  def print_res(game)
    gid = game[:id]
    print <<-GAMEINFO.unindent
      <tr>
       <td><a href='index.rb?game/#{gid}'>
        <img src='image/right_fu.png' alt='#{gid}' title='move to this game!'>
        <small>#{gid}</small>
       </a></td>
       <td>#{game[:nameb]}</td><td>#{game[:namew]}</td><td>#{game[:time]}</td>
       <td><a href='index.rb?dlkifu/#{gid}' target=_blank>
        <img src='image/dl_kif.png' alt='#{gid}' title='download kif!'>
       </a></td>
      </tr>
    GAMEINFO
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    res = searchgames(params)

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    if res && !res.empty?
      print <<-RESULT_TABLE.unindent
        <TABLE align='center' border='1'>
        <caption>検索結果</caption>
        <tr><th>ID</th><th>先手</th><th>後手</th>
        <th>着手日時</th><th>棋譜</th></tr>
      RESULT_TABLE
      res.each do |game|
        print_res(game)
      end
      print '</TABLE>'
    else
      print '<p>not found ...</p>'
    end

    CommonUI.html_foot
  end
end
