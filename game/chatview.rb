# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'unindent'

require './file/userchatfile.rb'
require './game/userinfo.rb'

#
# ChatViewの起動更新
#
class ChatView
  # 初期化
  def initialize; end

  def perform(userinfo)
    ucf = UserChatFile.new(userinfo.user_id)
    ucf.kidoku
  end
end
