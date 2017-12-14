# -*- encoding: utf-8 -*-

require './file/taikyokufile.rb'
require './views/common_ui.rb'

#
# matchlist画面
#
class MatchListScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # 対局中の対局のリストの出力
  def put_taikyokuchu
    tkcdb = TaikyokuChuFile.new
    tkcdb.read
    tkcdb.to_html('<a name="chu">対局中</a> <a href="#recent">30日以内へ</a>')
  end

  # 対局情報の出力
  #
  # @param game 対局情報{id:, idb:, idw:, nameb:, namew:, turn:, time:, comment:}
  def print_res(game)
    print <<-GAMEINFO.unindent
      <tr>
       <td><a href='washcrus.rb?game/#{game[:id]}'>
        <img src='image/right_fu.png' alt='#{game[:id]}' title='move to this game!'>
        <small>#{game[:id]}</small>
       </a></td>
       <td>#{game[:nameb]}</td><td>#{game[:namew]}</td>
       <td>#{TaikyokuFileContent.turn2str(game[:turn])}</td>
       <td>#{game[:time]}</td><td>#{game[:comment]}</td>
      </tr>
      GAMEINFO
  end

  # 最近の対局のリストの出力
  def put_recentgames
    tdb = TaikyokuFile.new
    tdb.read
    from = Time.now - 6_480_000 # 30days
    res = tdb.findtime(from.to_s, '') # {gid, time}

    games = []
    res.each_key do |i|
      games << tdb.probe(i)
    end

    print <<-RESULT_TABLE.unindent
      <TABLE align='center' border='1'>
      <caption><a href='#chu'>対局中へ</a> <a name='recent'>30日以内</a></caption>
      <tr><th>id</th><th>先手</th><th>後手</th><th>手番</th>
      <th>time</th><th>コメント</th></tr>
      RESULT_TABLE
    games.each do |game|
      print_res(game)
    end
    puts '</TABLE>'
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  def show(userinfo)
    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    put_taikyokuchu

    puts '<HR>'

    put_recentgames

    CommonUI.html_foot
  end
end
