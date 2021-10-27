# frozen_string_literal: true

require 'selenium-webdriver'
require 'yaml'

require './file/mylock.rb'
require './file/pathlist.rb'
require './travisci/browsertestabs.rb'

#
# functions to play a game automatically with a kifu.
#
class TestGameAbstract < BrowserTestAbstract
  include MyLock
  # 初期化
  def initialize
    super
  end

  attr_reader :driver, :gid, :nmsen, :nmgo, :emlsen, :emlgo, \
              :pwsen, :pwgo, :resultsfen

  # 対局情報のセット
  #
  # @param hash game-id
  def setgame(hash)
    @gid = hash
    swap_ply if checksengo
  end

  # 先後がどっちなのかチェックする
  def checksengo
    # path = "taikyoku/#{gid}/matchinfo.txt"
    data = YAML.load_file("taikyoku/#{gid}/matchinfo.txt")

    @gid = data[:gid]
    return puts "@gid:#{gid} is wrong." unless gid

    # puts "swap?:#{data[:playerb]} != #{@nmsen}"
    data[:playerb] != nmsen
  end

  # 先手と後手の情報を入れ替える
  def swap_ply
    @nmsen, @nmgo = @nmgo, @nmsen

    @emlsen, @emlgo = @emlgo, @emlsen

    @pwsen, @pwgo = @pwgo, @pwsen
  end

  # 先手情報のセット
  #
  # @param name 名前
  # @param eml メールアドレス
  # @param pwd パスワード
  def setplayersen(name, eml, pwd)
    @nmsen = name
    @emlsen = eml
    @pwsen = pwd
  end

  # 後手情報のセット
  #
  # @param name 名前
  # @param eml メールアドレス
  # @param pwd パスワード
  def setplayergo(name, eml, pwd)
    @nmgo = name
    @emlgo = eml
    @pwgo = pwd
  end

  # 先手としてログイン
  def becomesente
    checkloginsucc(emlsen, pwsen)
  end

  # 後手としてログイン
  def becomegote
    checkloginsucc(emlgo, pwgo)
  end

  # ログアウトする
  def logout
    driver.navigate.to BASE_URL + 'index.rb?logout'
  end

  # 対局ページに移動
  def gogame
    driver.navigate.to BASE_URL + "index.rb?game/#{gid}"
  end

  # 移動確認ダイアログのボタンをクリックする
  #
  # @param okcan ボタンのID。'ok' or 'cancel'
  def confirmmove(okcan = 'ok')
    eid = 'mvcfm_' + okcan
    driver.find_element(:id, eid).click
  end

  # 対局結果のチェック
  def checkresult(t, drawornot)
    # id, idv, idw, nameb, namew, turn, time, comment
    elem = t.split(',')
    result = elem[5]
    ret = drawornot ? result == 'd' : %w[fb fw d].include?(result)
    puts "ret = %w[fb fw d].include?(#{result})" unless ret
    res.succfail(ret)
  end

  # 対局ファイルのチェック
  def checktaikyokulines(file, drawornot)
    t = file.each_line.find do |line|
      line.start_with?(gid + ',')
    end
    return res.succfail(false) unless t # 見つからなかった
    checkresult(t, drawornot)
  end

  # 対局ファイルのチェック
  def checktaikyokucsv(drawornot = nil)
    lock(PathList::TAIKYOKULOCKFILE) do
      path = 'db/taikyoku.csv'
      File.open(path, 'r:utf-8') do |file|
        # file.flock File::LOCK_EX
        return checktaikyokulines(file, drawornot)
      end
      puts "could not find game:#{gid}"
      res.succfail(false)
    end
  end

  # 対局中ファイルのチェック 本体
  def checktaikyokuchucsvmain
    path = 'db/taikyokuchu.csv'
    File.open(path, 'r:utf-8') do |file|
      # file.flock File::LOCK_EX
      t = file.each_line.find do |line|
        line.start_with?(gid + ',')
      end
      return puts "'#{t}'.start_with?(#{gid + ','})" if t
    end
    puts 'removed from taikyokuchu successfully.'
    self
  end

  # 対局中ファイルのチェック
  def checktaikyokuchucsv
    lock(PathList::TAIKYOKUCHULOCKFILE) do
      res.succfail(!checktaikyokuchucsvmain.nil?)
    end
  end
end
