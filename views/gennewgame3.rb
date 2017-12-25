# -*- encoding: utf-8 -*-

require 'logger'
require 'unindent'

# require './file/chatfile.rb'
# require './file/jsonkifu.rb'
# require './file/matchinfofile.rb'
# require './file/pathlist.rb'
require './file/taikyokureqfile.rb'
# require './file/userinfofile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'
# require './util/mailmgr.rb'
# require './util/settings.rb'
require './views/common_ui.rb'
require './views/gennewgame.rb'
require './views/gennewgame2.rb'

#
# 対局作成確認
#
class GenNewGame3Screen < GenNewGame2Screen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    super
  end

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
  # @return { userdata1:, userdata2: }
  def check_newgame(userinfo, params)
    return @errmsg += 'data lost ...<BR>' unless check_datalost_gengame(params)

    @id1 = userinfo.user_id
    @id2 = params['opponent'][0]
    @log.debug("id1:#{@id1} id2:#{@id2}")

    check_players(@id1, @id2)
  end

  # 対局リクエスト情報の確認とリストからの破棄
  def checkrequest
    reqdb = TaikyokuReqFile.new
    reqdb.lock do
      reqdb.read

      unless reqdb.exist_id(@id2)
        return @errmsg += 'you chose a wrong user or ' \
          "the user already started another game.\n"
      end

      reqdb.remove(@id1)
      reqdb.remove(@id2)
      reqdb.write
    end
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
    @td.log = @log

    config_taikyoku(ret[:userdata1], ret[:userdata2], userinfo,
                    params['furigoma'][0])

    # send mail to the players
    send_mail

    true
  end
end
