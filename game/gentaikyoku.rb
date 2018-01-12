# -*- encoding: utf-8 -*-

require 'fileutils'

# 対局情報ファイル生成クラス
class GenTaikyokuData
  # 初期化
  #
  # @param taikyoku TaikyokuDataオブジェクト
  def initialize(taikyoku = nil)
    @taikyoku = taikyoku
    @id = taikyoku.gid
  end

  # attr_reader :taikyoku, :id

  # ファイルをモード666で作成
  #
  # @param path ファイルパス
  def self.touch(path)
    File.open(path, 'w').close
    File.chmod(0o666, path)
  end

  # 対局に必要なファイル群の生成
  def generate
    FileUtils.mkdir(@taikyoku.taikyokupath, mode: 0o777)
    [
      @taikyoku.matchinfopath, @taikyoku.chatpath, @taikyoku.kifupath,
      @taikyoku.sfenpath, @taikyoku.lockpath
    ].each do |path|
      GenTaikyokuData.touch(path)
    end
  end
end
