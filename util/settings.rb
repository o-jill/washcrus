# -*- encoding: utf-8 -*-

require 'singleton'
require 'yaml'

# グローバル設定
# ./config/settings.yamlを読み込んで使います。
class Settings
  include Singleton
  # 初期化
  #
  # @param path 読み込むファイルのパス
  def initialize(path = './config/settings.yaml')
    read(path)
  end

  attr_accessor :value

  # yamlファイルの読み込み
  #
  # @param path 読み込むファイルのパス
  def read(path)
    @value = YAML.load_file(path)
  end

  # yamlファイルに書き出し
  #
  # @param path 読み込むファイルのパス
  def write(path)
    File.open(path, 'wb') do |file|
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
