require 'selenium-webdriver'
require 'yaml'

require './travisci/browsertestabs.rb'

#
# play a game automatically with a kifu.
#
class TestGame < BrowserTestAbstract
  def initialize
    super
  end

  def setgame(hash)
    @gid = hash
    swap_ply if checksengo
  end

  def checksengo
    path = "taikyoku/#{@gid}/matchinfo.txt"
    data = YAML.load_file(path)

    @gid = data[:gid]
    return puts "@gid:#{@gid} is wrong." unless @gid

    # puts "swap?:#{data[:playerb]} != #{@nm1}"
    data[:playerb] != @nm1
  end

  def swap_ply
    t = @nm1
    @nm1 = @nm2
    @nm2 = t

    t = @eml1
    @eml1 = @eml2
    @eml2 = t

    t = @pw1
    @pw1 = @pw2
    @pw2 = t
  end

  def setplayer1(name, eml, pwd)
    @nm1 = name
    @eml1 = eml
    @pw1 = pwd
  end

  def setplayer2(name, eml, pwd)
    @nm2 = name
    @eml2 = eml
    @pw2 = pwd
  end

  def read(path)
    File.open(path, 'r:utf-8') do |file|
      data = JSON.parse(file.read)
      @header = data['header']
      @moves = data['moves']
      @initial = data['initial']
      @resultsfen = data['result']
      @special = @moves.last['special']
    end
    @moves = @moves.map.each do |te|
      te['move']
    end
    @moves.compact!
    # puts @moves
  end

  def becomesente
    checklogin(@eml1, @pw1)
  end

  def becomegote
    checklogin(@eml2, @pw2)
  end

  def logout
    @driver.navigate.to BASE_URL + 'index.rb?logout'
  end

  def gogame
    @driver.navigate.to BASE_URL + "index.rb?game/#{@gid}"
  end

  def touch(sujidan)
    @driver.find_element(:id, "b#{sujidan['x']}#{sujidan['y']}").click
  end

  def move(sujidan)
    @driver.find_element(:id, "b#{sujidan['x']}#{sujidan['y']}").click
  end

  def naru(bnaru)
    eid = bnaru ? 'naru' : 'narazu'
    @driver.find_element(:id, eid).click
  end

  # 打つ（持つだけ）
  def utu_motu(str)
    @driver.find_element(:id, {
      FU: 'sg_fu_img',
      KY: 'sg_kyo_img',
      KE: 'sg_kei_img',
      GI: 'sg_gin_img',
      KI: 'sg_kin_img',
      KA: 'sg_kaku_img',
      HI: 'sg_hisha_img'
    }[str.to_sym]).click
  end

  def confirmmove
    driver.find_element(:id, 'mvcfm_ok').click
  end

  def mustpromote?(piece, yfrm)
    yfrm == 2 && piece == 'FU' || yfrm == 2 && piece == 'KY' \
      || yfrm <= 4 && piece == 'KE'
  end

  def promotedlg?(prmt, piece, yfrm)
    return false unless prmt

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
    confirmmove
  end

  def checklastsfen
    path = "taikyoku/#{@gid}/matchinfo.txt"
    data = YAML.load_file(path)

    sfen = data[:sfen]
    @turn = data[:turn]
    puts "#{sfen == @resultsfen} := #{sfen} == #{@resultsfen}"
    res.succfail(sfen == @resultsfen)
  end

  def checktaikyokucsv
    path = "db/taikyoku.csv"
    File.open(path, 'r:utf-8') do |file|
      # file.flock File::LOCK_EX
      file.each_line do |line|
        next if line =~ /^#/  # comment
        # id, idv, idw, nameb, namew, turn, time, comment
        elem = line.chomp.split(',')
        if elem[0] == @gid
          turn = elem[5]
          return res.succfail(turn != 'b' && turn != 'w')
        end
      end
    end
    puts "could not find game:#{@gid}"
    res.succfail(false)
  end

  def checktaikyokuchucsv
    path = "db/taikyokuchu.csv"
    File.open(path, 'r:utf-8') do |file|
      # file.flock File::LOCK_EX
      file.each_line do |line|
        next if line =~ /^#/  # comment
        # id, idv, idw, nameb, namew, turn, time, comment
        elem = line.chomp.split(',')

        res.succfail(elem[0] != @gid)
      end
    end
  end

  def move_a_piece(from, to)
    if from
      touch(from)
      move(to)
      confirmmove
      naru(@prmt) if promotedlg?(@prmt, @piece, from['y'])
    else
      utu_motu(@piece)
      move(to)
      confirmmove
    end
  end

  def cvtxy(frm, too)
    from = {}
    from['x'] = 10 - frm['x'] if frm
    from['y'] = 10 - frm['y'] if frm
    from = frm unless frm
    to = {}
    to['x'] = 10 - too['x']
    to['y'] = 10 - too['y']

    { from: from, to: to }
  end

  def prcs_sengo(from, to, color)
    if color.zero?
      becomesente
      { from: from, to: to }
    else
      becomegote
      cvtxy(from, to)
    end
  end

  def li_move_a_piece
    ret = prcs_sengo(@from, @to, @color)

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
    @moves.each do |tee|
      puts "tee:#{tee}"

      readmove(tee)

      li_move_a_piece
    end
  rescue StandardError => er
    puts "ERROR in move_with_kifu: class=[#{er.class}] message=[#{er.message}]"
  end

  def run
    move_with_kifu
    resign(1 - @moves.last['color']) if @special == 'TORYO'

    # ブラウザを終了させる
    driver.quit

    checklastsfen
    checktaikyokuchucsv
    checktaikyokucsv
  end
end
