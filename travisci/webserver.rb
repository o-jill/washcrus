# webserver for browser testing.

require 'webrick'

# webrickを使いたい
module WEBrick
  # .rb ファイルもCGIスクリプトとして認識させたい
  module HTTPServlet
    FileHandler.add_handler('rb', CGIHandler)
  end
end

server =
  WEBrick::HTTPServer.new(
    if ENV['TRAVIS_BUILD_TYPE']
      {
        BindAddress:      '127.0.0.1',
        Port:             '3000',
        DocumentRoot:     './',
        AccessLog: [], # no access log
        CGIInterpreter:   '/home/travis/.rvm/rubies/' \
                          "ruby-#{RUBY_VERSION}/bin/ruby"
      }
    else
      {
        BindAddress:      '127.0.0.1',
        Port:             '3000',
        DocumentRoot:     './',
        # AccessLog: [],  # no access log
        CGIInterpreter:   '/usr/bin/env ruby'
      }
    end
  )

Signal.trap(:INT) { server.shutdown }
server.start
