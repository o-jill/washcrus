# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require './file/pathlist.rb'

# チャットファイル管理クラス
class ChatFile
  ERRMSG = 'ERROR:read a file at first...'

  # 初期化
  #
  # @param id 対局ID
  def initialize(id)
    @id = id
    @path = PathList::TAIKYOKUDIR + @id + '/' + PathList::CHATFILE
    @msg = ERRMSG
  end

  # @!attribute [r] id
  #   @return 対局ID
  # @!attribute [r] path
  #   @return ファイルパス
  # @!attribute [r] msg
  #   @return メッセージ
  attr_reader :id, :path, :msg

  # ファイルの読み込み
  #
  # @param fpath ファイルパス
  def read(fpath = path)
    File.open(fpath, 'r:utf-8') do |file|
      file.flock File::LOCK_EX
      @msg = file.read
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
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  # ファイルの1行追加書き出し
  #
  # @param line  1行分の文字列
  # @param fpath ファイルパス
  def add(line, fpath = path)
    File.open(fpath, 'a') do |file|
      file.flock File::LOCK_EX
      file.puts line
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  end

  # 発言する
  #
  # @param name 名前
  # @param mssg 発言内容
  def say(name, mssg)
    line = "<B>#{name}</B>:#{mssg}&nbsp;(#{Time.now})<BR>"
    add line
    line
  end

  # 発言する
  #
  # @param name 名前
  # @param mssg 発言内容
  def sayex(name, mssg)
    line = "#{name}:#{mssg}&nbsp;(#{Time.now})<BR>"
    add line
    line
  end

  WITNESS = "<span id='chatadmin'>Witness</span>"

  # 対局開始の合図
  #
  # @param name 先手名
  def say_start(name)
    sayex(WITNESS,
          "it's on time. please start your move as SENTE, #{name}-san.")
  end

  # 対局開始の合図
  #
  # @param name 勝者名
  # @param result 'd':引き分け, otherwise:どっちかが勝った。
  # @param moves 手数
  def say_finish(name, result, moves)
    sayex(WITNESS,
          if result != 'd'
            "#{name}-san won this game after #{moves} moves."
          else
            "this game was draw after #{moves} moves."
          end)
  end

  # 引き分け提案
  #
  # @param name 名前
  # @param yes true:, false:
  def say_sugdraw(name, yes)
    sayex(WITNESS,
          if yes
            "#{name}さんから引き分け提案がありました。"
          else
            "#{name}さんから引き分け提案の取りやめがありました。"
          end)
  end

  # チャット内容の出力
  def put
    print "Content-type:text/html;\n\n#{msg}"
  end

  # チャットのメッセージから立会人の発言と名前の<B>タグと<BR>タグを取り去る
  #
  # @return いろいろ取り去ったあとのチャットメッセージ
  def stripped_msg_keepusers
    newmsg = ''
    msg.each_line do |line|
      newmsg += line.gsub(%r{(<B>|<\/B>|<BR>)}, '') \
        unless line =~ /^<span id='chatadmin'>/
    end
    newmsg.gsub(/&(#44|nbsp|lt|gt|amp);/,
                '&#44;' => ',', '&nbsp;' => ' ',
                '&lt;' => '<', '&gt;' => '>', '&amp;' => '&')
  end

  # チャットのメッセージから立会人の<span>と名前の<B>タグと<BR>タグを取り去る
  #
  # @return いろいろ取り去ったあとのチャットメッセージ
  def stripped_msg
    newmsg = ''
    msg.each_line do |line|
      newmsg += line.gsub(
        %r{(<span id='chatadmin'>|<\/span>|<B>|<\/B>|<BR>)},
        ''
      )
    end
    newmsg.gsub(/&(#44|nbsp|lt|gt|amp);/,
                '&#44;' => ',', '&nbsp;' => ' ',
                '&lt;' => '<', '&gt;' => '>', '&amp;' => '&')
  end
end
