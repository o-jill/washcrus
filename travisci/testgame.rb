require 'selenium-webdriver'
require 'yaml'

require './travisci/browsertestabs.rb'
require './file/pathlist.rb'

#
# play a game automatically with a kifu.
#
class TestGame < BrowserTestAbstract
  def initialize
    super
  end

  attr_reader :color, :driver, :gid, :nmsen, :nmgo, :emlsen, :emlgo, \
              :pwsen, :pwgo, :moves, :special, :resultsfen

  def setgame(hash)
    @gid = hash
    swap_ply if checksengo
  end

  def checksengo
    path = "taikyoku/#{gid}/matchinfo.txt"
    data = YAML.load_file(path)

    @gid = data[:gid]
    return puts "@gid:#{gid} is wrong." unless gid

    # puts "swap?:#{data[:playerb]} != #{@nmsen}"
    data[:playerb] != nmsen
  end

  def swap_ply
    t = nmsen
    @nmsen = nmgo
    @nmgo = t

    t = emlsen
    @emlsen = emlgo
    @emlgo = t

    t = pwsen
    @pwsen = pwgo
    @pwgo = t
  end

  def setplayersen(name, eml, pwd)
    @nmsen = name
    @emlsen = eml
    @pwsen = pwd
  end

  def setplayergo(name, eml, pwd)
    @nmgo = name
    @emlgo = eml
    @pwgo = pwd
  end

  def reshapemoves
    @moves = moves.map.each do |te|
      te['move']
    end
    @moves.compact!
    # puts @moves
  end

  def read(path)
    File.open(path, 'r:utf-8') do |file|
      data = JSON.parse(file.read)
      @header = data['header']
      @moves = data['moves']
      @initial = data['initial']
      @resultsfen = data['result']
      @special = moves.last['special']
    end
    reshapemoves
  end

  def becomesente
    checklogin(emlsen, pwsen)
  end

  def becomegote
    checklogin(emlgo, pwgo)
  end

  def logout
    driver.navigate.to BASE_URL + 'index.rb?logout'
  end

  def gogame
    driver.navigate.to BASE_URL + "index.rb?game/#{gid}"
  end

  def touch(sujidan)
    driver.find_element(:id, "b#{sujidan['x']}#{sujidan['y']}").click
  end

  def move(sujidan)
    driver.find_element(:id, "b#{sujidan['x']}#{sujidan['y']}").click
  end

  def naru(bnaru)
    eid = bnaru ? 'naru' : 'narazu'
    driver.find_element(:id, eid).click
  end

  # 打つ（持つだけ）
  def utu_motu(str)
    driver.find_element(:id, {
      FU: 'sg_fu_img',
      KY: 'sg_kyo_img',
      KE: 'sg_kei_img',
      GI: 'sg_gin_img',
      KI: 'sg_kin_img',
      KA: 'sg_kaku_img',
      HI: 'sg_hisha_img'
    }[str.to_sym]).click
  end

  def confirmmove(okcan = 'ok')
    eid = 'mvcfm_' + okcan
    driver.find_element(:id, eid).click
  end

  def mustpromote?(piece, yfrm)
    yfrm == 2 && piece == 'FU' || yfrm == 2 && piece == 'KY' \
      || yfrm <= 4 && piece == 'KE'
  end

  # @param prmt nil:don't care or true:promote or false:no-promote
  def promotedlg?(prmt, piece, yfrm)
    return false if prmt.nil?

    !mustpromote?(piece, yfrm)
  end

  def resignbtn
    driver.find_element(:id, 'btn_resign').click
  end

  def resign(clr)
    if clr.zero?
      becomesente
    else
      becomegote
    end

    gogame

    resignbtn
    confirmmove('ok')
  end

  def checklastsfen
    path = "taikyoku/#{gid}/matchinfo.txt"
    data = YAML.load_file(path)

    sfen = data[:sfen]
    @turn = data[:turn]
    puts "#{sfen == resultsfen} := #{sfen} == #{resultsfen}"
    res.succfail(sfen == resultsfen)
  end

  # usage:
  # lock do
  #   do_something
  # end
  def lock(*)
    Timeout.timeout(10) do
      File.open(@lockfn, 'w') do |file|
        begin
          file.flock(File::LOCK_EX)
          yield
        ensure
          file.flock(File::LOCK_UN)
        end
      end
    end
  rescue Timeout::Error
    raise AccessDenied.new('timeout')
  end

  def checktaikyokulines(file)
    @lockfn = PathList::TAIKYOKULOCKFILE
    lock do
      file.each_line do |line|
        # next if line =~ /^#/ # comment
        # id, idv, idw, nameb, namew, turn, time, comment
        next unless line.start_with?(gid + ',')
        elem = line.chomp.split(',')
        ret = !%w[b w].include?(elem[5])
        puts "ret = !%w[b w].include?(#{elem[5]})" unless ret
        return res.succfail(ret)
      end
      false # 見つからなかった
    end
  end

  def checktaikyokucsv
    path = 'db/taikyoku.csv'
    File.open(path, 'r:utf-8') do |file|
      # file.flock File::LOCK_EX
      return checktaikyokulines(file)
    end
    puts "could not find game:#{gid}"
    res.succfail(false)
  end

  def checktaikyokuchucsv
    path = 'db/taikyokuchu.csv'
    File.open(path, 'r:utf-8') do |file|
      # file.flock File::LOCK_EX
      file.each_line do |line|
        # id, idv, idw, nameb, namew, turn, time, comment
        ret = line.start_with?(gid + ',')
        puts "#{line}.start_with?(#{gid + ','})" if ret
        return res.succfail(false) if ret
      end
    end
    puts 'removed from taikyokuchu successfully.'
    res.succfail(true)
  end

  def move_a_piece(from, to)
    if from
      touch(from)
      move(to)
      confirmmove('ok')
      naru(@prmt) if promotedlg?(@prmt, @piece, from['y'])
    else
      utu_motu(@piece)
      move(to)
      confirmmove('ok')
    end
  end

  def cvtxy(frm, too)
    from = {}
    if frm
      from['x'] = 10 - frm['x']
      from['y'] = 10 - frm['y']
    else
      from = frm
    end
    to = {}
    to['x'] = 10 - too['x']
    to['y'] = 10 - too['y']

    { from: from, to: to }
  end

  def prcs_sengo(from, to)
    if color.zero?
      becomesente
      { from: from, to: to }
    else
      becomegote
      cvtxy(from, to)
    end
  end

  def li_move_a_piece
    ret = prcs_sengo(@from, @to)

    gogame

    move_a_piece(ret[:from], ret[:to])

    sleep 3
    logout
  end

  def readmove(tee)
    @from = tee['from']
    @to = tee['to'] if tee['to']
    @prmt = tee['promote']
    @piece = tee['piece']
    @color = tee['color']

    # puts "#{@color}#{@piece}:#{@from}->#{@to},#{@prmt}" if tee['same']
  end

  def move_with_kifu
    moves.each do |tee|
      puts "tee:#{tee}"

      readmove(tee)

      li_move_a_piece
    end
  rescue StandardError => er
    puts "ERROR in move_with_kifu: class=[#{er.class}] message=[#{er.message}]"
  end

  def run
    move_with_kifu
    resign(1 - moves.last['color']) if special == 'TORYO'
    logout
    # ブラウザを終了させる
    # driver.quit

    checklastsfen
    checktaikyokuchucsv
    checktaikyokucsv
  end
end
