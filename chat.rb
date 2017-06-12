#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

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
  def initialize(cgi)
    @params = cgi.params
    @name = 'john doe'
    @msg = 'abdakadabra.'
    @gameid = cgi.query_string
    @action = @params['action']
  end

  # 本体
  def perform
    # check game id
    tdb = TaikyokuFile.new
    tdb.read
    if tdb.exist_id(@gameid)
      if @action == 'say'
        @name = params['chatname']
        @msg = params['chatmsg']
        unless @msg.length.zero?
          @msg.gsub!(',', '&#44;')
          @msg.gsub!('&', '&amp;')
          @msg.gsub!('<', '&lt;')
          @msg.gsub!('>', '&gt;')

          write
        end
      end
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
