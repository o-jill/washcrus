# for testing on a browser.
# frozen_string_literal: true

require 'selenium-webdriver'

require './travisci/testresult.rb'

# base for testing pages on a browser
class BrowserTestAbstract
  def initialize
    # Firefox用のドライバを使う
    @driver = Selenium::WebDriver.for :firefox
    @wait = Selenium::WebDriver::Wait.new(timeout: 10)
    @res = Result.new(driver)
  end

  attr_reader :driver, :res

  # ok, ngのカウントをゼロにする
  def reset
    res.reset
  end

  BASE_URL = 'http://localhost:3000/'

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

  # adminerrorになることの確認
  def adminerrcheck(pageurl)
    driver.navigate.to BASE_URL + pageurl
    res.checktitlenot('WashCrus')
    res.checkplaintext('ERR_NOT_ADMIN')
  end

  # @param this_will_fail true:no submitting because of err.
  #                       false:submit without error.
  def signupauser(signupinfo, this_will_fail = false)
    simplecheck 'index.rb?signup'
    signupinfo.each do |key, val|
      # puts "#{key.to_s} => #{val}"
      inputbox(:name, key.to_s, val)
    end
    clickbtn(:xpath, "//input[@value='Submit']")
    return if this_will_fail

    sleep 1
    simpleurlcheck('index.rb?register')
  end

  # 文字列入力
  def inputbox(key, name, txt)
    driver.find_element(key, name).send_keys(txt)
  end

  # ボタンをクリック
  def clickbtn(key, val)
    driver.find_element(key, val).click
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

  # テスト結果の表示
  #
  # @return ng数
  def showresult
    print res.ng.zero? ? "\e[32m" : "\e[31m"
    puts "ok:#{res.ok}, ng:#{res.ng}\e[0m"
    res.ng
  end

  def fold_begin(grp, msg)
    warn "travis_fold:start:#{grp}\033[33;1m#{msg}\033[0m"
  end

  def fold_end(grp)
    warn "\ntravis_fold:end:#{grp}\r"
  end

  # loginの確認
  def checklogin(email, pwd, ptn)
    simplecheck 'index.rb?login'
    inputbox(:name, 'siemail', email)
    elem = driver.find_element(:name, 'sipassword')
    elem.send_keys pwd
    elem.submit
    sleep 1.8
    simpleurlcheck('index.rb?logincheck')
    res.checkmatch(ptn)
  end

  # loginできることの確認
  def checkloginsucc(email, pwd)
    checklogin(email, pwd, /Logged in successfully/)
  end

  # loginできないことの確認
  def checkloginfail(email, pwd)
    checklogin(email, pwd, /Unfortunately failed/)
  end

  # adminerrorになることの確認
  def adminerrorcheckgroup
    adminerrcheck 'index.rb?adminmenu'
    adminerrcheck 'index.rb?adminnews'
    adminerrcheck 'index.rb?adminsettings'
    adminerrcheck 'index.rb?adminuserstg'
    adminerrcheck 'index.rb?adminsignature'
    adminerrcheck 'index.rb?userlist'
  end

  def lounge_file(msg)
    inputbox(:id, 'cmt', msg)
    clickbtn(:id, 'btn_f2l')
    sleep 8
    simpleurlcheck 'index.rb?lounge'
  end

  def lounge_cancel
    clickbtn(:id, 'btn_cfl')
    sleep 8
    simpleurlcheck 'index.rb?lounge'
  end

  def lounge_gengame
    clickbtn(:name, 'opponent')
    clickbtn(:id, 'btn_gen')
    sleep 8
    simpleurlcheck 'index.rb?gennewgame3'
  end

  def loungecheckfilecancel
    simplecheck 'index.rb?lounge'
    lounge_file('hello world!!')
    lounge_cancel
  end

  def lounge_say
    simplecheck 'index.rb?lounge'

    inputbox(:id, 'chatmsg', 'hello on lounge chat!!')
    chat = @driver.find_element(:id, 'chatlog').text
    clickbtn(:id, 'chatbtn')
    @wait.until do
      func = lambda do |txt|
        newchat = @driver.find_element(:id, 'chatlog').text
        newchat != txt
      end
      func.call(chat)
    end
    simplecheckmatch('chat.rb?lounge', /hello on lounge chat!!/)
  end

  GREETING = %w[よろしくお願いします。 おなしゃす。].freeze

  def gamechat(msg)
    inputbox(:id, 'chatmsg', msg)
    chat = @driver.find_element(:id, 'chatlog').text
    clickbtn(:id, 'chatbtn')
    @wait.until do
      func = lambda do |txt|
        newchat = @driver.find_element(:id, 'chatlog').text
        newchat != txt
      end
      func.call(chat)
    end
    res.checkchat(/#{msg}/)
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
