# -*- encoding: utf-8 -*-
# frozen_string_literal: true

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
    tkcdb.to_html('<a name="chu">対局中</a> <a href="#recent">90日以内へ</a>')
  end

  # 最近の対局のリストの出力
  def put_taikyokuchu_img
    tkcdb = TaikyokuChuFile.new
    tkcdb.read
    puts <<-RESULT_TABLE.unindent
      <div align='center'>
       <a name="chu">対局中</a> <a href="#recent">90日以内へ</a>
      </div>
      <div id="taikyokuchu" class="taikyokuchu">
    RESULT_TABLE
    tkcdb.content.idbs.each_key do |gameid|
      game = tkcdb.content.findid(gameid)
      print_res(**game)
    end
    # puts '</TABLE>'
    puts '</div>'
  end

  # WebApiSfenReaderオブジェクトの生成と値のセット
  #
  # @param mif  対局情報
  # @param turn 手番
  #
  # @return WebApiSfenReaderオブジェクト
  def gen_sfen_reader(mif, turn)
    sr = WebApiSfenReader.new
    sr.setmatchinfo(mif)
    sr.setturn(turn)
    sr.settitle(mif.dt_lastmove)
    sr
  end

  # 局面画像生成サイトへのリンクの生成
  #
  # @param gid game id
  # @param turn 手番
  #
  # @return 局面画像へのリンク
  def kyokumen_img(gid, turn)
    tkd = TaikyokuData.new
    tkd.log = nil # @log
    tkd.setid(gid)
    tkd.lockex do
      tkd.read
    end
    mif = tkd.mif

    sr = gen_sfen_reader(mif, turn)

    "<img src='#{sr.genuri}' alt='局面図画像#{gid}'" \
    " title='move to game[#{gid}]!'>"
  end

  # 対局情報の出力
  #
  # @param game 対局情報{id:, turn:, comment:}
  # @option :id  対局ID
  # @option :turn 手番
  # @option :comment コメント
  def print_res(id:, turn:, comment:, **_others)
    print <<-GAMEINFO.unindent
      <table border='1'><tr><td><a href='index.rb?game/#{id}'>
        #{kyokumen_img(id, turn)}
       </a></td></tr>
      <tr><td>#{comment}</td></tr></table>
    GAMEINFO
  end

  # 最近の対局のリストの出力
  #
  # @return 対局リスト
  def select_recentgames
    tdb = TaikyokuFile.new
    tdb.read
    # from = Time.now - 60_480_000 # for test
    from = Time.now - 7_776_000 # 90days
    res = tdb.findtime(from.to_s, '') # {gid, time}

    res.keys.map do |id|
      tdb.content.findid(id)
    end
  end

  # 最近の対局のリストの出力
  #
  # @param games 対局リスト
  def put_recentgames(games)
    print <<-RESULT_TABLE.unindent
      <div align='center'>
       <a href='#chu'>対局中へ</a> <a name='recent'>90日以内</a>
      </div>
      <div id="taikyokurecent" class="taikyokuchu">
    RESULT_TABLE
    games.each do |game|
      print_res(**game)
    end
    puts '</div>'
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  def show(userinfo)
    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)

    # put_taikyokuchu
    put_taikyokuchu_img

    puts '<HR>'

    put_recentgames(select_recentgames)

    CommonUI.html_foot
  end
end
