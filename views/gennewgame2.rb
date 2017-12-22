# -*- encoding: utf-8 -*-

require 'logger'
require 'unindent'

require './file/chatfile.rb'
require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './file/pathlist.rb'
require './file/userinfofile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'
require './util/mailmgr.rb'
require './util/settings.rb'
require './views/common_ui.rb'
require './views/gennewgame.rb'

#
# 対局作成確認
#
class GenNewGame2Screen < GenNewGameScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
    @stg = Settings.instance

    @errmsg = ''

    @log = Logger.new(PathList::GENNEWGAMELOG)
  end

  # データの存在チェック
  #
  # @param params パラメータハッシュオブジェクト
  # @return データが１つでも欠けてたらfalse
  def check_datalost_gengame(params)
    params['rid'] && params['rid2'] && params['furigoma'] && params['teai']
  end

  # プレイヤー情報の取得
  #
  # @param id1 プレイヤー1のID
  # @param id2 プレイヤー2のID
  # @return { userdata1:, userdata2: }
  def check_players(id1, id2)
    userdb = UserInfoFile.new
    userdb.read

    userdata1 = userdb.findid(id1) # [name, pw, email]
    if userdata1
      userdata1.unshift(id1) # [id, name, pw, email]
    else
      @errmsg += "player1's id is wrong ...<BR>\n"
    end

    userdata2 = userdb.findid(id2) # [name, pw, email]
    if userdata2
      userdata2.unshift(id2) # [id, name, pw, email]
    else
      @errmsg += "player2's id is wrong ...<BR>\n"
    end

    { userdata1: userdata1, userdata2: userdata2 }
  end

  # プレイヤー情報の確認
  #
  # @param params パラメータハッシュオブジェクト
  # @return { userdata1:, userdata2: }
  def check_newgame(params)
    return @errmsg += 'data lost ...<BR>' unless check_datalost_gengame(params)

    id1 = params['rid'][0]
    id2 = params['rid2'][0]

    check_players(id1, id2)
  end
end
