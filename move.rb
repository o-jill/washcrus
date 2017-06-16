#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

#!C:\Ruby-2.4-x64\bin\ruby.exe
#!/usr/bin/ruby

require 'cgi'
require 'cgi/session'

require './file/jsonkifu.rb'
require './file/jsonmove.rb'
require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'
# require './views/gamehtml.rb'

#
# CGI本体
#
class Move
  def initialize(cgi)
    @cgi = cgi
    @params = cgi.params
    @gameid = cgi.query_string

    @sfen = @params['sfen'][0] unless @params['sfen'].nil?
    @move = @params['jsonmove'][0] unless @params['jsonmove'].nil?

    @jmv = JsonMove::fromtext(@move)
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
    @userinfo.readsession(@session) unless @session.nil?

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

    # 指し手を適用する
    return print "Content-Type: text/plain; charset=UTF-8\n\ninvalid move." \
      if tkd.mi.fromsfen(@sfen).nil?

    tkd.mi.write(tkd.matchinfopath)

    return print "Content-Type: text/plain; charset=UTF-8\n\ninvalid move." \
      if @move.nil

    if @move[0] == '%'
      str = @move[1, @move.length - 1]
      tkd.jkf.spmove(str)
      tkd.mi.setlastmove(str, Time.now.strftime('%Y/%m/%d %H:%M:%S'))
    else
      tkd.jkf.move(jmv)
      tkd.mi.setlastmove(@move[0, 7],
                         Time.now.strftime('%Y/%m/%d %H:%M:%S'))
    end

    tkd.jkf.write(tkd.kifupath)
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
