#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'bundler/setup'

require 'cgi'

require './file/taikyokufile.rb'
require './file/chatfile.rb'
require './file/userchatfile.rb'

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
    @action = @params['action'][0]
  end

  # 発言をファイルに書き込む
  # パラメータが不正なときは何もしない
  def say
    @name = @params['chatname'][0]
    @msg = @params['chatmsg'][0]

    return if @name.empty? || @msg.empty?

    @msg.gsub!(',&<>',
               ',' => '&#44;', '&' => '&amp;',
               '<' => '&lt;', '>' => '&gt;')
    write
  end

  # 本体
  def perform
    # check game id
    tdb = TaikyokuFile.new
    tdb.read
    if tdb.exist?(@gameid) || @gameid == 'lounge'
      say if @action == 'say'

      # put chat log
      put
    else
      # invalid game id
      print "Content-type:text/html;\n\n# invalid game id #"
    end
  end

  # 発言を書き込む
  def write
    chatlog = ChatFile.new(@gameid)
    chatlog.read
    addedmsg = chatlog.say(@name, @msg)
    # 発言者、対局者x2のデータにも書く
    uchat = UserChatFile.new('bbf5fc78')#uid)
    uchat.read
    uchat.add(addedmsg, @gameid)
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
