# webserver for browser testing.

require 'webrick'

# .rb ファイルもCGIスクリプトとして認識させたい
module WEBrick::HTTPServlet
  FileHandler.add_handler('rb', CGIHandler)
end

server = WEBrick::HTTPServer.new(
  BindAddress:      '127.0.0.1',
  Port:             '3000',
  DocumentRoot:     './',
  CGIInterpreter:   "/home/travis/.rvm/rubies/ruby-#{RUBY_VERSION}/bin/ruby"
)

Signal.trap(:INT) { server.shutdown }
server.start
