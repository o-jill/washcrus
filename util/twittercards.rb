# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'logger'

require './file/matchinfofile.rb'
require './game/taikyokudata.rb'
require './game/webapi_sfenreader.rb'
require './util/settings.rb'

# generate meta tags for Twitter Card
class TwitterCards
  # init
  def initialize
    stg = Settings.instance
    @baseurl = stg.value['base_url']
    @wintitle = stg.value['wintitle']
    @desc = stg.value['description']

    @cardtype = 'summary' # or 'summary_large_image'
  end

  # 局面画像生成サイトへのリンクの生成
  #
  # @return 局面画像へのリンク
  def kyokumen_link
    sr = WebApiSfenReader.new
    sr.setplayers(@mif.playerb.name, @mif.playerw.name)
    sr.sfen = @mif.sfen
    sr.setlastmovecsa(@mif.lastmove)
    sr.setturn(@mif.turnex)

    @baseurl + sr.genuri
  end

  def generate(gid)
    # puts "generate(gid:#{gid})"
    tkd = TaikyokuData.new
    tkd.log = Logger.new(STDERR)
    tkd.setid(gid)
    tkd.lockex do
      tkd.read
    end

    @mif = tkd.mif
    @title = "#{@mif.to_vs} @ #{@wintitle}"

    ret = <<-EOM.unindent
      <meta property="og:title" content="#{@title}" />
      <meta property="og:site_name" content="#{@wintitle}" />
      <meta property="og:description" content="#{@desc}" />
      <meta property="og:type" content="website" />
      <meta property="og:url" content="#{@baseurl}index.rb?game/#{gid}" />
      <meta property="og:image" content="#{kyokumen_link}" />
      <meta property="twitter:card" content="#{@cardtype}" />
    EOM
    ret
  end
end
