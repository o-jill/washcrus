# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'rubygems'
require 'unindent'
# require 'redcarpet'

require './file/pathlist.rb'
require './game/userinfo.rb'
require './util/myhtml.rb'
require './views/common_ui.rb'

#
# NEWS編集結果画面
#
class AdminMarqueeNewsUpdateScreen
  # 初期化
  #
  # @param header htmlヘッダ
  def initialize(header)
    @header = header
    @errmsg = ''
  end

  # news内容の確認と保存
  #
  # @param params パラメータハッシュオブジェクト
  def write_param(params)
    if params['mqnews']
      update_mqnews(params['mqnews'][0])
    else
      @errmsg += 'invalid parameters...<br>'
    end
  end

  # newsをファイルに書き込む
  #
  # @param news newsの内容
  def update_mqnews(mqnews)
    File.write(PathList::MQNEWSFILE, mqnews)
  rescue StandardError => er
    @errmsg += "failed to update...#{er}"
  end

  def put_marquee
    lines = File.read(PathList::MQNEWSFILE).lines(chomp: true)
    lines.each do |line|
      next if line.empty?
      puts "<div class='marquee-anim'><span>#{line}</span></div>"
    end
  end

  # 画面の表示
  #
  # @param userinfo ユーザー情報
  # @param params パラメータハッシュオブジェクト
  def show(userinfo, params)
    return MyHtml.puts_textplain_errnotadmin unless userinfo.admin

    write_param(params)

    CommonUI.html_head(@header)
    CommonUI.html_menu(userinfo)
    CommonUI.html_adminmenu

    if @errmsg.empty?
      put_marquee
    else
      puts @errmsg
    end

    CommonUI.html_foot
  end
end
