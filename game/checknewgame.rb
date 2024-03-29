# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'

require 'cgi'
require 'digest/sha2'

require './file/userinfofile.rb'
require './game/taikyokudata.rb'
require './util/myhtml.rb'

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
    userdata && name == userdata[:name]
  end

  # 登録情報の確認
  def check
    return @errmsg += 'data lost ...' unless check_params(@params)

    read_params

    userdb = UserInfoFile.new
    userdb.read
    udb = userdb.content

    userdta = udb.findemail(@email1)
    @errmsg = "name or e-mail address in player 1 is wrong ...\n" \
        unless check_ply(userdta, @name1)

    userdtb = udb.findemail(@email2)
    @errmsg += "name or e-mail address in player 2 is wrong ...\n" \
        unless check_ply(userdtb, @name2)
  end

  # データの確認と応答
  def perform
    check

    return MyHtml.puts_textplain(@errmsg) unless @errmsg.empty?

    MyHtml.puts_textplain('new game check passed!')

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
