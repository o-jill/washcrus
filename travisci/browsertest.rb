# for testing on a browser.
# frozen_string_literal: true

require 'selenium-webdriver'

require './travisci/browsertestabs.rb'
require './travisci/testresult.rb'
require './travisci/testusers.rb'
# require './travisci/testgame.rb'
# require './travisci/testdraw.rb'

# test pages on a browser
class BrowserTest < BrowserTestAbstract
  def initialize
    super
  end

  attr_reader :gameurl

  # # @param this_will_fail true:no submitting because of err.
  # #                       false:submit without error.
  # def signupauser(signupinfo, this_will_fail = false)
  #   simplecheck 'index.rb?signup'
  #   signupinfo.each do |key, val|
  #     # puts "#{key.to_s} => #{val}"
  #     element = driver.find_element(:name, key.to_s)
  #     element.send_keys(val)
  #   end
  #   clickbtn(:xpath, "//input[@value='Submit']")
  #   return if this_will_fail
  #   sleep 1
  #   simpleurlcheck('index.rb?register')
  # end

  def adminaccess
    checklogin(TestUsers::ADMININFO[:email], TestUsers::ADMININFO[:pwd])

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
    checklogin(TestUsers::ADMININFO[:email], TestUsers::ADMININFO[:pwd])

    loungecheckfilecancel
    lounge_file('hello john!!')

    simplecheckmatch('chat.rb?lounge', /lounge chat/)

    lounge_say

    simplecheck 'index.rb?logout'
  end

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
    newpwd = TestUsers::NEWJOHNINFO[:pwd]
    updatepwd_mypage(TestUsers::JOHN[:rpassword], newpwd, newpwd)
    res.checkmatch(/Your password was updated/)

    matchmailsbjlast(/Updating password for/)

    simplecheck 'index.rb?logout'

    checklogin(TestUsers::JOHN[:remail], newpwd)
  end

  def chkupdatepwd_fail
    updatepwd_mypage('doeeee', 'bbbb', 'bbbb')
    res.checkmatch(/old password is not correct!/)

    updatepwd_mypage(TestUsers::NEWJOHNINFO[:pwd], 'jones', 'john')
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
    email = TestUsers::NEWJOHNINFO[:email]
    updateemail_mypage(email, email)
    res.checkmatch(/Your e-mail address was updated/)

    matchmailsbjlast(/Updating e-mail address for/)

    simplecheck 'index.rb?logout'

    checklogin(email, TestUsers::NEWJOHNINFO[:pwd])
  end

  def checkupdateemail_fail
    updateemail_mypage(TestUsers::JOHN[:remail], 'joooooohn@example.com')
    res.checkmatch(/e-mail addresses are not same/)

    updateemail_mypage('johndoe1_example.com', 'johndoe1_example.com')
    res.checkmatch(/the e-mail address does not have "@"/)

    updateemail_mypage(TestUsers::ADMININFO[:email],
                       TestUsers::ADMININFO[:email])
    res.checkmatch(/e-mail address is already registered/)
  end

  def checkupdateemail
    checkupdateemail_succ
    checkupdateemail_fail
  end

  def restorepwdandmail
    updatepwd_mypage(TestUsers::NEWJOHNINFO[:pwd],
                     TestUsers::JOHN[:rpassword], TestUsers::JOHN[:rpassword])
    updateemail_mypage(TestUsers::JOHN[:remail], TestUsers::JOHN[:remail])
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

  def tryunsubscribe(email)
    simplecheck 'index.rb?mypage'
    sleep 0.5
    clickbtn(:id, 'navbtn_unsubscribe')
    elem = driver.find_element(:id, 'unsubscribe')
    elem.send_keys email
    elem.submit
    sleep 1
    # simpleurlcheck('index.rb?unsubscribe')
  end

  def unsubscribecheck(eml, ptn)
    tryunsubscribe(eml)
    simpleurlcheck('index.rb?unsubscribe')
    res.checkmatch(ptn)
  end

  def unsubscribefailures
    # click w/o mail
    tryunsubscribe('')
    # click w/ incorrect
    unsubscribecheck('in@correct.address',
                     /Please finish all your games at first./)
    # res.checkmatch(/e-mail address is not correct!/)

    # click w/ correct before finish
    unsubscribecheck(TestUsers::JOHN[:remail],
                     /Please finish all your games at first./)
  end

  def unsubscribejohn
    email = TestUsers::JOHN[:remail]
    checklogin(email, TestUsers::JOHN[:rpassword])
    # click w/o mail
    tryunsubscribe('')
    # click w/ incorrect
    unsubscribecheck('in@correct.address', /e-mail address is not correct!/)

    # click w/ correct
    unsubscribecheck(email, /You successfully unsubscribed./)
    matchmailsbjlast(/Unsubscribe/)

    # fail login
    checkloginfail(email, TestUsers::JOHN[:rpassword])
  end

  def newuserjohn
    signupauser(TestUsers::JOHN)
    res.checkmatch(/Registered successfully/)

    matchmailsbjlast(/Welcome to 洗足池!/)

    checklogin('johndoe@example.com', 'john')

    simplecheckgroup

    checkupdatepwd

    checkupdateemail

    newuserjohn_loungegame

    adminerrorcheckgroup

    restorepwdandmail

    unsubscribefailures

    simplecheck 'index.rb?logout'
  end

  def newuserjohnlight
    checklogin('johndoe@example.com', 'john')

    newuserjohn_loungegame

    simplecheck 'index.rb?logout'
  end

  # 二重登録できないことの確認
  def newuserjohn2nd
    signupauser(TestUsers::JOHN)
    res.checkmatch(/Unfortunately failed/)
  end

  def signuperr(user, msgs)
    signupauser(user, true)

    element = driver.find_element(:id, 'errmsg')
    # puts "errmsg:#{element.text}"
    etext = element.text
    msgs.each do |errmsg|
      res.matchproperty(errmsg, etext)
    end
    sleep 3
  end

  def strangeusers
    signuperr(TestUsers::STRANGEJOHN, [/"name" cannot contain URL/])
  end

  # 登録内容のチェックの確認
  def signuperrmsg
    signuperr(
      TestUsers::JOHNMANYMISS,
      [
        /name is too short/,
        /e-mail addresses are not same/,
        /e-mail address is strange/,
        /passwords are not same/,
        /password is too short/
      ]
    )
  end

  def runlight
    puts 'adminaccesslight'
    adminaccesslight

    puts 'newuserjohnlight'
    newuserjohnlight

    # テストを終了する（ブラウザを終了させる）
    # driver.quit
  end

  TESTTBL = %w[simpleaccess adminaccess newuserjohn newuserjohn2nd signuperrmsg
               strangeusers].freeze

  def run
    TESTTBL.each do |test|
      unless methods(true).include?(test.to_sym)
        puts "unknown test name '#{test}'..."
        exit(-9999)
      end
      puts test
      method(test.to_sym).call
    end

    # テストを終了する（ブラウザを終了させる）
    # driver.quit
  end

  def finalize(ret)
    # テストを終了する（ブラウザを終了させる）
    driver.quit
    exit(ret)
  end
end
