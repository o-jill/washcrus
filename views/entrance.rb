# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'
require './game/userinfo.rb'
require './views/common_ui.rb'

#
# 入り口画面
#
class EntranceScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
  end

  # LOGO
  def show_logo_tmpl(leto, rito, lebo, ribo)
    print <<-LOGO_TEXT.unindent
      <TABLE bgcolor='#cc9933' align='center' bordercolor='black' border='0' frame='void' rules='all'>
       <TR><TD></TD>
        <TD class='logo_edge_ud'></TD>
        <TD class='logo_edge_ud'></TD>
        <TD></TD></TR>
       <TR><TD class='logo_edge_lr'></TD>
        <TD class='logo_center'>#{leto}</TD>
        <TD class='logo_center'>#{rito}</TD>
        <TD class='logo_edge_lr'></TD></TR>
       <TR><TD class='logo_edge_lr'></TD>
        <TD class='logo_center'>#{lebo}</TD>
        <TD class='logo_center'>#{ribo}</TD>
        <TD class='logo_edge_lr'></TD></TR>
       <TR><TD></TD>
        <TD class='logo_edge_ud'></TD>
        <TD class='logo_edge_ud'></TD>
        <TD></TD></TR>
      </TABLE>
    LOGO_TEXT
  end

  LOGO_TEXT = [
    %w[銀 金 金 角],
    %w[香 銀 玉 桂],
    %w[銀 香 桂 玉],
    ['角', '銀', '飛', ''],
    ['角', '', '銀', '飛'],
    %w[桂 銀 金 玉],
    %w[銀 桂 玉 金]
  ].freeze

  # ロゴの表示
  def show_logo
    koma = LOGO_TEXT.sample
    show_logo_tmpl(*koma)
  end

  # 開発用テスト表示
  def test_area
    scriptname = File.basename($PROGRAM_NAME)
    print <<-TEST_AREA.unindent
      <span id=signup><A href='#{scriptname}?signup'>signup</a></span><BR>
      <span id=signin><A href='#{scriptname}?login'>signin</a></span><BR>
      <span id=users><A href='#{scriptname}?userlist'>users</a></span><BR>
      <span id=matchs><A href='#{scriptname}?matchlist'>matchs</a></span><BR>
      <span id=signout><A href='#{scriptname}?logout'>signout</a></span><BR>
      <span id=create><A href='#{scriptname}?newgame'>newgame</a></span><BR>
      <A href='index.rb?anywhere'>anywhere</a>
    TEST_AREA
  end

  #
  # 入り口画面の表示
  #
  # @param userinfo ユーザ情報
  def show(userinfo)
    CommonUI.html_head(@header)

    CommonUI.html_menu(userinfo)

    puts "<script type='text/javascript' defer src='js/entrance.js'></script>"

    # LOGO
    show_logo

    userinfo.put_visitcount

    # test
    # test_area

    # puts "<pre>header:#{header}</pre>"

    CommonUI.html_foot
  end
end
