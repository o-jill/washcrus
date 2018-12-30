# require 'unindent'

#
# testresult
class Result
  def initialize(driver)
    @ok = 0
    @ng = 0
    @driver = driver
  end

  attr_reader :ok, :ng

  # check if title is t
  def checktitle(t)
    return @ok += 1 if @driver.title == t

    @ng += 1

    puts <<-ERRMSG
      URL: #{@driver.current_url}
      "#{@driver.title}" is not #{t}.
      ERRMSG
  end

  # check if title is not t
  def checktitlenot(t)
    return @ok += 1 if @driver.title != t

    @ng += 1

    puts <<-ERRMSG
      URL: #{@driver.current_url}
      "#{@driver.title}" is not #{t}.
      ERRMSG
  end

  # check if current_url is url
  def checkurl(url)
    return @ok += 1 if @driver.current_url == url

    @ng += 1

    puts <<-ERRMSG
      URL: #{@driver.current_url}
      "#{@driver.current_url}" is not #{url}.
      ERRMSG
  end

  # check if body is t
  def checkplaintext(t)
    body = @driver.find_element(:tag_name, 'body').text

    return @ok += 1 if body == t

    @ng += 1

    puts <<-ERRMSG
      URL: #{@driver.current_url}
      "#{body}" is not #{t}.
      ERRMSG
  end

  # check if regexp matches content
  def checkmatch(regexp)
    body = @driver.find_element(:tag_name, 'body').text

    return @ok += 1 if regexp =~ body

    @ng += 1

    puts <<-ERRMSG
      URL: #{@driver.current_url}
      "#{body}" does not match #{regexp}.
      ERRMSG
  end

  # check footer
  def checkfooter(regexp)
    ft = @driver.find_element(:tag_name, 'footer')
    unless ft
      puts <<-ERRMSG
        URL: #{@driver.current_url}
        does not have any footer elements.
        ERRMSG
      return @ng += 1
    end

    return @ok += 1 if regexp =~ ft

    @ng += 1

    puts <<-ERRMSG
      URL: #{@driver.current_url}
      "#{ft}" does not match #{regexp}.
      ERRMSG
  end
end
