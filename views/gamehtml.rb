# -*- encoding: utf-8 -*-

require 'rubygems'
require 'erb'
require 'unindent'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './game/webapi_sfenreader.rb'
require './game/userinfo.rb'

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
      <body><center>洗足池</center><HR>
      <div class=gamearea>
       <div class=block>
        <div class='block_elem_ban' id='block_elem_ban'> #{banelement} </div>
        <div class='block_elem_kifu'> #{kifuelement} </div>
       </div>
       #{chatelement}
      </div>
      <HR><div style='text-align:right;'>ぢるっち(c)2017</div>
      <div class='fogscreen' id='fogscreen'>
       <section class='msg_fogscreen' id='msg_fogscreen'>
        <BIG>sending data to server..</BIG><img src='image/komanim.gif'>
       </section>
      </div>
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
    "<button onclick='openurlin_blank(\"dlkifu.rb?#{@gameid}\")'>" \
    'Download KIF</button><BR>' \
    "<textarea id='kifulog' class='kifu' readonly>#{@jkf.to_kif}</textarea>"
    # "<div id='kifulog' class='kifu'>#{@jkf.to_kif.gsub("\n", '<BR>')}</div>"
  end

  # class methods
end
