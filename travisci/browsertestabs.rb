# for testing on a browser.

require 'selenium-webdriver'

require './travisci/testresult.rb'

# base for testing pages on a browser
class BrowserTestAbstract
  def initialize
    # Firefox用のドライバを使う
    @driver = Selenium::WebDriver.for :firefox
    @res = Result.new(driver)
  end

  attr_reader :driver, :res

  BASE_URL = 'http://localhost:3000/'.freeze

  def simplecheck(pageurl)
    driver.navigate.to BASE_URL + pageurl
    res.checktitle
    # puts driver.page_source
    res.checkfooter
  end

  def simpleurlcheck(url)
    res.checkurl(BASE_URL + url)
    res.checktitle
    # puts driver.page_source
    res.checkfooter
  end

  def simplecheckmatch(url, rex)
    driver.navigate.to BASE_URL + url
    # puts driver.title
    # puts driver.page_source
    res.checkmatch(rex)
  end

  # adminerrorになることの確認
  def simpleadmincheckgroup
    simplecheck 'index.rb?adminmenu'
    simplecheck 'index.rb?adminnews'
    simplecheck 'index.rb?adminsettings'
    simplecheck 'index.rb?adminsignature'
    simplecheck 'index.rb?userlist'
  end

  def simplecheckgroup
    simplecheck 'index.rb?mypage'
    simplecheck 'index.rb?matchlist'
    simplecheck 'index.rb?searchform'
  end

  def simpleaccess
    simplecheck 'index.rb'
    simplecheck 'index.rb?news'
    # simplecheck 'index.rb?signup'

    simplecheckmatch('move.rb', /illegal access/)

    simplecheckmatch('getsfen.rb', /illegal access/)
  end

  # ボタンをクリック
  def clickbtn(key, val)
    elem = driver.find_element(key, val)
    elem.click
  end

  def getmailjson
    driver.navigate.to 'http://localhost:1080/messages'
    # puts driver.page_source
    element = driver.find_element(:id, 'json')
    # puts "json:#{element.text}"
    JSON.parse(element.text)
  end

  def matchmailsbjlast(rex)
    json = getmailjson
    res.matchmailsubject(json.last, rex)
  end

  def showresult
    print res.ng.zero? ? "\e[32m" : "\e[31m"
    puts "ok:#{res.ok}, ng:#{res.ng}\e[0m"
    res.ng.zero?
  end

  def fold_begin(grp, msg)
    STDERR.puts "travis_fold:start:#{grp}\033[33;1m#{msg}\033[0m"
  end

  def fold_end(grp)
    STDERR.puts "\ntravis_fold:end:#{grp}\r"
  end

  # loginできることの確認
  def checklogin(email, pwd)
    simplecheck 'index.rb?login'
    driver.find_element(:name, 'siemail').send_keys(email)
    elem = driver.find_element(:name, 'sipassword')
    elem.send_keys pwd
    elem.submit
    sleep 1.8
    simpleurlcheck('index.rb?logincheck')
    res.checkmatch(/Logged in successfully/)
  end
end

# memo

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
