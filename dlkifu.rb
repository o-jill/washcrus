#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

#!d:\ruby193\bin\ruby.exe
#!C:\Ruby-2.4-x64\bin\ruby.exe
#!/usr/bin/ruby

require 'cgi'
require 'cgi/session'

require './file/jsonkifu.rb'
require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'
require './views/gamehtml.rb'

#
# CGI本体
#
class Game
  def initialize(cgi)
    @cgi = cgi
    # @params = cgi.params

    @gameid = cgi.query_string
  end

  def readuserparam
    begin
      @session = CGI::Session.new(@cgi,
                                  {
                                    'new_session' => false,
                                    'session_key' => '_washcrus_session',
                                    'tmpdir' => './tmp'
                                  })
    rescue ArgumentError
      # @session = nil
    end

    @userinfo = UserInfo.new
    if @session.nil?
      @userinfo.visitcount = '1'
    else
      @userinfo.readsession(@session)
    end

    @header = @cgi.header('charset' => 'UTF-8')
    @header = @header.gsub("\r\n", "\n")
  end

  # class methods

  #
  # 実行本体。
  #
  def perform
    # gameid が無いよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access." \
        if @gameid.nil? || @gameid.length.zero?

    # userinfoが変だよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nplease log in." \
        unless @userinfo.nil? || @userinfo.exist_indb

    tdb = TaikyokuFile.new
    tdb.read
    # 存在しないはずのIDだよ
    return print "Content-Type: text/plain; charset=UTF-8\n\nillegal access." \
        unless tdb.exist_id(@gameid)

    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    # 表示する
    # tkd.download_csa
    tkd.download_kif
  end

  # class methods
end

# -----------------------------------
#   main
#

cgi = CGI.new

game = Game.new(cgi)
game.readuserparam
game.perform

# -----------------------------------
#   testing
#
