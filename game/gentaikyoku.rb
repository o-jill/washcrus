# -*- encoding: utf-8 -*-

require 'fileutils'

# 対局情報ファイル生成クラス
class GenTaikyokuData
  def initialize(taikyoku = nil)
    @taikyoku = taikyoku
    @id = taikyoku.gid
  end

  attr_reader :taikyoku, :id

  # 対局に必要なファイル群の生成
  def generate
    FileUtils.mkdir(taikyoku.taikyokupath, mode: 0o777)

    File.open(taikyoku.matchinfopath, 'w', 0o666).close
    # matchfile = taikyoku.matchinfopath
    # FileUtils.touch(matchfile)
    # FileUtils.chmod(0o666, matchfile)

    File.open(taikyoku.chatpath, 'w', 0o666).close
    # chatfile = taikyoku.chatpath
    # FileUtils.touch(chatfile)
    # FileUtils.chmod(0o666, chatfile)

    File.open(taikyoku.kifupath, 'w', 0o666).close
    # kifufile = taikyoku.kifupath
    # FileUtils.touch(kifufile)
    # FileUtils.chmod(0o666, kifufile)

    File.open(taikyoku.sfenpath, 'w', 0o666).close
    # sfenfile = taikyoku.sfenpath
    # sfenUtils.touch(sfenfile)
    # sfenUtils.chmod(0o666, sfenfile)

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
