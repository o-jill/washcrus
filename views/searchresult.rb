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
  # @param title  ページタイトル
  # @param name   ページヘッダタイトル
  def initialize(header, title, name)
    @header = header
    @title = title
    @name = name
  end

  # 先手を検索
  #
  # @param tdb  対局情報オブジェクト
  # @param ply1 検索する先手の名前
  # @return 対局IDのリスト
  def findply1(tdb, ply1)
    return [] if ply1.empty?

    res = tdb.findnameb(ply1)
    res.empty? ? nil : res.keys
  end

  # 後手を検索
  #
  # @param tdb  対局情報オブジェクト
  # @param ply2 検索する後手の名前
  # @return 対局IDのリスト
  def findply2(tdb, ply2)
    return [] if ply2.empty?

    res = tdb.findnamew(ply2)
    res.empty? ? nil : res.keys
  end

  # ２つの対局IDのリストをマージする。(重複削除)
  #
  # @param id1 対局IDのリスト
  # @param id2 対局IDのリスト
  # @return マージしたリスト
  def merge2ids(id1, id2)
    if id1.empty? && id2.empty?
      []
    elsif id1.empty?
      id2
    elsif id2.empty?
      id1
    else
      id1.merge(id2)
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
    res.empty? ? nil : res.keys
  end

  # 最終着手日から検索
  #
  # @param tdb  対局情報オブジェクト
  # @param ply1 検索する先手の名前
  # @param ply2 検索する後手の名前
  # @param from この日から
  # @param to   この日まで
  # @return 対局IDのリスト
  def findgameid(tdb, ply1, ply2, from, to)
    id1 = findply1(tdb, ply1)
    return nil if id1.nil?

    id2 = findply2(tdb, ply2)
    return nil if id2.nil?

    id3 = findtime(tdb, from, to)
    return nil if id3.nil?

    id12 = merge2ids(id1, id2)
    merge2ids(id12, id3)
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
  # @param ply1 検索する先手の名前
  # @param ply2 検索する後手の名前
  # @param from この日から
  # @param to   この日まで
  # @return 対局IDのリスト
  def searchgames_(ply1, ply2, from, to)
    tdb = TaikyokuFile.new
    tdb.read

    foundid = findgameid(tdb, ply1, ply2, from, to)

    return nil if foundid.nil? || foundid.empty?

    res = []
    foundid.each do |i|
      res << tdb.probe(i)
    end
    res
  end

  # 対局情報の出力
  #
  # @param game 対局情報{id:, idb:, idw:, nameb:, namew:, time: , comment:}
  def print_res(game)
    print <<-GAMEINFO.unindent
      <tr>
       <td><a href='washcrus.rb?game/#{game[:id]}'>#{game[:id]}</a></td>
       <td>#{game[:nameb]}</td><td>#{game[:namew]}</td><td>#{game[:time]}</td>
       <td><a href='washcrus.rb?dlkifu/#{game[:id]}' target=_blank>download</a></td>
      </tr>
      GAMEINFO
  end

  # 画面の表示
  #
  # @param userinfo ユーザ情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    res = searchgames(params)

    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenu(@name, userinfo)

    if res.nil? || res.empty?
      print '<p>not found ...</p>'
    else
      print <<-RESULT_TABLE.unindent
        <TABLE align='center' border='1'>
        <caption>検索結果</caption>
        <tr><th>id</th><th>先手</th><th>後手</th>
        <th>time</th><th>download</th></tr>
        RESULT_TABLE
      res.each do |game|
        print_res(game)
      end
      print '</TABLE>'
    end

    CommonUI::HTMLfoot()
  end
end
