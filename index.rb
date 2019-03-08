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
  washcrus = WashCrus.new(cgi)
  washcrus.perform
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
