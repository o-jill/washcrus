# -*- encoding: utf-8 -*-

require 'rubygems'

require 'cgi'
require 'digest/sha2'

require './game/userinfo.rb'
require './file/taikyokureqfile.rb'

#
# 対局作成確認
#
class File2Lounge
  # ヘッダ情報
  TEXTPLAIN_HEAD = "Content-Type: text/plain; charset=UTF-8\n\n".freeze

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
    reqdb.read

    return puts TEXTPLAIN_HEAD + 'already exists.' \
      if reqdb.exist_id(userinfo.user_id)

    reqdb = TaikyokuReqFile.new
    reqdb.read
    reqdb.add(userinfo.user_id, userinfo.user_name, @cmt)
    reqdb.append(userinfo.user_id)

    puts TEXTPLAIN_HEAD + 'successflly filed.'
  end

  # データの確認と応答(対局待ち解除)
  #
  # @param userinfo ユーザー情報
  def canceling(userinfo)
    reqdb = TaikyokuReqFile.new
    reqdb.lock do
      reqdb.read

      return puts TEXTPLAIN_HEAD + 'you are not in the list.' \
        unless reqdb.exist_id(userinfo.user_id)

      reqdb.remove(userinfo.user_id)
      reqdb.write
    end

    puts TEXTPLAIN_HEAD + 'successflly canceled.'
  end

  # データの確認と応答(不正)
  def invalid
    puts TEXTPLAIN_HEAD + 'invalid action...'
  end

  # データの確認と応答
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def perform(userinfo, params)
    return puts TEXTPLAIN_HEAD + 'please log-in ...' if userinfo.invalid?

    read(params)

    case @act
    when 'file' then filing(userinfo)
    when 'cancel' then canceling(userinfo)
    else invalid
    end
  end
end
