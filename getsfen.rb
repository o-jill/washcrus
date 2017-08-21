#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'logger'

# require './file/jsonkifu.rb'
# require './file/jsonmove.rb'
require './file/matchinfofile.rb'
require './file/taikyokufile.rb'
require './game/userinfo.rb'

#
# CGI本体
#
class GetSfen
  TEXTPLAIN_HEAD = "Content-Type: text/plain; charset=UTF-8\n\n".freeze

  def initialize(cgi)
    # @log = Logger.new('./tmp/movelog.txt')
    # @log.level = Logger::INFO
    # @log.info('Move.new()')
    @cgi = cgi
    @params = cgi.params
    @gameid = cgi.query_string
    # @log.info("gameid:#{@gameid}")
    # @sfen = @params['sfen'][0] unless @params['sfen'].nil?
    # @move = @params['jsonmove'][0] unless @params['jsonmove'].nil?
    # @log.info("sfen:#{@sfen}")
    # @log.info("move:#{@move}")
    # @jmv = JsonMove.fromtext(@move)
    # @log.debug('Move.initialized')
  end

  # attr_reader :log

  def readuserparam
    # @log.debug('Move.readuserparam')
    begin
      @session = CGI::Session.new(@cgi,
                                  {
                                    'new_session' => false,
                                    'session_key' => '_washcrus_session',
                                    'tmpdir' => './tmp'
                                  })
    rescue ArgumentError
      @session = nil
      # @log.info('failed to find session')
    end

    @userinfo = UserInfo.new
    @userinfo.readsession(@session) unless @session.nil?

    # @header = @cgi.header('charset' => 'UTF-8')
    # @header = @header.gsub("\r\n", "\n")
  end

  def check_param
    # gameid が無いよ
    return print TEXTPLAIN_HEAD + 'ERROR:illegal access.' \
        if @gameid.nil? || @gameid.empty?

    # userinfoが変だよ
    return print TEXTPLAIN_HEAD + 'ERROR:please log in.' \
        unless @userinfo.nil? || @userinfo.exist_indb

    # # moveが変だよ
    # return print TEXTPLAIN_HEAD + 'ERROR:invalid move.' if @jmv.nil?

    self
  end

  #
  # 実行本体。
  #
  def perform
    # @log.debug('Move.perform')
    # gameid が無いよ
    # userinfoが変だよ
    # moveが変だよ
    return if check_param.nil?

    # @log.debug('Move.check gameid')
    tcdb = TaikyokuChuFile.new
    tcdb.read
    # 存在しないはずのIDだよ
    return print TEXTPLAIN_HEAD + 'ERROR:illegal access.' \
      unless tcdb.exist_id(@gameid)

    # @log.debug('Move.read data')
    tkd = TaikyokuData.new
    tkd.setid(@gameid)
    tkd.read

    print TEXTPLAIN_HEAD + tkd.mi.sfen
  end
end

# -----------------------------------
#   main
#

cgi = CGI.new
begin
  getsfen = GetSfen.new(cgi)
  getsfen.readuserparam
  getsfen.perform
# rescue ScriptError => e
#   move.log.warn("class=[#{e.class}] message=[#{e.message}] in move")
# rescue SecurityError => e
#   move.log.warn("class=[#{e.class}] message=[#{e.message}] in move")
# rescue => e
#   move.log.warn("class=[#{e.class}] message=[#{e.message}] in move")
end
# -----------------------------------
#   testing
#
