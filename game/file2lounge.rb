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
  # 初期化
  def initialize
  end

  # パラメータの確認
  #
  # @param params パラメータハッシュオブジェクト
  # @return 値が入っていればfalse
  def check(params)
    params['action'].nil? || params['f2lcmt'].nil?
  end

  # パラメータの読み込み
  def read(params)
    @act = params['action'][0]
    @cmt = "#{params['f2lcmt'][0]} (#{Time.now})"
  end

  # データの確認と応答(対局待ち登録)
  #
  # @param userinfo ユーザー情報
  def filing(userinfo)
    reqdb = TaikyokuReqFile.new
    reqdb.read

    return puts "Content-type: text/plain;\n\nalready exists." \
      if reqdb.exist_id(userinfo.user_id)

    reqdb = TaikyokuReqFile.new
    reqdb.read
    reqdb.add(userinfo.user_id, userinfo.user_name, @cmt)
    reqdb.append(userinfo.user_id)

    puts "Content-type: text/plain;\n\nsuccessflly filed."
  end

  # データの確認と応答(対局待ち解除)
  #
  # @param userinfo ユーザー情報
  def canceling(userinfo)
    reqdb = TaikyokuReqFile.new
    reqdb.read

    return puts "Content-type: text/plain;\n\nyou are not in the list." \
      unless reqdb.exist_id(userinfo.user_id)

    reqdb.remove(userinfo.user_id)
    reqdb.write

    puts "Content-type: text/plain;\n\nsuccessflly canceled."
  end

  # データの確認と応答(不正)
  def invalid
    puts "Content-type: text/plain;\n\ninvalid action..."
  end

  # データの確認と応答
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def perform(userinfo, params)
    return puts "Content-type: text/plain;\n\ndata lost ..." \
      if userinfo.invalid? || check(params)

    read(params)

    case @act
    when 'file' then filing(userinfo)
    when 'cancel' then canceling(userinfo)
    else invalid
    end
  end
end
