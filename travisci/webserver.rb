# webserver for browser testing.

require 'webrick'

# .rb ファイルもCGIスクリプトとして認識させたい
module WEBrick
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
        CGIInterpreter:   '/home/travis/.rvm/rubies/' \
                          "ruby-#{RUBY_VERSION}/bin/ruby"
      }
    else
      {
        BindAddress:      '127.0.0.1',
        Port:             '3000',
        DocumentRoot:     './',
        CGIInterpreter:   '/usr/bin/env ruby'
      }
    end
  )

Signal.trap(:INT) { server.shutdown }
server.start
