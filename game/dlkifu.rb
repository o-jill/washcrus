# -*- encoding: utf-8 -*-

require 'cgi'

require './file/taikyokufile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'

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
    return MyHtml.puts_textplain_illegalaccess unless @gameid

    # userinfoが変だよ
    return MyHtml.puts_textplain_pleaselogin unless @userinfo.exist_indb

    tdb = TaikyokuFile.new
    tdb.read
    # 存在しないはずのIDだよ
    return MyHtml.puts_textplain_illegalaccess unless tdb.exist_id(@gameid)

    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    # 表示する
    # tkd.download_kifu_file('csa')
    tkd.download_kifu_file('kif')
  end

  # class methods
end
