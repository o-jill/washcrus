# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'

#
# common HTML words and phrases
#
module MyHtml
  TEXTPLAIN_HEAD = "Content-Type: text/plain; charset=UTF-8\n\n"

  # Content-Type: text/plainで出力
  #
  # @param msg 出力メッセージ
  def self.print_textplain(msg)
    print TEXTPLAIN_HEAD + msg
  end

  # Content-Type: text/plainで出力
  #
  # @param msg 出力メッセージ
  def self.puts_textplain(msg)
    puts TEXTPLAIN_HEAD + msg
  end

  # puts 'ERR_NOT_ADMIN'
  def self.puts_textplain_errnotadmin
    puts_textplain('ERR_NOT_ADMIN')
  end

  # puts 'illegal access.'
  def self.puts_textplain_illegalaccess
    puts_textplain('illegal access.')
  end

  # puts 'please log in.'
  def self.puts_textplain_pleaselogin
    puts_textplain('please log in.')
  end
end
