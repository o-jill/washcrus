# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'singleton'
require 'yaml'

require './file/pathlist.rb'

# グローバル設定
# ./config/settings.yamlを読み込んで使います。
# Singleton
class Settings
  include Singleton
  # 初期化
  def initialize
    read
  end

  # 設定内容
  attr_accessor :value

  # 設定ファイルのパス
  attr_reader :fpath

  # yamlファイルの読み込み
  def read
    @value = YAML.load_file(PathList::SETTINGSFILE)
  end

  # yamlファイルに書き出し
  def write
    File.open(PathList::SETTINGSFILE, 'wb') do |file|
      file.flock File::LOCK_EX
      file.puts @value.to_yaml
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in yaml write"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in yaml write"
  end
end
