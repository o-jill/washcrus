# -*- encoding: utf-8 -*-

# require 'rubygems'
require 'logger'
# require 'redcarpet'
require 'unindent'

require './file/pathlist.rb'
require './file/taikyokufile.rb'
require './game/taikyokudata.rb'
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
    @log = Logger.new(PathList::GAMELOG)
    @header = header
    @errmsg = "AdminGameManageUpdateScreen\n"
    @log.debug @errmsg
  end

  def extractparams(params)
    @gameid = params['gameid'][0] if params['gameid']
    @result = params['result'][0] if params['result']

    msg = "gameid:#{@gameid}, result:#{@result}\n"
    @log.debug msg
    @errmsg += msg
  end

  def removefromlist(gid, res)
    tcdb = TaikyokuChuFile.new
    tcdb.read
    # 存在しないはずのIDだよ
    unless tcdb.exist_id(gid)
      msg = "#{gid} does not exist...\n"
      @log.debug msg
      return @errmsg += msg
    end
    # 対局中から外す
    tcdb.finished(gid)
    @errmsg += "tcdb.finished(#{gid})\n"

    @tkd = TaikyokuData.new
    @tkd.log = @log
    @tkd.setid(gid)
    @tkd.read
    # 対局終了フラグをつける or 引き分けにする。
    @tkd.forcefinished(Time.now, res)
    @errmsg += "@tkd.forcefinished(Time.now, #{res})\n"

    # %CHUDANとかを棋譜に追加
    # とりあえず中断一択にします。
    @jmv = JsonMove.fromtext('%CHUDAN')
    # ret = @tkd.move(@sfen, @jmv, now)
    # @log.debug("@tkd.move() = #{ret}")
    @tkd.finish_special(@jmv)
    @tkd.write

    msg = "DONE.\n"
    @log.debug msg
    @errmsg += msg
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    extractparams(params)

    removefromlist(@gameid, @result)

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    puts "<pre>#{@errmsg}</pre>"

    CommonUI.html_foot
  end
end
