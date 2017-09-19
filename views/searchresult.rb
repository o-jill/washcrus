# -*- encoding: utf-8 -*-

# require 'rubygems'
# require 'unindent'

require './game/userinfo.rb'
require './views/common_ui.rb'
require './file/taikyokufile.rb'

#
# 検索結果画面
#
class SearchResultScreen
  def initialize(header, title, name)
    @header = header
    @title = title
    @name = name
  end

  def findply1(tdb, ply1)
    return [] if ply1.empty?

    res = tdb.findnameb(ply1)
    res.empty? ? nil : res.keys
  end

  def findply2(tdb, ply2)
    return [] if ply2.empty?

    res = tdb.findnamew(ply2)
    res.empty? ? nil : res.keys
  end

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

  def findtime(tdb, from, to)
    return [] if from.empty? && to.empty?

    res = tdb.findtime(from, to)
    res.empty? ? nil : res.keys
  end

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

  def searchgames(params)
    searchgames_(params['player1'][0], params['player2'][0],
                 params['time_frame_from'][0], params['time_frame_to'][0])
  end

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

  def print_res(game)
    print <<-GAMEINFO.unindent
      <tr>
       <td><a href='washcrus.rb?game/#{game[:id]}' target=_blank>#{game[:id]}</a></td>
       <td>#{game[:nameb]}</td><td>#{game[:namew]}</td><td>#{game[:time]}</td>
       <td><a href='washcrus.rb?dlkifu/#{game[:id]}' target=_blank>download</a></td>
      </tr>
      GAMEINFO
  end

  def show(userinfo, params)
    res = searchgames(params)

    CommonUI::HTMLHead(@header, @title)
    CommonUI::HTMLmenuLogIn(@name, !userinfo.invalid?)

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
