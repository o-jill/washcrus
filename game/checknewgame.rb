# -*- encoding: utf-8 -*-

require 'rubygems'

require 'cgi'
require 'digest/sha2'

require './file/userinfofile.rb'
require './game/taikyokudata.rb'

#
# 対局作成確認
#
class CheckNewGame
  def initialize(cgi)
    @errmsg = ''
    @cgi = cgi
    @params = cgi.params

    @name1 = nil
    @email1 = nil
    @name2 = nil
    @email2 = nil
  end

  def check_params(params)
    params['rname'].nil? || params['remail'].nil? \
      || params['rname2'].nil? || params['remail2'].nil?
  end

  def read_params
    return if @errmsg.length !~ 0

    @name1 = @params['rname'][0]
    @email1 = @params['remail'][0]
    @name2 = @params['rname2'][0]
    @email2 = @params['remail2'][0]
  end

  def check_ply(userdata, name)
    userdata.nil? || name != userdata[1]
  end

  def check
    return @errmsg += 'data lost ...' if check_params(@params)

    read_params

    userdb = UserInfoFile.new
    userdb.read

    userdata1 = userdb.findemail(@email1)  # [id, @names[id], @passwords[id]]
    @errmsg = "name or e-mail address in player 1 is wrong ...\n" \
      if check_ply(userdata1, @name1)

    userdata2 = userdb.findemail(@email2)  # [id, @names[id], @passwords[id]]
    @errmsg += "name or e-mail address in player 2 is wrong ...\n" \
        if check_ply(userdata2, @name2)
  end

  def perform
    check

    return puts "Content-type: text/plain;\n\n#{@errmsg}" \
      unless @errmsg.length.zero?

    puts "Content-type: text/plain;\n\nnew game check passed!\n"

    # td = TaikyokuData.new
    # td.player1 = name1
    # td.email1 = email1
    # td.player2 = name2
    # td.email2 = email2
    # td.creator = username
    # td.checkgenerate
    # td.dump
  end
end
