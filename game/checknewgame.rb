# -*- encoding: utf-8 -*-

require 'rubygems'

require 'cgi'
require 'digest/sha2'

require './file/userinfofile.rb'
require './game/taikyokudata.rb'

#
# 対局作成確認
#
class CheckNewGame
  # 初期化
  #
  # @param cgi CGIオブジェクト
  def initialize(cgi)
    @errmsg = ''
    @cgi = cgi
    @params = cgi.params

    @name1 = nil
    @email1 = nil
    @name2 = nil
    @email2 = nil
  end

  # パラメータの確認
  #
  # @param params パラメータハッシュオブジェクト
  # @return すべて値が入っていればtrue
  def check_params(params)
    params['rname'] && params['remail'] && params['rname2'] && params['remail2']
  end

  # パラメータの読み込み
  def read_params
    @name1 = @params['rname'][0]
    @email1 = @params['remail'][0]
    @name2 = @params['rname2'][0]
    @email2 = @params['remail2'][0]
  end

  # ユーザー名の確認。
  #
  # @param userdata メールアドレスに紐付けられたユーザ情報
  # @param userdata ユーザ名
  # @return ユーザ情報とユーザ名が同じ時true
  def check_ply(userdata, name)
    userdata && name == userdata[1]
  end

  # 登録情報の確認
  def check
    return @errmsg += 'data lost ...' unless check_params(@params)

    read_params

    userdb = UserInfoFile.new
    userdb.read

    userdata1 = userdb.findemail(@email1)  # [id, @names[id], @passwords[id]]
    @errmsg = "name or e-mail address in player 1 is wrong ...\n" \
        unless check_ply(userdata1, @name1)

    userdata2 = userdb.findemail(@email2)  # [id, @names[id], @passwords[id]]
    @errmsg += "name or e-mail address in player 2 is wrong ...\n" \
        unless check_ply(userdata2, @name2)
  end

  # データの確認と応答
  def perform
    check

    return puts "Content-type: text/plain;\n\n#{@errmsg}" unless @errmsg.empty?

    puts "Content-type: text/plain;\n\nnew game check passed!\n"

    # td = TaikyokuData.new
    # td.player1 = name1
    # td.email1 = email1
    # td.player2 = name2
    # td.email2 = email2
    # td.creator = username
    # td.checkgenerate
    # td.dump
  end
end
