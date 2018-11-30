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
  CGIInterpreter: '/usr/bin/ruby' # Rubyのインストール先
})

Signal.trap(:INT){ server.shutdown }
server.start
