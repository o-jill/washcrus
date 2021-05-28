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
    @log.debug errmsg
  end

  # @!attribute [r] errmsg
  #   @return エラーメッセージ
  # @!attribute [r] gid
  #   @return 対局ID
  # @!attribute [r] jmv
  #   @return JsonMoveオブジェクト
  # @!attribute [r] result
  #   @return fb:先手勝ち, fw:後手勝ち, d:引き分け
  # @!attribute [r] tkd
  #   @return 対局情報
  attr_reader :errmsg, :gid, :jmv, :result, :tkd

  # パラメータの認識
  #
  # @param params パラメータ
  def extractparams(params)
    @gid = params['gameid'][0] if params['gameid']
    @result = params['result'][0] if params['result']

    msg = "gameid:#{gid}, result:#{result}\n"
    @log.debug msg
    @errmsg += msg
  end

  # 対局データの読み込み
  #
  # @param gid 対局ID
  def preparetkd(gid)
    @tkd = TaikyokuData.new
    tkd.log = @log
    tkd.setid(gid)
    tkd.read
  end

  # ロギング
  #
  # @param msg メッセージ
  def logg(msg)
    @log.debug msg
    @errmsg += msg
  end

  # 対局中のリストから外す
  def removefromtaikyokuchu
    tcdb = TaikyokuChuFile.new
    tcdb.read
    # 存在しないはずのIDだよ
    return logg("#{gid} does not exist...\n") unless tcdb.exist_id(gid)

    # 対局中から外す
    tcdb.finished(gid)
    logg("tcdb.finished(#{gid})\n")
    true
  end

  # 対局の状態を更新する(終わらせる)
  def updatetaikyoku
    preparetkd(gid)
    # 対局終了フラグをつける or 引き分けにする。
    tkd.forcefinished(Time.now, result)
    logg("@tkd.forcefinished(Time.now, #{res})\n")

    # %CHUDANとかを棋譜に追加
    # とりあえず中断一択にします。
    @jmv = JsonMove.fromtext('%CHUDAN')
    # ret = @tkd.move(@sfen, @jmv, now)
    # @log.debug("@tkd.move() = #{ret}")
    tkd.finish_special(jmv)
    tkd.write
  end

  # 対局DBを更新する
  def updatetaikyokudb
    return unless removefromtaikyokuchu

    tdb = TaikyokuFile.new
    tdb.read
    return logg("#{gid} does not exist...\n") unless tdb.exist_id(gid)
    tdb.updateturn(gid, result)

    updatetaikyoku

    logg("DONE.\n")
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    extractparams(params)

    updatetaikyokudb

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    puts "<pre>#{errmsg}</pre>"

    CommonUI.html_foot
  end
end
