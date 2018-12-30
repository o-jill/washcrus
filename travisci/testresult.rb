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
    if @driver.title == t
       @ok = @ok + 1
    else
       @ng = @ng + 1

       puts <<-EOE
         URL: #{@driver.current_url}
         "#{@driver.title}" is not #{t}.
         EOE
    end
  end

  # check if title is not t
  def checktitlenot(t)
    if @driver.title != t
       @ok = @ok + 1
    else
       @ng = @ng + 1

       puts <<-EOE
         URL: #{@driver.current_url}
         "#{@driver.title}" is not #{t}.
         EOE
    end
  end

  # check if current_url is url
  def checkurl(url)
    if @driver.current_url == url
      @ok = @ok + 1
    else
      @ng = @ng + 1

      puts <<-EOE
        URL: #{@driver.current_url}
        "#{@driver.current_url}" is not #{url}.
        EOE
    end
  end

  # check if current_url is url
  def checkplaintext(text)
    body = @driver.find_element(:tag_name, 'body').text
    if body == text
      @ok = @ok + 1
    else
      @ng = @ng + 1

      puts <<-EOE
        URL: #{@driver.current_url}
        "#{body}" is not #{text}.
        EOE
    end
  end

  # check if current_url is url
  def checkmatch(regexp)
    body = @driver.find_element(:tag_name, 'body').text
    if regexp =~ body
      @ok = @ok + 1
    else
      @ng = @ng + 1

      puts <<-EOE
        URL: #{@driver.current_url}
        "#{body}" does not match #{regexp}.
        EOE
    end
  end

end
