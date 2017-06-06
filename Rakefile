# rakefile
# encoding: utf-8

require 'rake/clean'

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
task init: [:gen_info, :add_w2d, :add_x2rb]

task gen_info: [:gen_userinfo, :gen_taikyokuinfo, :gen_taikyokuchuinfo]

task gen_userinfo: ['userinfo.csv']
task gen_taikyokuinfo: ['taikyoku.csv']
task gen_taikyokuchuinfo: ['taikyokuchu.csv']

file 'userinfo.csv' do |f|
  cp './init/userinfo.csv.tmpl', f.name
  chmod 0o666, f.name
end

file 'taikyoku.csv' do |f|
  cp './init/taikyoku.csv.tmpl', f.name
  chmod 0o666, f.name
end

file 'taikyokuchu.csv' do |f|
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
  chmod 0o755, 'washcrus.rb'
  chmod 0o755, 'checknewgame.rb'
  chmod 0o755, 'chat.rb'
end
