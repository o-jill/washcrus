# -*- encoding: utf-8 -*-

require 'cgi'

require './file/taikyokufile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'

#
# 棋譜のダウンロード
#
class DownloadKifu
  def initialize(gid, userinfo)
    @gameid = gid
    @userinfo = userinfo
  end

  # class methods

  #
  # 実行本体。
  #
  def perform
    # gameid が無いよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access." \
        unless @gameid

    # userinfoが変だよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nplease log in." \
        unless @userinfo.exist_indb

    tdb = TaikyokuFile.new
    tdb.read
    # 存在しないはずのIDだよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access." \
        unless tdb.exist_id(@gameid)

    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    # 表示する
    # tkd.download_kifu_file('csa')
    tkd.download_kifu_file('kif')
  end

  # class methods
end
