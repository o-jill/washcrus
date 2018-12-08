# for testing on a browser.

require 'selenium-webdriver'

# Firefox用のドライバを使う
driver = Selenium::WebDriver.for :firefox

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
puts driver.title

driver.navigate.to 'http://localhost:3000/index.rb?news'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?signup'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?login'
puts driver.title
puts driver.page_source

element = driver.find_element(:name, 'siemail')
element.send_keys 'admin1@example.com'
element = driver.find_element(:name, 'sipassword')
element.send_keys 'admin'
element.submit
sleep 1

puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?lounge'
puts driver.title
puts driver.page_source
sleep 3
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?mypage'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?matchlist'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?searchform'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminmenu'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminnews'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminsettings'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminsignature'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?userlist'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/chat.rb?lounge'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/move.rb'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/getsfen.rb'
puts driver.title
puts driver.page_source

# -- -- -- -- --  -- -- -- -- --
# -- -- -- -- LOGOUT -- -- -- --
# -- -- -- -- --  -- -- -- -- --

driver.navigate.to 'http://localhost:3000/index.rb?logout'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?lounge'
puts driver.title
puts driver.page_source
sleep 3
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?mypage'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?matchlist'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?searchform'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminmenu'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminnews'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminsettings'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?adminsignature'
puts driver.title
puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?userlist'
puts driver.title
puts driver.page_source

# テストを終了する（ブラウザを終了させる）
driver.quit
