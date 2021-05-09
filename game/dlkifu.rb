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
  # 初期化
  #
  # @param gid 対局ID
  # @param userinfo ユーザー情報
  def initialize(gid, userinfo)
    @gameid = gid
    @userinfo = userinfo
  end

  # class methods

  # 棋譜のダウンロード
  def checkparam
    # gameid が無いよ
    return MyHtml.puts_textplain_illegalaccess unless @gameid

    # userinfoが変だよ
    return MyHtml.puts_textplain_pleaselogin unless @userinfo.exist_indb

    tdb = TaikyokuFile.new
    tdb.read
    # 存在しないはずのIDだよ
    return MyHtml.puts_textplain_illegalaccess unless tdb.exist_id(@gameid)

    self
  end

  #
  # 実行本体。
  #
  def perform
    return unless checkparam

    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    # 表示する
    # tkd.download_kifu_file('csa')
    tkd.download_kifu_file('kif')
  end

  # class methods
end
