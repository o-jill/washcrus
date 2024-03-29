# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'logger'
require 'unindent'

require './file/taikyokureqfile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'
require './views/common_ui.rb'
require './views/gennewgame.rb'
require './views/gennewgame2.rb'

#
# loungeから対局作成確認
#
class GenNewGame3Screen < GenNewGame2Screen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    super
  end

  # @!attribute [r] id1
  #   @return 対局者ID1
  # @!attribute [r] id2
  #   @return 対局者ID2
  attr_reader :id1, :id2

  # データの存在チェック
  #
  # @param params パラメータハッシュオブジェクト
  # @return データが１つでも欠けてたらfalse
  def check_datalost_gengame(params)
    params['opponent'] && params['sengo'] && params['furigoma']
  end

  # プレイヤー情報の確認
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  # @return { userdataa:, userdatab: }
  def check_newgame(userinfo, params)
    return @errmsg += 'data lost ...<BR>' unless check_datalost_gengame(params)

    @id1 = userinfo.user_id
    @id2 = params['opponent'][0]
    @log.debug("id1:#{id1} id2:#{id2}")

    check_players(id1, id2)
  end

  # 対局リクエスト情報の確認とリストからの破棄
  def checkrequest
    reqdb = TaikyokuReqFile.new

    return if reqdb.bonvoyage(id1, id2)

    @errmsg += 'you chose a wrong user or ' \
        "the user already started another game.\n"
  end

  # 対局生成
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  # @return 生成できたらtrue
  def generate(userinfo, params)
    ret = check_newgame(userinfo, params)

    # @log.debug('check_newgame(params)')
    @errmsg += "your log-in information is wrong ...\n" if userinfo.invalid?

    checkrequest

    return false unless @errmsg.empty?

    # @log.debug('TaikyokuData.new')
    @td = TaikyokuData.new
    @td.log = log

    config_taikyoku(ret[:userdataa], ret[:userdatab], userinfo,
                    params['furigoma'][0])

    # send mail to the players
    send_mail

    true
  end
end
