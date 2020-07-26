#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

# 初期配置は変なやつ(角厨とか)以外はいらない。
# 同のときはtoを追加。
# 打つときは"from":nullを追加。

require 'bundler/setup'

require 'jkf'

return puts "usage\nbundle exec kif2jkf.rb <kif>" if ARGV.empty?

puts ARGV.to_s

inp = ''
File.open(ARGV[0], 'r:cp932:utf-8') do |f|
  # File.open(ARGV[0], 'r', encoding:'cp932') do |f|
  inp = f.read
end

puts 'convert...'
kif_parser = Jkf::Parser::Kif.new
jkf = kif_parser.parse(inp)

puts jkf.to_s
