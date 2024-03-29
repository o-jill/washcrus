# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'erb'
require 'unindent'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './game/webapi_sfenreader.rb'
require './game/userinfo.rb'
require './util/settings.rb'
require './views/common_ui.rb'

# 表示する
class GameHtml
  # 初期化
  #
  # @param gid Game ID
  # @param mif  MatchInfoFile
  # @param kif JsonKifu
  # @param ui  UserInfo
  def initialize(gid, mif, kif, ui)
    @gameid = gid
    @mif = mif
    @jkf = kif
    @userinfo = ui
    @log = nil
  end

  # @!attribute [rw] log
  #   @return logging
  attr_accessor :log

  # @!attribute [r] bname
  #   @return 先手の対局者名
  # @!attribute [r] wname
  #   @return 後手の対局者名
  attr_reader :bname, :wname

  # 画面の表示
  #
  # @param header htmlヘッダ
  def put(header)
    @log.debug('print header')
    print header
    puts "<!DOCTYPE html>\n<html>#{headerelement}<body>"

    CommonUI.html_menu(@userinfo)

    print <<-HEAD_GAMEAREA.unindent
      <div class=gamearea>
       <div id='notify_area' class='notify'>
        <BR>指されました。ページを再読込してください。
        <input type='image' style='vertical-align:middle;' id='btn_reload' src='./image/reloadbtn.png' onclick='location.reload(true);' alt='再読込' title='再読込'/>
        <BR><BR>
       </div>
    HEAD_GAMEAREA
    puts <<-CONTENT_GAMEAREA.unindent
       <div class=block>
        <section class='block_elem_ban' id='block_elem_ban'> #{banelement} </section>
        <section class='block_elem_kifu'> #{kifuelement} </section>
       </div>
       #{chatelement}
      </div>
      <HR><footer><div align='right'>&copy;ぢるっち 2017-2021 with Ruby v#{RUBY_VERSION}</div></footer>
    CONTENT_GAMEAREA
    puts "#{hiddenelement}</body></html>"
  end

  # 最終着手時間と経過時間用のタグの生成
  def prepare_time
    ltlm = " (<span id='lmtm'>#{@mif.dt_lastmove}</span>)"

    @bname += ' <span id="sentetime"></span>' if @mif.turn == 'b'
    @wname += ltlm if @mif.turn == 'b'

    @bname += ltlm if @mif.turn == 'w'
    @wname += ' <span id="gotetime"></span>' if @mif.turn == 'w'
  end

  # 将棋盤の部品
  #
  # @return 部品の文字列
  def shogibanelement
    @log.debug('shogibanelement')

    @wname = @mif.playerw.name
    @bname = @mif.playerb.name

    prepare_time

    erbtxt = File.read('./ui/gamehtml_shogiban.erb', encoding: 'utf-8')
    ERB.new(erbtxt).result(binding)
  end

  # 局面画像生成サイトへのリンクの生成
  #
  # @return 局面画像へのリンク
  def kyokumen_link
    sr = WebApiSfenReader.new
    sr.setmatchinfo(@mif)
    ret = "<a href='#{sr.genuri}' target='_blank'>局面図画像svg</a>"
    sr.setimage('.png')
    ret + "&nbsp;<a href='#{sr.genuri}' target='_blank'>局面図画像png</a>"
  end

  # 将棋盤まわりの部品
  #
  # @return 部品の文字列
  def banelement
    @log.debug('banelement')
    ret = shogibanelement

    erbtxt = File.read('./ui/gamehtml_123neye.erb', encoding: 'utf-8')
    ret += ERB.new(erbtxt).result(binding)

    ret
  end

  # 画面上部の部品
  #
  # @return 部品の文字列
  def headerelement
    @log.debug('headerelement')
    stg = Settings.instance
    title = "#{stg.value['wintitle']} #{@mif.to_vs}"
    erbtxt = File.read('./ui/gamehtml_header.erb', encoding: 'utf-8')
    ERB.new(erbtxt).result(binding)
  end

  # チャットまわりの部品
  #
  # @return 部品の文字列
  def chatelement
    @log.debug('chatelement')
    erbtxt = File.read('./ui/gamehtml_chat.erb', encoding: 'utf-8')
    ERB.new(erbtxt).result(binding)
  end

  def tweetbtn
    stg = Settings.instance
    return '' if stg.value['tweetbtn'] != 'show'

    '<a href="https://twitter.com/share?ref_src=twsrc%5Etfw" ' \
    'class="twitter-share-button" data-show-count="false">Tweet</a>' \
    '<script async src="https://platform.twitter.com/widgets.js"' \
    ' charset="utf-8"></script>'
  end

  # 棋譜まわりの部品
  #
  # @return 部品の文字列
  def kifuelement
    @log.debug('kifuelement')
    "<textarea id='kifulog' class='kifu' cols=40 readonly>" \
    "#{@jkf.to_kifu}</textarea>" \
    "<button onclick='dl_kifu_file();'>Download KIF</button>&nbsp;" \
    "<button onclick='open_kifu_player();'>棋譜再生</button><br>#{tweetbtn}" \
    "&nbsp;#{kyokumen_link}"
    # "<div id='kifulog' class='kifu'>#{@jkf.to_kifu.gsub("\n", '<BR>')}</div>"
  end

  # 隠し部品
  #
  # @return 部品の文字列
  def hiddenelement
    erbtxt = File.read('./ui/gamehtml_hiddenparts.erb', encoding: 'utf-8')
    ERB.new(erbtxt).result
  end

  # class methods
end
