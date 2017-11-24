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

  def check_datalost_gengame(params)
    params['rid'].nil? || params['rid2'].nil? || params['furigoma'].nil? \
      || params['teai'].nil?
  end

  def check_players(id1, id2)
    userdb = UserInfoFile.new
    userdb.read

    userdata1 = userdb.findid(id1) # [name, pw, email]
    if userdata1.nil?
      @errmsg += "player1's id is wrong ...<BR>\n"
    else
      userdata1.unshift(id1) # [id, name, pw, email]
    end

    userdata2 = userdb.findid(id2) # [name, pw, email]
    if userdata2.nil?
      @errmsg += "player2's id is wrong ...<BR>\n"
    else
      userdata2.unshift(id2) # [id, name, pw, email]
    end

    { userdata1: userdata1, userdata2: userdata2 }
  end

  def check_newgame(params)
    return @errmsg += 'data lost ...<BR>' if check_datalost_gengame(params)

    id1 = params['rid'][0]
    id2 = params['rid2'][0]

    check_players(id1, id2)
  end

  def config_taikyoku(userdata1, userdata2, userinfo, furigomastr)
    # @log.debug('td.setplayer1')
    @td.setplayer1(userdata1[0], userdata1[1], userdata1[3])

    # @log.debug('td.setplayer2')
    @td.setplayer2(userdata2[0], userdata2[1], userdata2[3])

    # @log.debug("furifusen(#{params['furigoma'][0].count('F')})")
    @td.switchplayers unless furifusen(furigomastr)

    # @log.debug('td.creator')
    @td.creator = "#{userinfo.user_name}(#{userinfo.user_id})"

    # @log.debug('td.generate')
    @td.generate
  end

  def generate(userinfo, params)
    ret = check_newgame(params)

    # @log.debug('check_newgame(params)')
    @errmsg += "your log-in information is wrong ...\n" \
        if userinfo.nil? || userinfo.invalid?

    return false unless @errmsg.length.zero?

    # @log.debug('put_err_sreen')

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
