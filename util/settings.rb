# -*- encoding: utf-8 -*-

require 'singleton'
require 'yaml'

require './file/pathlist.rb'

# グローバル設定
# ./config/settings.yamlを読み込んで使います。
class Settings
  include Singleton
  # 初期化
  def initialize
    read
  end

  attr_accessor :value
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
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in yaml write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in yaml write"
  end
end
