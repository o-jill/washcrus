# -*- encoding: utf-8 -*-

require 'rubygems'
require 'erb'
require 'unindent'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './game/webapi_sfenreader.rb'
require './game/userinfo.rb'
require './views/common_ui.rb'

# 表示する
class GameHtml
  # 初期化
  #
  # @param gid Game ID
  # @param mi  MatchInfoFile
  # @param kif JsonKifu
  # @param ui  UserInfo
  def initialize(gid, mi, kif, ui)
    @gameid = gid
    @mi = mi
    @jkf = kif
    @userinfo = ui
    @log = nil
  end

  attr_accessor :log

  # 画面の表示
  #
  # @param header htmlヘッダ
  def put(header)
    @log.debug('print header')
    print header
    print <<-HTMLELEMENTS_HEADER.unindent
      <html>#{headerelement}
      <body>
      HTMLELEMENTS_HEADER

    CommonUI.html_menu(@userinfo)

    print <<-HTMLELEMENTS_BODY.unindent
      <div class=gamearea>
       <div id='notify_area' class='notify'>
        <BR>指されました。ページを再読込してください。
        <input type='image' style='vertical-align:middle;' id='btn_reload' src='./image/reloadbtn.png' onclick='location.reload(true);' alt='再読込' title='再読込'/>
        <BR><BR>
       </div>
       <div class=block>
        <section class='block_elem_ban' id='block_elem_ban'> #{banelement} </section>
        <section class='block_elem_kifu'> #{kifuelement} </section>
       </div>
       #{chatelement}
      </div>
      <HR><div style='text-align:right;'>ぢるっち(c)2017</div>
      #{hiddenelement}
      </body></html>
      HTMLELEMENTS_BODY
  end

  # 将棋盤の部品
  #
  # @return 部品の文字列
  def shogibanelement
    @log.debug('shogibanelement')
    ERB.new(File.read('./ui/gamehtml_shogiban.erb')).result(binding)
  end

  # 将棋盤まわりの部品
  #
  # @return 部品の文字列
  def banelement
    @log.debug('banelement')
    ret = <<-BOARD_TEXT.unindent
      #{shogibanelement}
      <script type='text/javascript' src='./js/shogi.v016.js'></script>
      <script type='text/javascript' src='./js/ui.v015.js' async></script>
      BOARD_TEXT

    ret += ERB.new(File.read('./ui/gamehtml_123neye.erb')).result(binding)

    sr = WebApiSfenReader.new
    sr.setplayers(@mi.playerb, @mi.playerw)
    sr.sfen = @mi.sfen
    sr.setlastmovecsa(@mi.lastmove)
    ret += "<a href='#{sr.genuri}' target='_blank'>局面図画像</a>"

    ret
  end

  # 画面上部の部品
  #
  # @return 部品の文字列
  def headerelement
    @log.debug('headerelement')
    stg = Settings.instance
    title = "#{stg.value['wintitle']} #{@mi.playerb}  vs  #{@mi.playerw}"
    ERB.new(File.read('./ui/gamehtml_header.erb')).result(binding)
  end

  # チャットまわりの部品
  #
  # @return 部品の文字列
  def chatelement
    @log.debug('chatelement')
    ERB.new(File.read('./ui/gamehtml_chat.erb')).result(binding)
  end

  # 棋譜まわりの部品
  #
  # @return 部品の文字列
  def kifuelement
    @log.debug('kifuelement')
    "<button onclick='openurlin_blank(\"washcrus.rb?dlkifu/#{@gameid}\")'>" \
    'Download KIF</button><BR>' \
    "<textarea id='kifulog' class='kifu' cols=40 readonly>#{@jkf.to_kif}</textarea>"
    # "<div id='kifulog' class='kifu'>#{@jkf.to_kif.gsub("\n", '<BR>')}</div>"
  end

  # 隠し部品
  #
  # @return 部品の文字列
  def hiddenelement
    ERB.new(File.read('./ui/gamehtml_hiddenparts.erb')).result
  end

  # class methods
end
