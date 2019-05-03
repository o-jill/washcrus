require 'selenium-webdriver'
require 'yaml'

require './travisci/browsertestabs.rb'

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

  def setplayer1(nm, eml, pw)
    @nm1 = nm
    @eml1 = eml
    @pw1 = pw
  end

  def setplayer2(nm, eml, pw)
    @nm2 = nm
    @eml2 = eml
    @pw2 = pw
  end

  def read(path)
    File.open(path, 'r:utf-8') do |file|
      data = JSON.parse(file.read)
      @header = data['header']
      @moves = data['moves']
      @initial = data['initial']
      @resultsfen = data['result']
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
    @driver.navigate.to BASE_URL + "index.rb?logout"
  end

  def gogame
    @driver.navigate.to BASE_URL + "index.rb?game/#{@gid}"
  end

  def touch(suji, dan)
    @driver.find_element(:id, "b#{suji}#{dan}").click
  end

  def move(suji, dan)
    @driver.find_element(:id, "b#{suji}#{dan}").click
  end

  def naru(bnaru)
    eid = bnaru ? 'naru' : 'narazu'
    elem = @driver.find_element(:id, eid).click
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
        HI: 'sg_hisha_img',
      }[str.to_sym]).click
  end

  def confirmmove
    driver.find_element(:id, 'mvcfm_ok').click
  end

  def promotedlg?(te, fy)
    prmt = te['promote']
    if prmt
      case te['piece']
      when 'FU'
        return false if fy == 2
      when 'KY'
        return false if fy == 2
      when 'KE'
        return false if fy <= 4
      end

      true
    else
      false
    end
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
    puts "exit -838861 if #{sfen} != #{@resultsfen}"
    exit -838861 if sfen != @resultsfen
  end

  def run
    @moves.each do |te|
      puts "te:#{te}"

      from = te['from']
      to = te['to']
      prmt = te['promote']

      if te['color'].zero?
        becomesente
      else
        from['x'] = 10 - from['x'] if from
        from['y'] = 10 - from['y'] if from
        to['x'] = 10 - to['x']
        to['y'] = 10 - to['y']

        becomegote
      end

      gogame

      if from
        touch(from['x'], from['y'])
        move(to['x'], to['y'])
        confirmmove
        naru(prmt) if promotedlg?(te, from['y'])
      else
        utu_motu(te['piece'])
        move(to['x'], to['y'])
        confirmmove
      end

      sleep 4
      logout
    end

    resign(1 - @moves.last['color'])
  end
end
