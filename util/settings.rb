# -*- encoding: utf-8 -*-

require 'yaml'

#
#
class Settings
  def initialize(path = './config/settings.yaml')
    read(path)
  end

  attr_accessor :value

  def read(path)
    @value = YAML.load_file(path)
  end

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
