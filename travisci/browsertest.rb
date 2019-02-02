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
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?news'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?signup'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?login'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

element = driver.find_element(:name, 'siemail')
element.send_keys 'admin1@example.com'
element = driver.find_element(:name, 'sipassword')
element.send_keys 'admin'
element.submit
sleep 1

res.checkurl('http://localhost:3000/index.rb?logincheck')
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?lounge'
res.checktitle('WashCrus')
res.checkfooter

# puts driver.page_source
sleep 3
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?mypage'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?matchlist'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?searchform'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?adminmenu'
# puts driver.title
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?adminnews'
# puts driver.title
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?adminsettings'
# puts driver.title
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?adminsignature'
# puts driver.title
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?userlist'
# puts driver.title
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/chat.rb?lounge'
# puts driver.title
# res.checktitle('WashCrus')
# puts driver.page_source
res.checkmatch(/lounge chat/)
# res.checkfooter

driver.navigate.to 'http://localhost:3000/move.rb'
# puts driver.title
# puts driver.page_source
res.checkmatch(/illegal access/)

driver.navigate.to 'http://localhost:3000/getsfen.rb'
# puts driver.title
# res.checktitle('WashCrus')
res.checkmatch(/illegal access/)
# puts driver.page_source

# -- -- -- -- --  -- -- -- -- --
# -- -- -- -- LOGOUT -- -- -- --
# -- -- -- -- --  -- -- -- -- --

driver.navigate.to 'http://localhost:3000/index.rb?logout'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?lounge'
res.checktitle('WashCrus')
# puts driver.page_source
sleep 3
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?mypage'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?matchlist'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?searchform'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?adminmenu'
res.checktitlenot('WashCrus')
res.checkplaintext('ERR_NOT_ADMIN')
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

# -- -- -- -- --  -- -- -- -- --
# -- -- -- -- SIGNUP -- -- -- --
# -- -- -- -- --  -- -- -- -- --

driver.navigate.to 'http://localhost:3000/index.rb?signup'
# res.checktitle('WashCrus')
# puts driver.page_source
# res.checkfooter

element = driver.find_element(:name, 'rname')
element.send_keys 'john doe'
element = driver.find_element(:name, 'remail')
element.send_keys 'johndoe@example.com'
element = driver.find_element(:name, 'remail2')
element.send_keys 'johndoe@example.com'
element = driver.find_element(:name, 'rpassword')
element.send_keys 'john'
element = driver.find_element(:name, 'rpassword2')
element.send_keys 'john'
element = driver.find_element(:xpath, "//input[@value='Submit']")
element.click
sleep 1

res.checkurl('http://localhost:3000/index.rb?register')
res.checktitle('WashCrus')
# puts driver.page_source
res.checkmatch(/Registered successfully/)
res.checkfooter


driver.navigate.to 'http://localhost:1080/messages'
# puts driver.page_source
element = driver.find_element(:id, 'json')
# puts "json:#{element.text}"
json = JSON.parse(element.text)
res.checkmailsubject(json[0], 'Welcome to 洗足池!')

# 二重登録できないことの確認
driver.navigate.to 'http://localhost:3000/index.rb?signup'
# res.checktitle('WashCrus')
# puts driver.page_source
# res.checkfooter

element = driver.find_element(:name, 'rname')
element.send_keys 'john doe'
element = driver.find_element(:name, 'remail')
element.send_keys 'johndoe@example.com'
element = driver.find_element(:name, 'remail2')
element.send_keys 'johndoe@example.com'
element = driver.find_element(:name, 'rpassword')
element.send_keys 'john'
element = driver.find_element(:name, 'rpassword2')
element.send_keys 'john'
element = driver.find_element(:xpath, "//input[@value='Submit']")
element.click
sleep 1

res.checkurl('http://localhost:3000/index.rb?register')
res.checktitle('WashCrus')
# puts driver.page_source
res.checkmatch(/Unfortunately failed/)
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?login'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

element = driver.find_element(:name, 'siemail')
element.send_keys 'johndoe@example.com'
element = driver.find_element(:name, 'sipassword')
element.send_keys 'john'
element.submit
sleep 1

res.checkurl('http://localhost:3000/index.rb?logincheck')
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?lounge'
res.checktitle('WashCrus')
res.checkfooter

# puts driver.page_source
sleep 3
# puts driver.page_source

driver.navigate.to 'http://localhost:3000/index.rb?mypage'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?matchlist'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?searchform'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

driver.navigate.to 'http://localhost:3000/index.rb?adminmenu'
res.checktitlenot('WashCrus')
res.checkplaintext('ERR_NOT_ADMIN')
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

driver.navigate.to 'http://localhost:3000/index.rb?logout'
res.checktitle('WashCrus')
# puts driver.page_source
res.checkfooter

# 登録内容のチェックの確認
driver.navigate.to 'http://localhost:3000/index.rb?signup'
# res.checktitle('WashCrus')
# puts driver.page_source
# res.checkfooter

element = driver.find_element(:name, 'rname')
element.send_keys 'doe'
element = driver.find_element(:name, 'remail')
element.send_keys 'johndoe1_example.com'
element = driver.find_element(:name, 'remail2')
element.send_keys 'nanashi@example.com'
element = driver.find_element(:name, 'rpassword')
element.send_keys 'doe'
element = driver.find_element(:name, 'rpassword2')
element.send_keys 'john'
element = driver.find_element(:xpath, "//input[@value='Submit']")
element.click

element = driver.find_element(:id, 'errmsg')
res.matchproperty(/name is too short/, element.text)
res.matchproperty(/e-mail addresses are not same/, element.text)
res.matchproperty(/e-mail address is strange/, element.text)
res.matchproperty(/passwords are not same/, element.text)
res.matchproperty(/password is too short/, element.text)
# puts "errmsg:#{element.text}"

# テストを終了する（ブラウザを終了させる）
driver.quit

puts "ok:#{res.ok}, ng:#{res.ng}"
exit 1 if res.ng > 0
