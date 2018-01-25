# -*- encoding: utf-8 -*-

require 'rubygems'

require 'cgi'
require 'digest/sha2'

require './game/userinfo.rb'
require './file/chatfile.rb'
require './file/taikyokureqfile.rb'
require './util/myhtml.rb'
#
# 対局作成確認
#
class File2Lounge
  # 初期化
  def initialize; end

  # パラメータの読み込み
  def read(params)
    @act = (params['action'] || [])[0]

    @cmt = params['f2lcmt']
    @cmt = "#{@cmt[0]} (#{Time.now})" if @cmt
  end

  # データの確認と応答(対局待ち登録)
  #
  # @param userinfo ユーザー情報
  def filing(userinfo)
    reqdb = TaikyokuReqFile.new

    if reqdb.fileauser(userinfo.user_id, userinfo.user_name, @cmt)
      chatlog = ChatFile.new('lounge')
      chatlog.sayex('System', "#{userinfo.user_name}さんが対局待ちになりました。")

      return MyHtml.puts_textplain('successflly filed.')
    end

    MyHtml.puts_textplain('already exists.')
  end

  # データの確認と応答(対局待ち解除)
  #
  # @param userinfo ユーザー情報
  def canceling(userinfo)
    reqdb = TaikyokuReqFile.new

    if reqdb.cancelauser(userinfo.user_id)
      chatlog = ChatFile.new('lounge')
      chatlog.sayex('System', "#{userinfo.user_name}さんが対局待ちを解除しました。")

      return MyHtml.puts_textplain('successflly canceled.') \
    end

    MyHtml.puts_textplain('you are not in the list.')
  end

  # データの確認と応答
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def perform(userinfo, params)
    return MyHtml.puts_textplain_pleaselogin if userinfo.invalid?

    read(params)

    case @act
    when 'file' then filing(userinfo)
    when 'cancel' then canceling(userinfo)
    else MyHtml.puts_textplain('invalid action...')
    end
  end
end
