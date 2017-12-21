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
task init: [:check_mailcfg, :gen_info, :give_permissions, :revision]

task gen_info: [:gen_news, :gen_settings, :gen_userinfo, :gen_taikyokuinfo,
                :gen_taikyokuchuinfo, :gen_taikyokureqinfo]

task gen_news: ['./config/news.txt']
task gen_settings: ['./config/settings.yaml']
task gen_userinfo: ['./db/userinfo.csv']
task gen_taikyokuinfo: ['./db/taikyoku.csv']
task gen_taikyokuchuinfo: ['./db/taikyokuchu.csv']
task gen_taikyokureqinfo: ['./db/taikyokureq.csv']

file './config/news.txt' do |f|
  cp './init/news.txt.tmpl', f.name
  chmod 0o666, f.name
end

file './config/settings.yaml' do |f|
  cp './config/settings.yaml.sample', f.name
  chmod 0o666, f.name
end

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

file './db/taikyokureq.csv' do |f|
  cp './init/taikyokureq.csv.tmpl', f.name
  chmod 0o666, f.name
end

task give_permissions: [:add_w2d, :add_x2rb, :add_w2lock, :add_w2stg]
task :add_w2d do
  chmod 0o777, './tmp'
  chmod 0o777, './taikyoku'
  chmod 0o777, './log'
  chmod 0o777, './backup'

  puts 'please arrange permissions ',
       'according to your server\'s rule before you start this service.'
end

task :add_x2rb do
  chmod 0o755, 'chat.rb'
  chmod 0o755, 'getsfen.rb'
  chmod 0o755, 'move.rb'
  chmod 0o755, 'washcrus.rb'
end

task :add_w2lock do
  chmod 0o666, './db/taikyokufile.lock'
  chmod 0o666, './db/taikyokuchufile.lock'
  chmod 0o666, './db/taikyokureqfile.lock'
  chmod 0o666, './db/userinfofile.lock'
end

task :add_w2stg do
  chmod 0o666, './config/settings.yaml'
  chmod 0o666, './config/signature.txt'
end

task check_mailcfg: [:check_mailcfg_yaml, :check_mailcfg_sign]

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

task check_adminconfig: ['./db/adminconfig.txt']

file './db/adminconfig.txt' do
  puts "ERROR: './db/adminconfig.txt' is missing..."
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

desc 'generate a user and give admin rights.'
task :add_admin do
  require './config/genadmin.rb'
  unless genadmin.nil?
    puts 'FAILED: adding an administrator.'
    exit 201
  end
end

desc 'byouyomi task'
task :byouyomi do
  require './observer/byouyomichan.rb'
  bc = ByouyomiChan.new
  bc.perform
end

desc 'make REVISION file from repository HEAD.'
task :revision do
  puts '`git log -1 >REVISION`'
  `git log -1 >REVISION`
end

desc 'make tarball to backup taikyoku/, config/ and db/.'
task :backup do
  fn = Time.now.strftime('%Y%m%d%H%M%S') + '_bak.tar.gz'
  puts "`tar cvfz ./backup/#{fn} taikyoku/ config/ db/`"
  `tar cvfz ./backup/#{fn} taikyoku/ config/ db/`
end
