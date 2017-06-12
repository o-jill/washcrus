#!d:\ruby193\bin\ruby
# -*- encoding: utf-8 -*-

#!/usr/bin/ruby

require 'cgi'
require 'digest/sha2'

require './file/userinfofile.rb'
require './taikyokudata.rb'

cgi = CGI.new
params = cgi.params

#
# 対局作成確認
#
errmsg = ''

if params['rname'].nil? || params['rname'].length.zero? \
  || params['remail'].nil? || params['remail'].length.zero? \
  || params['rname2'].nil? || params['rname2'].length.zero? \
  || params['remail2'].nil? || params['remail2'].length.zero?
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
