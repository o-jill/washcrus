# frozen_string_literal: true

# lock() module

# ファイルlock用
module MyLock
  # usage:
  # lock('aaaa.lock') do
  #   do_something
  # end
  def lock(lockfn)
    Timeout.timeout(10) do
      File.open(lockfn, 'w') do |file|
        begin
          file.flock(File::LOCK_EX)
          yield
        ensure
          file.flock(File::LOCK_UN)
        end
      end
    end
  rescue Timeout::Error
    raise AccessDenied.new("lock timeout - #{lockfn}.")
  end
end
