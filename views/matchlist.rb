# -*- encoding: utf-8 -*-

require './file/taikyokufile.rb'
require './file/matchinfofile.rb'
require './game/taikyokudata.rb'
require './game/webapi_sfenreader.rb'
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

  # 局面画像生成サイトへのリンクの生成
  #
  # @return 局面画像へのリンク
  def kyokumen_img(gid)
    tkd = TaikyokuData.new
    tkd.log = nil#@log
    tkd.setid(gid)
    tkd.lock do
      tkd.read
    end
    mi = tkd.mi

    sr = WebApiSfenReader.new
    sr.setplayers(mi.playerb.name, mi.playerw.name)
    sr.sfen = mi.sfen
    sr.setlastmovecsa(mi.lastmove)

    "<img src='#{sr.genuri}' alt='局面図画像#{gid}' title='move to #{gid}!'>"
  end

  # 対局情報の出力
  #
  # @param game 対局情報{id:, idb:, idw:, nameb:, namew:, turn:, time:, comment:}
  def print_res(game)
    print <<-GAMEINFO.unindent
      <tr>
       <td rowspan='5'><a href='index.rb?game/#{game[:id]}'>
        #{kyokumen_img(game[:id])}
        <!-- img src='image/right_fu.png' alt='#{game[:id]}' title='move to this game!'>
        <small>#{game[:id]}</small -->
       </a></td>
       <!-- th>ID</th -->
       <th>先手</th>
       <td>#{game[:nameb]}</td></tr>
      <tr><th>後手</th><td>#{game[:namew]}</td></tr>
      <tr><th>手番</th><td>#{CommonUI.turn2str(game[:turn])}</td></tr>
      <tr><th>着手日時</th><td>#{game[:time]}</td></tr>
      <tr><th>コメント</th><td>#{game[:comment]}</td></tr>
      </tr>
      GAMEINFO
  end

  # 最近の対局のリストの出力
  #
  # @return 対局リスト
  def select_recentgames
    tdb = TaikyokuFile.new
    tdb.read
    from = Time.now - 6_480_000 # 30days
    res = tdb.findtime(from.to_s, '') # {gid, time}

    games = []
    res.each_key do |id|
      games << tdb.content.probe(id)
    end
    games
  end

  # 最近の対局のリストの出力
  #
  # @param games 対局リスト
  def put_recentgames(games)
    print <<-RESULT_TABLE.unindent
      <TABLE align='center' border='1'>
      <caption><a href='#chu'>対局中へ</a> <a name='recent'>30日以内</a></caption>
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

    put_recentgames(select_recentgames)

    CommonUI.html_foot
  end
end
