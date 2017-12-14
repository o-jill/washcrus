#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'cgi'

require './file/taikyokufile.rb'
require './file/chatfile.rb'

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
    if tdb.exist_id(@gameid)
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
    chatlog.say(@name, @msg)
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

cgi = CGI.new
chat = Chat.new(cgi)
chat.perform
