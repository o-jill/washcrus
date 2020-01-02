# -*- encoding: utf-8 -*-

# require 'rubygems'
require 'unindent'
# require 'redcarpet'

require './file/pathlist.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './views/common_ui.rb'

#
# 対局編集画面
#
class AdminGameManageUpdateScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
    @errmsg = ''
  end

  def removefromlist()
    tcdb = TaikyokuChuFile.new
    tcdb.read
    # 存在しないはずのIDだよ
    return errmsg = "#{@gameid} does not exist..." unless tcdb.exist_id(@gameid)
    # 対局中から外す
    tcdb.finished(@gameid)

    # 対局終了フラグをつける or 引き分けにする。
    # gote_win = (@tkd.mif.teban == 'b')
    @tkd.forcefinished(Time.now, @result)

    # %CHUDANとかを棋譜に追加
    @jmv = JsonMove.fromtext('%CHUDAN')

  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    @gameid = params['gameid'][0]
    @result = params['result'][0]
    removefromlist()

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    puts errmsg

    CommonUI.html_foot
  end
end
