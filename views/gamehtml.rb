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
  def initialize(gid, mi, kif, ui)
    @gameid = gid
    @mi = mi
    @jkf = kif
    @userinfo = ui
    @log = nil
  end

  attr_accessor :log

  def put(header)
    @log.debug('print header')
    print header
    print <<-HTMLELEMENTS.unindent
      <html>#{headerelement}
      <body>
      #{CommonUI::HTMLmenuLogIn('洗足池', true)}
      <div class=gamearea>
       <div id='notify_area' class='notify'>
        <BR>指されました。ページを再読込してください。
        <input type='image' style='vertical-align:middle;' id='btn_reload' src='./image/reloadbtn.png' onclick='location.reload(true);' alt='再読込' title='再読込'/>
        <BR><BR>
       </div>
       <div class=block>
        <div class='block_elem_ban' id='block_elem_ban'> #{banelement} </div>
        <div class='block_elem_kifu'> #{kifuelement} </div>
       </div>
       #{chatelement}
      </div>
      <HR><div style='text-align:right;'>ぢるっち(c)2017</div>
      #{hiddenelement}
      </body></html>
      HTMLELEMENTS
  end

  def shogibanelement
    @log.debug('shogibanelement')
    ERB.new(File.read('./ui/gamehtml_shogiban.erb')).result
  end

  def banelement
    @log.debug('banelement')
    ret = <<-BOARD_TEXT.unindent
      #{shogibanelement}
      <script type='text/javascript' src='./js/shogi.js'></script>
      <script type='text/javascript' src='./js/ui.js' async></script>
      BOARD_TEXT

    ret += ERB.new(File.read('./ui/gamehtml_123neye.erb')).result(binding)

    sr = WebApiSfenReader.new
    sr.setplayers(@mi.playerb, @mi.playerw)
    sr.sfen = @mi.sfen
    sr.setlastmovecsa(@mi.lastmove)
    ret += "<a href='#{sr.genuri}' target='_blank'>局面図画像</a>"

    ret
  end

  def headerelement
    @log.debug('headerelement')
    ERB.new(File.read('./ui/gamehtml_header.erb')).result(binding)
  end

  def chatelement
    @log.debug('chatelement')
    ERB.new(File.read('./ui/gamehtml_chat.erb')).result(binding)
  end

  def kifuelement
    @log.debug('kifuelement')
    "<button onclick='openurlin_blank(\"washcrus.rb?dlkifu/#{@gameid}\")'>" \
    'Download KIF</button><BR>' \
    "<textarea id='kifulog' class='kifu' readonly>#{@jkf.to_kif}</textarea>"
    # "<div id='kifulog' class='kifu'>#{@jkf.to_kif.gsub("\n", '<BR>')}</div>"
  end

  def hiddenelement
    ERB.new(File.read('./ui/gamehtml_hiddenparts.erb')).result
  end

  # class methods
end
