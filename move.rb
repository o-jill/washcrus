#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

#!C:\Ruby-2.4-x64\bin\ruby.exe
#!/usr/bin/ruby

require 'cgi'
require 'cgi/session'
require 'logger'

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
  TEXTPLAIN_HEAD = "Content-Type: text/plain; charset=UTF-8\n\n".freeze

  def initialize(cgi)
    @log = Logger.new('./tmp/movelog.txt')
    # @log.level = Logger::INFO
    @log.info('Move.new()')
    @cgi = cgi
    @params = cgi.params
    @gameid = cgi.query_string
    @log.info("gameid:#{@gameid}")
    @sfen = @params['sfen'][0] unless @params['sfen'].nil?
    @move = @params['jsonmove'][0] unless @params['jsonmove'].nil?
    @log.info("sfen:#{@sfen}")
    @log.info("move:#{@move}")
    @jmv = JsonMove.fromtext(@move)
    @log.debug('Move.initialized')
  end

  def readuserparam
    @log.debug('Move.readuserparam')
    begin
      @session = CGI::Session.new(@cgi,
                                  {
                                    'new_session' => false,
                                    'session_key' => '_washcrus_session',
                                    'tmpdir' => './tmp'
                                  })
    rescue ArgumentError
      # @session = nil
      @log.info('failed to find session')
    end

    @userinfo = UserInfo.new
    @userinfo.readsession(@session) unless @session.nil?

    @header = @cgi.header('charset' => 'UTF-8')
    @header = @header.gsub("\r\n", "\n")
  end

  def check_param
    # gameid が無いよ
    return print TEXTPLAIN_HEAD + 'illegal access.' \
        if @gameid.nil? || @gameid.length.zero?

    # userinfoが変だよ
    return print TEXTPLAIN_HEAD + 'please log in.' \
        unless @userinfo.nil? || @userinfo.exist_indb

    # moveが変だよ
    return print TEXTPLAIN_HEAD + 'invalid move.' if @jmv.nil?

    self
  end

  #
  # 実行本体。
  #
  def perform
    @log.debug('Move.perform')
    # gameid が無いよ
    # userinfoが変だよ
    # moveが変だよ
    return if check_param.nil?

    @log.debug('Move.check gameid')
    tdb = TaikyokuFile.new
    tdb.read
    # 存在しないはずのIDだよ
    return print TEXTPLAIN_HEAD + 'illegal access.' unless tdb.exist_id(@gameid)

    @log.debug('Move.read data')
    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    @log.debug('Move.apply sfen')
    # 指し手を適用する
    return print TEXTPLAIN_HEAD + 'invalid move.' if tkd.mi.fromsfen(@sfen).nil?

    @log.debug('Move.setlastmove')
    tkd.mi.setlastmove(@move[0, 7], Time.now.strftime('%Y/%m/%d %H:%M:%S'))

    @log.debug('Move.mi.write')
    tkd.mi.write(tkd.matchinfopath)

    @log.debug('Move.apply jmv')
    tkd.jkf.move(@jmv)

    @log.debug('Move.jkf.write')
    tkd.jkf.write(tkd.kifupath)
    @log.debug('Move.performed')
  end
end

# -----------------------------------
#   main
#

cgi = CGI.new

move = Move.new(cgi)
move.readuserparam
move.perform

# -----------------------------------
#   testing
#
