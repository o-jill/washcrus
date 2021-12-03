# -*- encoding: utf-8 -*-
# frozen_string_literal: true

# 対局に付随するchat.txtからUserChatFileを生成する。

require 'bundler/setup'

require 'fileutils'

require './file/chatfile.rb'
require './file/pathlist.rb'
require './file/taikyokufile.rb'
require './game/taikyokudata.rb'

uclist = []

tkdb = TaikyokuFile.new
tkdb.read
tkdb.content.idbs.each_key do |gid|
  print "game: #{gid}... "
  tkd = TaikyokuData.new
  tkd.log = @log
  tkd.setid(gid)
  tkd.lockex do
    tkd.read
  end
  chat = ChatFile.new(gid)
  chat.read
  msg = chat.msg.lines.map { |line| "#{gid},#{line}" }
  msg = msg.join
  tkd.mif.getplayerids.each do |userid|
    path = PathList::USERCHATDIR + userid + '.txt'
    File.open(path, 'a:utf-8') do |file|
      file.write(msg)
      file.flush
    end
    uclist << path
  end
end

uclist.uniq.each do |path|
  puts "sorting #{path}..."
  lines = File.open(path, 'r:utf-8').readlines.sort do |a, b|
    ptn = /nbsp;\(([0-9+\-]+ [0-9:]+ \+[0-9]{4})\)<BR>/
    aa = a.match(ptn)
    bb = b.match(ptn)
    # puts "#{aa[1]} <=> #{bb[1]}"
    aa[1] <=> bb[1] # 日時の比較 新しいものが下
    # bb[1] <=> aa[1] # 日時の比較 新しいものが上
  end
  lines = lines[-200, 200] if lines.size > 200
  File.open(path, 'w:utf-8').write(lines[0, 200].join)
  FileUtils.chmod(0o666, path)
end
