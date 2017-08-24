#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'cgi'
require 'digest/sha2'

require './file/userinfofile.rb'
require './game/taikyokudata.rb'

cgi = CGI.new
params = cgi.params

#
# 対局作成確認
#
errmsg = ''

if params['rname'].nil? || params['rname'].empty? \
  || params['remail'].nil? || params['remail'].empty? \
  || params['rname2'].nil? || params['rname2'].empty? \
  || params['remail2'].nil? || params['remail2'].empty?
  errmsg += 'data lost ...<BR>'
else
  name1 = params['rname'][0]
  email1 = params['remail'][0]
  name2 = params['rname2'][0]
  email2 = params['remail2'][0]

  userdb = UserInfoFile.new
  userdb.read
  userdata1 = userdb.findemail(email1)  # [id, @names[id], @passwords[id]]
  if userdata1.nil? || name1 != userdata1[1]
    errmsg += "name or e-mail address in player 1 is wrong ...\n"
  end
  userdata2 = userdb.findemail(email2)  # [id, @names[id], @passwords[id]]
  if userdata2.nil? || name2 != userdata2[1]
    errmsg += "name or e-mail address in player 2 is wrong ...\n"
  end
end

puts "Content-type: text/plain;\n\n"
if errmsg != ''
  puts errmsg
else
  puts "new game check passed!\n"

  # td = TaikyokuData.new
  # td.player1 = name1
  # td.email1 = email1
  # td.player2 = name2
  # td.email2 = email2
  # td.creator = username
  # td.checkgenerate
  # td.dump
end
