# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require './file/pathlist.rb'

# チャットファイル管理クラス
class UserChatFile
  LIMIT = 201 # 最新何発言分保存するか
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
      file.puts msg
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
    msg << "#{gid},#{mssg}"
    msg.shift(msg.size - LIMIT) if msg.size > LIMIT
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

  def checkdatemsg(newdate)
    return [@date, ''] if @date == newdate

    [newdate, "<div class='cvdate'>- #{newdate} -</div>"]
  end

  def checkmine(msg, myname)
    %r{^<[bB]>#{myname}</[Bb]>:} =~ msg ? 'mychatmsg' : 'notmychatmsg'
  end

  def procmsg(msg, idx, myname)
    res = msg.match(
      /^([0-9a-f]+?),(.+)\((\d{4}-\d\d-\d\d) (\d\d:\d\d:\d\d) \+\d{4}\)<BR>$/
    )
    return msg unless res

    @date, datemsg = checkdatemsg(res[3])
    mine = checkmine(res[2], myname)
    gid = res[1]

    "#{datemsg}<div id='chat#{idx}' class='#{mine}'>" \
    "<div class='fukiarea'><div class='fukidasi'>" \
    "<label><span class='#{mine}'><input style='display:none;' type=checkbox " \
    "onclick='clickchatmsg(\"chat#{idx}\", \"#{gid}\")'>" \
    "#{res[2]}</span></label></div></div><div><small>#{res[4]}</small></div>" \
    "<div><a href='index.rb?game/#{gid}' class='mypage_chatgame'>" \
    "<img src='image/right_fu.png' alt='game:#{gid}'
    title='go to this game!'></a></div></div>"
  end

  def msg4mypage(unm)
    @date = ''
    msg.map.with_index do |line, idx|
      line.chomp!
      procmsg(line, idx, unm)
    end
  end

  KIDOKU_LINE = '<div id="cvnew" class="kidoku">ここまで読んだかも</div>'

  def kidoku
    read

    # remove kidoku line
    msg.reject! do |line|
      line.index(KIDOKU_LINE)&.zero?
    end

    # append kidoku line
    msg << KIDOKU_LINE

    write
    puts "Content-type:text/plain;\n\nKIDOKU for file:#{path}\n#{KIDOKU_LINE}"
  end
end
