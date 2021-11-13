# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require './file/pathlist.rb'

# チャットファイル管理クラス
class UserChatFile
  LIMIT = 200 # 最新何発言分保存するか
  # 初期化
  #
  # @param id 対局ID
  def initialize(uid)
    @uid = uid
    @path = PathList::USERCHATDIR + uid + '.txt'
    @msg = []
  end

  # @!attribute [r] uid
  #   @return 対局ID
  # @!attribute [r] path
  #   @return ファイルパス
  # @!attribute [r] msg
  #   @return メッセージArray
  attr_reader :uid, :path, :msg

  # ファイルの読み込み
  #
  # @param fpath ファイルパス
  def read(fpath = path)
    return self unless File.exist?(fpath)

    File.open(fpath, 'r:utf-8') do |file|
      file.flock File::LOCK_EX
      @msg = file.readlines
    end
    self
  end

  # ファイルの書き出し
  #
  # @param fpath ファイルパス
  def write(fpath = path)
    File.open(fpath, 'w') do |file|
      file.flock File::LOCK_EX
      file.puts msg[0, LIMIT]
      file.flush
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  # 発言を追加する
  #
  # @param mssg 発言内容
  # @param gid 対局id
  def add(mssg, gid)
    msg.unshift(gid + ',' + mssg)
    write
  end

  # 空かどうか
  def empty?
    msg.nil?
  end

  def gameids
    ret = msg.map do |line|
      line.split(',')[0]
    end
    ret.uniq
  end

  def gameselecter
    puts '<select><option>all</option>'
    gameids.each do |gid|
      print "<option>#{gid}</option>"
    end
    puts '</select>'
  end

  def msg4mypage
    msg.map.with_index do |line, idx|
      line.chomp!
      res = line.match(
        /^([0-9a-fA-F]+?),(.+)(\(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d \+\d{4}\))<BR>$/
      )
      if res
        gid = res[1]
        "<div id=chat#{idx}><label><input style='display:none;' type=checkbox" \
        " onclick='clickchatmsg(\"chat#{idx}\", \"#{gid}\")'>" \
        "#{res[2]}<small>#{res[3]}</small>" \
        "</label><a href='index.rb?game/#{gid}' class='mypage_chatgame'>" \
        "<img src='image/right_fu.png' alt='game:#{gid}'
        title='go to this game!'></a></div>"
      else
        line
      end
    end
  end
end
