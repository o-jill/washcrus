# rakefile
# encoding: utf-8

require 'rake/clean'

desc "greeting task"
task :hello do
  puts 'hello rake!'
end

desc "globally greeting task"
task :helloworld => [:hello] do
  puts 'hello world!'
end

desc "cleaning session files"
task :session_clean => [:gen_session_clean, :clean]

# sub task for session_clean
task :gen_session_clean do
  files_to_delete = FileList['./tmp/*']
  files_to_delete.exclude('./tmp/delete.me')

  CLEAN = files_to_delete
end

desc "init task"
task :init => [:gen_userinfo, :gen_taikyokuinfo, :gen_taikyokuchuinfo, :add_w2tmp]

task :gen_userinfo => ['userinfo.csv']
task :gen_taikyokuinfo => ['taikyoku.csv']
task :gen_taikyokuchuinfo => ['taikyokuchu.csv']

file 'userinfo.csv' do |f|
  cp './init/userinfo.csv.tmpl', f.name
  chmod 'uo+w', f.name
end

file 'taikyoku.csv' do |f|
  cp './init/taikyoku.csv.tmpl', f.name
  chmod 'uo+w', f.name
end

file 'taikyokuchu.csv' do |f|
  cp './init/taikyoku.csv.tmpl', f.name
  chmod 'uo+w', f.name
end

task :add_w2tmp do
  chmod 'o+w', './tmp'
end
