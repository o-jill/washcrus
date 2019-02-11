# for testing on a browser.

require 'selenium-webdriver'

require './travisci/testresult.rb'

# test pages on a browser
class BrowserTest
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

  # loginできることの確認
  def checklogin(email, pwd)
    simplecheck 'index.rb?login'
    driver.find_element(:name, 'siemail').send_keys(email)
    elem = driver.find_element(:name, 'sipassword')
    elem.send_keys pwd
    elem.submit
    sleep 1
    simpleurlcheck('index.rb?logincheck')
  end

  # ボタンをクリック
  def clickbtn(key, val)
    elem = driver.find_element(key, val)
    elem.click
  end

  def signupauser(signupinfo, this_will_fail = false)
    simplecheck 'index.rb?signup'
    signupinfo.each do |key, val|
      # puts "#{key.to_s} => #{val}"
      element = driver.find_element(:name, key.to_s)
      element.send_keys(val)
    end
    clickbtn(:xpath, "//input[@value='Submit']")
    return if this_will_fail
    sleep 1
    simpleurlcheck('index.rb?register')
  end

  # adminerrorになることの確認
  def adminerrcheck(pageurl)
    driver.navigate.to BASE_URL + pageurl
    res.checktitlenot('WashCrus')
    res.checkplaintext('ERR_NOT_ADMIN')
  end

  # adminerrorになることの確認
  def adminerrorcheckgroup
    adminerrcheck 'index.rb?adminmenu'
    adminerrcheck 'index.rb?adminnews'
    adminerrcheck 'index.rb?adminsettings'
    adminerrcheck 'index.rb?adminsignature'
    adminerrcheck 'index.rb?userlist'
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
    res.startsection('simpleaccess')
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

    simplecheck 'index.rb'
    simplecheck 'index.rb?news'
    simplecheck 'index.rb?signup'

    driver.navigate.to BASE_URL + 'move.rb'
    # puts driver.title
    # puts driver.page_source
    res.checkmatch(/illegal access/)

    driver.navigate.to BASE_URL + 'getsfen.rb'
    # puts driver.title
    # res.checktitle
    res.checkmatch(/illegal access/)
    # puts driver.page_source
  end

  def adminaccess
    res.startsection('adminaccess')

    checklogin('admin1@example.com', 'admin')

    res.startsection('adminaccess_simplecheck')
    simplecheckgroup

    simplecheck 'index.rb?lounge'
    element = driver.find_element(:id, 'cmt')
    element.send_keys('hello world!!')
    clickbtn(:id, 'btn_f2l')
    sleep 8
    simpleurlcheck 'index.rb?lounge'
    clickbtn(:id, 'btn_cfl')
    sleep 8
    simpleurlcheck 'index.rb?lounge'
    element = driver.find_element(:id, 'cmt')
    element.send_keys('hello world!!')
    clickbtn(:id, 'btn_f2l')
    element.click
    # puts driver.page_source
    sleep 3
    # puts driver.page_source

    simpleadmincheckgroup

    driver.navigate.to BASE_URL + 'chat.rb?lounge'
    # puts driver.title
    # res.checktitle
    # puts driver.page_source
    res.checkmatch(/lounge chat/)
    # res.checkfooter

    simplecheck 'index.rb?logout'

    simplecheckgroup

    simplecheck 'index.rb?lounge'
    # puts driver.page_source
    sleep 3
    # puts driver.page_source

    adminerrorcheckgroup
  end

  SIGNUPINFOJOHN = {
    rname: 'john doe',
    remail: 'johndoe@example.com',
    remail2: 'johndoe@example.com',
    rpassword: 'john',
    rpassword2: 'john'
  }.freeze

  def getmailjson
    driver.navigate.to 'http://localhost:1080/messages'
    # puts driver.page_source
    element = driver.find_element(:id, 'json')
    # puts "json:#{element.text}"
    JSON.parse(element.text)
  end

  def newuserjohn
    res.startsection('newuserjohn')
    signupauser(SIGNUPINFOJOHN)
    res.checkmatch(/Registered successfully/)
    json = getmailjson
    res.checkmailsubject(json.last, 'Welcome to 洗足池!')

    checklogin('johndoe@example.com', 'john')

    simplecheckgroup

    simplecheck 'index.rb?lounge'
    # puts driver.page_source
    sleep 3
    # puts driver.page_source
    simplecheck 'index.rb?lounge'
    clickbtn(:name, 'opponent')
    clickbtn(:id, 'btn_gen')
    sleep 8
    simpleurlcheck 'index.rb?gennewgame3'

    json = getmailjson
    res.matchmailsubject(json.last, /a game is ready!! \(.+ vs .+\)/)

    adminerrorcheckgroup

    simplecheck 'index.rb?logout'
  end

  # 二重登録できないことの確認
  def newuserjohn2nd
    res.startsection('newuserjohn2nd')
    signupauser(SIGNUPINFOJOHN)
    res.checkmatch(/Unfortunately failed/)
  end

  # 登録内容のチェックの確認
  def signuperrmsg
    res.startsection('signuperrmsg')
    signupauser(
      {
        rname: 'doe',
        remail: 'johndoe1_example.com',
        remail2: 'nanashi@example.com',
        rpassword: 'doe',
        rpassword2: 'john'
      }, true
    )

    element = driver.find_element(:id, 'errmsg')
    # puts "errmsg:#{element.text}"
    etext = element.text
    [
      /name is too short/,
      /e-mail addresses are not same/,
      /e-mail address is strange/,
      /passwords are not same/,
      /password is too short/
    ].each do |errmsg|
      res.matchproperty(errmsg, etext)
    end
  end

  def run
    simpleaccess

    adminaccess

    newuserjohn

    newuserjohn2nd

    signuperrmsg

    # テストを終了する（ブラウザを終了させる）
    driver.quit
  end

  def showresult
    print res.ng.zero? ? "\e[32m" : "\e[31m"
    puts "ok:#{res.ok}, ng:#{res.ng}\e[0m"
    res.ng.zero?
  end
end

test = BrowserTest.new
test.run
exit 1 unless test.showresult
