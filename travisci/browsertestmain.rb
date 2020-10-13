# for testing on a browser.

# usage:
#    ruby travisci/browsertest.rb <options>
# --quick :  test only around playing.
# --nogame : dont play at all.
# -N0 :      testmove.jkf will be used.
# -N1 :      fuji_system.jkf will be used.
# -N2 :      fuji_debut.jkf will be used.
# -N3 :      koyan_tadao.jkf will be used.
# -N4 :      sennichite.jkf will be used.
# -N5 :      kingtaking.jkf will be used.

require 'selenium-webdriver'

# require './travisci/browsertestabs.rb'
require './travisci/browsertest.rb'
# require './travisci/testresult.rb'
# require './travisci/testusers.rb'
require './travisci/testgame.rb'
# require './travisci/testdraw.rb'

# main

test = BrowserTest.new
test.fold_begin('pages.1', 'pages tests')
ARGV.include?('--quick') ? test.runlight : test.run
test.fold_end('pages.1')
succ = test.showresult

test.finalize(succ) if ARGV.include?('--nogame')

tg = TestGame.new
tg.fold_begin('game.1', 'game test')
tg.setplayersen(
  TestUsers::JOHN[:rname],
  TestUsers::JOHN[:remail],
  TestUsers::JOHN[:rpassword]
)
tg.setplayergo(
  'admin',
  TestUsers::ADMININFO[:email],
  TestUsers::ADMININFO[:pwd]
)
tg.setgame(test.gameurl)
KIFULIST = [
  'travisci/testmove.jkf', # N0
  'travisci/fuji_system.jkf',
  'travisci/fuji_debut.jkf',
  'travisci/koyan_tadao.jkf',
  'travisci/sennichite.jkf',
  'travisci/kingtaking.jkf' # N5
].freeze
kifindexarr = ARGV.grep(/-N\d+/)
kifindex = kifindexarr.size.zero? ? -1 : kifindexarr[0].slice(2, 10).to_i
jkfpath = kifindex < 0 ? KIFULIST.sample : KIFULIST[kifindex]
puts "#{jkfpath}, #{ARGV} #{kifindexarr} #{kifindex}"
tg.read(jkfpath)
tg.run
tg.fold_end('game.1')
succ += tg.showresult

test.finalize(succ) if ARGV.include?('--quick')

# test = BrowserTest.new
test.fold_begin('draw.1', 'draw test')
test.runlight
test.fold_end('draw.1')
succ += test.showresult

td = TestDraw.new
td.fold_begin('draw.2', 'draw test')
td.setplayersen(
  TestUsers::JOHN[:rname],
  TestUsers::JOHN[:remail],
  TestUsers::JOHN[:rpassword]
)
td.setplayergo(
  'admin',
  TestUsers::ADMININFO[:email],
  TestUsers::ADMININFO[:pwd]
)
td.setgame(test.gameurl)
td.run
td.fold_end('draw.2')
succ += tg.showresult

test.finalize(succ)
