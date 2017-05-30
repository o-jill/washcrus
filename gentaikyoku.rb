#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'fileutils'

# 対局情報ファイル生成クラス
class GenTaikyokuData
  def initialize(taikyoku = nil)
    @taikyoku = taikyoku
    @id = taikyoku.id
  end

  attr_accessor :taikyoku, :id

  # 対局に必要なファイル群の生成
  def generate
    directory = taikyoku.taikyokupath
    FileUtils.mkdir(directory, mode: 0o777)

    matchfile = taikyoku.matchinfopath
    FileUtils.touch(matchfile)
    FileUtils.chmod(0o666, matchfile)

    chatfile = taikyoku.chatpath
    FileUtils.touch(chatfile)
    FileUtils.chmod(0o666, chatfile)

    kifufile = taikyoku.csapath
    FileUtils.touch(kifufile)
    FileUtils.chmod(0o666, kifufile)

    # print <<-GEN_LOG
    # FileUtils.mkdir(#{directory}, { :mode => 0777 })
    #
    # matchfile = directory+MATCHFILE
    # FileUtils.touch(#{matchfile})
    # FileUtils.chmod(0666, #{matchfile})
    #
    # chatfile = directory+CHATFILE
    # FileUtils.touch(#{chatfile})
    # FileUtils.chmod(0666, #{chatfile})
    #
    # kifufile = directory+KIFUFILE
    # FileUtils.touch(#{kifufile})
    # FileUtils.chmod(0666, #{kifufile})
    # GEN_LOG
  end
end
