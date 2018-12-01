require 'webrick'

#
# デフォルトでは .cgi ファイルだけがCGIスクリプトとして認識される
# .rb ファイルもCGIスクリプトとして認識させたい場合は次のブロックをコメントアウト
#
module WEBrick::HTTPServlet
  FileHandler.add_handler('rb', CGIHandler)
end

server = WEBrick::HTTPServer.new({
  BindAddress:    '127.0.0.1',
  Port:           '3000',
  DocumentRoot:   './',
  # CGIInterpreter: '/usr/bin/ruby' # Rubyのインストール先
  # CGIInterpreter: '/home/travis/.rvm/rubies/ruby-2.4.4/bin/ruby'
  CGIInterpreter: "/home/travis/.rvm/rubies/ruby-#{RUBY_VERSION}/bin/ruby"
  # CGIInterpreter: '/usr/bin/env ruby'
  # CGIInterpreter: 'ruby'
})

Signal.trap(:INT){ server.shutdown }
server.start
