# for testing on a browser.

require 'selenium-webdriver'

require './travisci/browsertestabs.rb'
require './travisci/testresult.rb'
require './travisci/testgame.rb'

# test pages on a browser
class BrowserTest < BrowserTestAbstract
  def initialize
    super
  end

  attr_reader :gameurl

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
    adminerrcheck 'index.rb?adminuserstg'
    adminerrcheck 'index.rb?adminsignature'
    adminerrcheck 'index.rb?userlist'
  end

  def lounge_file(msg)
    element = driver.find_element(:id, 'cmt')
    element.send_keys(msg)
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

    elem = driver.find_element(:id, 'chatmsg')
    elem.send_keys 'hello on lounge chat!!'
    elem = driver.find_element(:id, 'chatbtn')
    elem.click
    sleep 1
    simplecheckmatch('chat.rb?lounge', /hello on lounge chat!!/)
  end

  ADMININFO = {
    email: 'admin1@example.com',
    pwd: 'admin'
  }.freeze

  def adminaccess
    checklogin(ADMININFO[:email], ADMININFO[:pwd])

    simplecheckgroup

    loungecheckfilecancel
    lounge_file('hello john!!')

    simpleadmincheckgroup

    simplecheckmatch('chat.rb?lounge', /lounge chat/)

    lounge_say

    simplecheck 'index.rb?logout'

    simplecheckgroup

    simplecheck 'index.rb?lounge'
    # puts driver.page_source
    sleep 3
    # puts driver.page_source

    adminerrorcheckgroup
  end

  def adminaccesslight
    checklogin(ADMININFO[:email], ADMININFO[:pwd])

    loungecheckfilecancel
    lounge_file('hello john!!')

    simplecheckmatch('chat.rb?lounge', /lounge chat/)

    lounge_say

    simplecheck 'index.rb?logout'
  end

  SIGNUPINFOJOHN = {
    rname: 'john doe',
    remail: 'johndoe@example.com',
    remail2: 'johndoe@example.com',
    rpassword: 'john',
    rpassword2: 'john'
  }.freeze

  NEWJOHNINFO = { email: 'johndoe1@example.com', pwd: 'doee' }.freeze

  def updatepwd_mypage(opwd, npwd1, npwd2)
    simplecheck 'index.rb?mypage'
    clickbtn(:id, 'navbtn_pwd')
    elem = driver.find_element(:id, 'sipassword')
    elem.send_keys opwd
    elem = driver.find_element(:id, 'rnewpassword')
    elem.send_keys npwd1
    elem = driver.find_element(:id, 'rnewpassword2')
    elem.send_keys npwd2
    elem.submit
    sleep 2
    simpleurlcheck('index.rb?update_password')
  end

  def chkupdatepwd_succ
    updatepwd_mypage(
      SIGNUPINFOJOHN[:rpassword],
      NEWJOHNINFO[:pwd],
      NEWJOHNINFO[:pwd]
    )
    res.checkmatch(/Your password was updated/)

    matchmailsbjlast(/Updating password for/)

    simplecheck 'index.rb?logout'

    checklogin(SIGNUPINFOJOHN[:remail], NEWJOHNINFO[:pwd])
  end

  def chkupdatepwd_fail
    updatepwd_mypage('doeeee', 'bbbb', 'bbbb')
    res.checkmatch(/old password is not correct!/)

    updatepwd_mypage(NEWJOHNINFO[:pwd], 'jones', 'john')
    simpleurlcheck('index.rb?update_password')
    res.checkmatch(/new passwords are not same/)
  end

  def checkupdatepwd
    chkupdatepwd_succ
    chkupdatepwd_fail
  end

  def updateemail_mypage(nemail1, nemail2)
    simplecheck 'index.rb?mypage'
    clickbtn(:id, 'navbtn_email')
    elem = driver.find_element(:id, 'rnewemail')
    elem.send_keys nemail1
    elem = driver.find_element(:id, 'rnewemail2')
    elem.send_keys nemail2
    elem.submit
    sleep 2
    simpleurlcheck('index.rb?update_email')
  end

  def checkupdateemail_succ
    updateemail_mypage(NEWJOHNINFO[:email], NEWJOHNINFO[:email])
    res.checkmatch(/Your e-mail address was updated/)

    matchmailsbjlast(/Updating e-mail address for/)

    simplecheck 'index.rb?logout'

    checklogin(NEWJOHNINFO[:email], NEWJOHNINFO[:pwd])
  end

  def checkupdateemail_fail
    updateemail_mypage(SIGNUPINFOJOHN[:remail], 'joooooohn@example.com')
    res.checkmatch(/e-mail addresses are not same/)

    updateemail_mypage('johndoe1_example.com', 'johndoe1_example.com')
    res.checkmatch(/the e-mail address does not have "@"/)

    updateemail_mypage(ADMININFO[:email], ADMININFO[:email])
    res.checkmatch(/e-mail address is already registered/)
  end

  def checkupdateemail
    checkupdateemail_succ
    checkupdateemail_fail
  end

  def restorepwdandmail
    updatepwd_mypage(
      NEWJOHNINFO[:pwd],
      SIGNUPINFOJOHN[:rpassword],
      SIGNUPINFOJOHN[:rpassword]
    )
    updateemail_mypage(SIGNUPINFOJOHN[:remail], SIGNUPINFOJOHN[:remail])
  end

  def newuserjohn_loungegame
    simplecheck 'index.rb?lounge'
    lounge_gengame
    elem = driver.find_element(:tag_name, 'big')
    elem.click
    sleep 2

    @gameurl = driver.current_url
    idx = @gameurl.rindex('/') + 1
    @gameurl = @gameurl[idx..-1]
    # elem = driver.find_element(:id, 'myteban')
    # @johnteban = (elem.attribute('value') == 'b')

    # puts "game URL: #{@gameurl}\njohn is first?: #{@johnteban}"
    matchmailsbjlast(/a game is ready!! \(.+ vs .+\)/)
  end

  def newuserjohn
    signupauser(SIGNUPINFOJOHN)
    res.checkmatch(/Registered successfully/)

    matchmailsbjlast(/Welcome to 洗足池!/)

    checklogin('johndoe@example.com', 'john')

    simplecheckgroup

    checkupdatepwd

    checkupdateemail

    newuserjohn_loungegame

    adminerrorcheckgroup

    restorepwdandmail

    simplecheck 'index.rb?logout'
  end

  def newuserjohnlight
    signupauser(SIGNUPINFOJOHN)
    res.checkmatch(/Registered successfully/)

    matchmailsbjlast(/Welcome to 洗足池!/)

    checklogin('johndoe@example.com', 'john')

    newuserjohn_loungegame

    simplecheck 'index.rb?logout'
  end

  # 二重登録できないことの確認
  def newuserjohn2nd
    signupauser(SIGNUPINFOJOHN)
    res.checkmatch(/Unfortunately failed/)
  end

  # 登録内容のチェックの確認
  def signuperrmsg
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

  def runlight
    adminaccesslight

    newuserjohnlight

    # テストを終了する（ブラウザを終了させる）
    driver.quit
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
end

