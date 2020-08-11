require 'selenium-webdriver'

require 'yaml'

require './travisci/testgame.rb'

#
# make a game by draw suggestion.
#
class TestDraw < TestGame
  def initialize
    super
  end

  # 引き分け提案ボタンを押す
  def drawbtn
    driver.find_element(:id, 'btn_draw_suggest').click
  end

  # 引き分けの提案行為
  def drawsuggest(clr, sug = true)
    clr.zero? ? becomesente : becomegote

    gogame

    drawbtn

    confirmmove(sug)

    sleep 3
    logout
  end

  SENTE = 0
  GOTE = 1
  SEQ = {
    trfa: [true, false],
    fatr: [false, true],
    fafa: [false, false],
    trtr: [true, true]
  }.freeze

  # 実行
  def run
    swap_ply if [true, false].sample
    SEQ.each do |key, val|
      puts("phase:#{key}")
      drawsuggest(SENTE, val[0])
      drawsuggest(GOTE, val[1])
    end
    # ブラウザを終了させる
    # driver.quit

    checktaikyokuchucsv
    checktaikyokucsv
  end
end
