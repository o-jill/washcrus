# rakefile
# encoding: utf-8

require 'rake/clean'
require 'securerandom'

desc 'token generation task'
task gen_token: ['secret_token.rb']

file 'secret_token.rb' do |fn|
  open(fn.name, 'w:utf-8') do |f|
    keydata = SecureRandom.hex(20)
    suf = SecureRandom.hex(2)
    f.puts <<"SECRET_TOKEN"
# coding: utf-8
module Globals
  KEY = '#{keydata}'.freeze
  USERINFO = './db/userinfo#{suf}.csv'.freeze
  TAIKYOKU = './db/taikyoku#{suf}.csv'.freeze
  TAIKYOKUCHU = './db/taikyoku#{suf}.csv'.freeze
end
SECRET_TOKEN
  end
end

desc 'greeting task'
task :hello do
  puts 'hello rake!'
end

desc 'globally greeting task'
task helloworld: [:hello] do
  puts 'hello world!'
end

desc 'cleaning session files'
task session_clean: [:gen_session_clean, :clean]

# sub task for session_clean
task :gen_session_clean do
  files_to_delete = FileList['./tmp/*']
  files_to_delete.exclude('./tmp/delete.me')

  CLEAN = files_to_delete
end

desc 'init task'
task init: [:check_mailcfg, :gen_info, :add_w2d, :add_x2rb]

task gen_info: [:gen_userinfo, :gen_taikyokuinfo, :gen_taikyokuchuinfo]

task gen_userinfo: ['./db/userinfo.csv']
task gen_taikyokuinfo: ['./db/taikyoku.csv']
task gen_taikyokuchuinfo: ['./db/taikyokuchu.csv']

file './db/userinfo.csv' do |f|
  cp './init/userinfo.csv.tmpl', f.name
  chmod 0o666, f.name
end

file './db/taikyoku.csv' do |f|
  cp './init/taikyoku.csv.tmpl', f.name
  chmod 0o666, f.name
end

file './db/taikyokuchu.csv' do |f|
  cp './init/taikyoku.csv.tmpl', f.name
  chmod 0o666, f.name
end

task add_w2d: [:add_w2tmp, :add_w2taikyoku, :add_w2d_msg]

task :add_w2tmp do
  chmod 0o777, './tmp'
end

task :add_w2taikyoku do
  chmod 0o777, './taikyoku'
end

task :add_w2d_msg do
  puts 'please arrange permissions ',
       'according to your server\'s rule before you start this service.'
end

task :add_x2rb do
  chmod 0o755, 'chat.rb'
  chmod 0o755, 'checknewgame.rb'
  chmod 0o755, 'dlkifu.rb'
  chmod 0o755, 'game.rb'
  chmod 0o755, 'getsfen.rb'
  chmod 0o755, 'move.rb'
  chmod 0o755, 'washcrus.rb'
end

task check_mailcfg: [:check_mailcfg_yaml, :check_mailcfg_sign, :check_settings_yaml]

task check_mailcfg_yaml: ['./config/mail.yaml']

file './config/mail.yaml' do
  puts "ERROR: './config/mail.yaml' is missing..."
  exit 101
end

task check_mailcfg_sign: ['./config/signature.txt']

file './config/signature.txt' do
  puts "ERROR: './config/signature.txt' is missing..."
  exit 102
end

task check_settings_yaml: ['./config/settings.yaml']

file './config/settings.yaml' do
  puts "ERROR: './config/settings.yaml' is missing..."
  exit 103
end

desc 'testing and checking code style'
task test: [:do_rubocop, :do_rspec]

task :do_rspec do
  sh 'rspec' rescue nil
end

task :do_rubocop do
  sh 'rubocop' rescue nil
end