test = BrowserTest.new
test.fold_begin('pages.1', 'pages tests')
ARGV.include?('--quick') ? test.runlight : test.run
test.fold_end('pages.1')
succ = test.showresult

tg = TestGame.new
tg.fold_begin('game.1', 'game test')
tg.setplayer1(
  BrowserTest::SIGNUPINFOJOHN[:rname],
  BrowserTest::SIGNUPINFOJOHN[:remail],
  BrowserTest::SIGNUPINFOJOHN[:rpassword]
)
tg.setplayer2(
  'admin',
  BrowserTest::ADMININFO[:email],
  BrowserTest::ADMININFO[:pwd]
)
tg.setgame(test.gameurl)
KIFULIST = [
  'travisci/testmove.jkf',
  'travisci/fuji_system.jkf',
  'travisci/fuji_debut.jkf',
  'travisci/koyan_tadao.jkf',
  'travisci/sennichite.jkf',
  'travisci/kingtaking.jkf'
].freeze
kifindexarr = ARGV.grep(/-N\d+/)
kifindex = kifindexarr.size.zero? ? -1 : kifindexarr[0].slice(2, 10).to_i
jkfpath = kifindex < 0 ? KIFULIST.sample : KIFULIST[kifindex]
puts "#{jkfpath}, #{ARGV} #{kifindexarr} #{kifindex}"
tg.read(jkfpath)
tg.run
tg.fold_end('game.1')
succ &= tg.showresult
exit 1 unless succ

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
