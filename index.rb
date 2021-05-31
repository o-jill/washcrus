#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'bundler/setup'

require 'cgi'
require 'cgi/session'

require './washcrus.rb'

# -----------------------------------
#   main
#

begin
  cgi = CGI.new
  # ブロック内の処理を計測
  require 'stackprof'
  StackProf.run(out: "./tmp/stackprof_#{Time.now.to_i}.dump") do
  washcrus = WashCrus.new(cgi)
  washcrus.perform
  end
rescue StandardError => err
  puts "Content-Type: text/html; charset=UTF-8\n\n"
  puts <<-ERRMSG.unindent
    <html><title>ERROR Washcrus</title><body><pre>
    ERROR:#{err}
    STACK:#{err.backtrace.join("\n")}
    </pre></body></html>
  ERRMSG
end
# -----------------------------------
#   testing
#
