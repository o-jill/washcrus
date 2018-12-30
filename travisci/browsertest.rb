# for testing on a browser.

require 'selenium-webdriver'

require './travisci/testresult.rb'


# Firefox用のドライバを使う
driver = Selenium::WebDriver.for :firefox

res = Result.new(driver)

# Googleにアクセス
# driver.navigate.to "http://google.com"
# driver.navigate.to "http://localhost/"

# `q`というnameを持つ要素を取得
# element = driver.find_element(:name, 'q')

# `Hello WebDriver!`という文字を、上記で取得したinput要素に入力
# element.send_keys "Hello WebDriver!"

# submitを実行する（つまり検索する）
# element.submit

# 表示されたページのタイトルをコンソールに出力
# puts driver.title

driver.navigate.to 'http://localhost:3000/index.rb'
# puts driver.title
res.checktitle('WashCrus')

driver.navigate.to 'http://localhost:3000/index.rb?news'
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?signup'
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?login'
res.checktitle('WashCrus')
# puts driver.page_source

element = driver.find_element(:name, 'siemail')
element.send_keys 'admin1@example.com'
element = driver.find_element(:name, 'sipassword')
element.send_keys 'admin'
element.submit
sleep 1

res.checkurl('http://localhost:3000/index.rb?logincheck')
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?lounge'
res.checktitle('WashCrus')

# puts driver.page_source
sleep 3
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?mypage'
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?matchlist'
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?searchform'
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminmenu'
# puts driver.title
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminnews'
# puts driver.title
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminsettings'
# puts driver.title
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminsignature'
# puts driver.title
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?userlist'
# puts driver.title
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/chat.rb?lounge'
# puts driver.title
# res.checktitle('WashCrus')
# puts driver.page_source
res.checkmatch(%r[lounge chat])

driver.navigate.to 'http://localhost:3000/move.rb'
# puts driver.title
# puts driver.page_source
res.checkmatch(%r[illegal access])

driver.navigate.to 'http://localhost:3000/getsfen.rb'
# puts driver.title
# res.checktitle('WashCrus')
res.checkmatch(%r[illegal access])
# puts driver.page_source

# -- -- -- -- --  -- -- -- -- --
# -- -- -- -- LOGOUT -- -- -- --
# -- -- -- -- --  -- -- -- -- --

driver.navigate.to 'http://localhost:3000/index.rb?logout'
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?lounge'
res.checktitle('WashCrus')
# puts driver.page_source
sleep 3
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?mypage'
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?matchlist'
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?searchform'
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminmenu'
res.checktitle('WashCrus')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminnews'
res.checktitlenot('WashCrus')
res.checkplaintext('ERR_NOT_ADMIN')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminsettings'
# puts driver.title
res.checktitlenot('WashCrus')
res.checkplaintext('ERR_NOT_ADMIN')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminsignature'
res.checktitlenot('WashCrus')
res.checkplaintext('ERR_NOT_ADMIN')
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?userlist'
res.checktitlenot('WashCrus')
# e = driver.find_element(:tag_name, 'body')
# puts "body:#{e.text}"
res.checkplaintext('ERR_NOT_ADMIN')
# puts driver.page_source

# テストを終了する（ブラウザを終了させる）
driver.quit

puts "ok:#{res.ok}, ng:#{res.ng}"
exit 1 if res.ng > 0
