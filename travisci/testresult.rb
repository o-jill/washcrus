# require 'unindent'

#
# testresult
class Result
  def initialize(driver)
    @ok = 0
    @ng = 0
    @driver = driver
    @setction = 'null'
  end

  attr_reader :ok, :ng

  def startsection(a)
    @section = a
  end

  def checkproperty(a, b)
    # general function to check some property
    return @ok += 1 if a == b

    @ng += 1

    puts <<-ERRMSG
      section:#{@section}
      URL: #{@driver.current_url}
      "#{a}" is not #{b}.
    ERRMSG
  end

  # general function to check some property matches
  def matchproperty(rex, b)
    return @ok += 1 if rex =~ b

    @ng += 1

    puts <<-ERRMSG
      section:#{@section}
      URL: #{@driver.current_url}
      "#{b}" does not match #{rex}.
    ERRMSG
  end

  # check if title is t
  def checktitle(t = 'WashCrus')
    checkproperty(@driver.title, t)
  end

  # check if title is not t
  def checktitlenot(t = 'WashCrus')
    return @ok += 1 if @driver.title != t

    @ng += 1

    puts <<-ERRMSG
      section:#{@section}
      URL: #{@driver.current_url}
      "#{@driver.title}" should not be #{t}.
    ERRMSG
  end

  # check if current_url is url
  def checkurl(url)
    checkproperty(@driver.current_url, url)
  end

  # check if body is t
  def checkplaintext(t)
    body = @driver.find_element(:tag_name, 'body')
    checkproperty(body.text, t)
  end

  # check if regexp matches content
  def checkmatch(regexp)
    body = @driver.find_element(:tag_name, 'body')
    matchproperty(regexp, body.text)
  end

  # check footer
  def checkfooter(regexp = /ぢるっち/)
    ft = @driver.find_element(:tag_name, 'footer')
    unless ft
      puts <<-ERRMSG
        section:#{@section}
        URL: #{@driver.current_url}
        does not have any footer elements.
      ERRMSG
      return @ng += 1
    end
    matchproperty(regexp, ft.text)
  end

  # check subject in a mail
  def checkmailsubject(json, sbj)
    unless json
      puts <<-ERRMSG
        section:#{@section}
        URL: #{@driver.current_url}
        JSON(mail?) is empty.
      ERRMSG
      return @ng += 1
    end

    return @ok += 1 if json['subject'] == sbj

    @ng += 1

    puts <<-ERRMSG
      section:#{@section}
      URL: #{@driver.current_url}
      "#{json['subject']}" is not "#{sbj}".
    ERRMSG
  end
end
