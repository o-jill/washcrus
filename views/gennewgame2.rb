# -*- encoding: utf-8 -*-
# frozen_string_literal: true

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
    @cmt = 'blank'
    @errmsg = ''

    @log = Logger.new(PathList::GENNEWGAMELOG)
  end

  # データの存在チェック
  #
  # @param params パラメータハッシュオブジェクト
  # @return データが１つでも欠けてたらfalse
  def check_datalost_gengame(params)
    params['rid'] && params['rid2'] && params['furigoma'] \
      && params['teai'] && params['cmt2']
  end

  # プレイヤー情報の取得
  #
  # @param id1 プレイヤー1のID
  # @param id2 プレイヤー2のID
  # @return { userdataa:, userdatab: }
  def check_players(id1, id2)
    userdb = UserInfoFile.new
    userdb.read
    udb = userdb.content

    userdataa = udb.findid(id1) # [name, pw, email]

    @errmsg += "player1's id is wrong ...<BR>\n" unless userdataa

    userdatab = udb.findid(id2) # [name, pw, email]

    @errmsg += "player2's id is wrong ...<BR>\n" unless userdatab

    { userdataa: userdataa, userdatab: userdatab }
  end

  # プレイヤー情報の確認
  #
  # @param params パラメータハッシュオブジェクト
  # @return { userdataa:, userdatab: }
  def check_newgame(params)
    return @errmsg += 'data lost ...<BR>' unless check_datalost_gengame(params)

    id1 = params['rid'][0]
    id2 = params['rid2'][0]
    @cmt = params['cmt2'][0] unless params['cmt2'][0].empty?

    check_players(id1, id2)
  end
end
