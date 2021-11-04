#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'bundler/setup'

require 'cgi'
require 'cgi/session'

require './file/chatfile.rb'
require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './file/userchatfile.rb'
require './game/taikyokudata.rb'
require './game/userinfo.rb'

# チャットシステムクラス
#
# QUERY_STRING = Game ID
#
# read:
#  action != say
# write:
#  action = say
#  chatname = johndoe
#  chatmsg  = message
class Chat
  # 初期化
  #
  # @param cgi CGIオブジェクト
  def initialize(cgi)
    @params = cgi.params
    @name = 'john doe'
    @msg = 'abdakadabra.'
    @gameid = cgi.query_string
    @action = @params['action'] || ['']
    @action = @action[0]
    readuserparam(cgi)
  end

  # 発言をファイルに書き込む
  # パラメータが不正なときは何もしない
  #
  # @param ongame true:対局画面で発言, false:ラウンジで発言
  def say(ongame)
    @name = @userinfo.user_name
    @uid = @userinfo.user_id

    @msg = @params['chatmsg'] || ['']
    @msg = @msg[0]

    return if @name.empty? || @msg.empty?

    @msg.gsub!(',&<>',
               ',' => '&#44;', '&' => '&amp;',
               '<' => '&lt;', '>' => '&gt;')
    write(ongame)
  end

  # 本体
  def perform
    # check game id
    tdb = TaikyokuFile.new
    tdb.read
    exist = tdb.exist?(@gameid)
    if exist || @gameid == 'lounge'
      say(exist) if @action == 'say'

      # put chat log
      put
    else
      # invalid game id
      print "Content-type:text/html;\n\n# invalid game id #"
    end
  end

  # 発言者、対局者x2のデータにも書く
  #
  # @param addedmsg 発言
  def write2chatview(addedmsg)
    tkd = TaikyokuData.new
    tkd.log = @log
    tkd.setid(@gameid)
    tkd.lockex do
      tkd.read
    end
    tkd.mif.getplayerids.append(@uid).uniq.each do |userid|
      uchat = UserChatFile.new(userid)
      uchat.read
      uchat.add(addedmsg, @gameid)
    end
  end

  # 発言を書き込む
  #
  # @param ongame true:対局画面で発言, false:ラウンジで発言
  def write(ongame)
    chatlog = ChatFile.new(@gameid)
    chatlog.read
    addedmsg = chatlog.say(@name, @msg)

    write2chatview(addedmsg) if ongame
  end

  # sessionの取得と情報の読み取り
  #
  # @param cgi CGIオブジェクト
  def readuserparam(cgi)
    begin
      session = CGI::Session.new(
        cgi,
        'new_session' => false,
        'session_key' => '_washcrus_session',
        'tmpdir' => './tmp'
      )
    rescue ArgumentError # => ae
      session = nil
    end

    @userinfo = UserInfo.new
    @userinfo.readsession(session) if session
    session&.close
  end

  # 発言ログを表示する
  def put
    chatlog = ChatFile.new(@gameid)
    chatlog.read
    chatlog.put
  end
end

# -----------------------------------
#   main
#
begin
  cgi = CGI.new
  chat = Chat.new(cgi)
  chat.perform
rescue StandardError => e
  puts "content-type:text/plain\n\n"
  puts "some error happend!\n--\n#{e}"
  puts "#{e.backtrace.join("\n")}\n--"
end
