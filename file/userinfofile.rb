# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'
require 'timeout'
require 'unindent'
require './file/pathlist.rb'
require './file/userinfofilecontent.rb'
require './util/myerror.rb'

#
# ユーザー情報DB管理クラス
#
# @note draw非対応
#
class UserInfoFile
  # 初期化
  def initialize
    @fname = PathList::USERINFOFILE
    @content = UserInfoFileContent.new
  end

  # ファイル名
  attr_reader :fname

  # 内容
  attr_reader :content

  # usage:
  # lock do
  #   do_something
  # end
  def lock(*)
    Timeout.timeout(10) do
      File.open(PathList::USERINFOLOCKFILE, 'w') do |file|
        begin
          file.flock(File::LOCK_EX)
          yield
        ensure
          file.flock(File::LOCK_UN)
        end
      end
    end
  rescue Timeout::Error
    raise AccessDenied.new('timeout')
  end

  # read data from a file
  def read
    File.open(@fname, 'r:utf-8') do |file|
      file.flock File::LOCK_EX

      file.each_line do |line|
        @content.read_elements(line)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "#{er} in read"
  rescue IOError => er
    puts "#{er} in read"
  end

  # put header part of the file.
  #
  # [file] File object
  def self.put_header(file)
    file.puts "# user information #{Time.now}" \
              '# id, name, password, e-mail(encrypted), swn, sls, gwn, gls'
  end

  # write data to a file.
  # note: use with lock(*)
  def write
    File.open(@fname, 'w') do |file|
      file.flock File::LOCK_EX

      UserInfoFile.put_header(file)

      @content.names.each_key do |id|
        file.puts @content.build_line(id)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "#{er} in write"
  rescue IOError => er
    puts "#{er} in write"
  end

  # append a set of data to a db file.
  #
  # [id] user's ID to append
  def append(id)
    File.open(@fname, 'a') do |file|
      file.flock File::LOCK_EX

      file.puts @content.build_line(id)
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  rescue IOError => er
    puts "class=[#{er.class}] message=[#{er.message}] in write"
  end

  # add user information, generate id and append to file.
  # [name]     user name.
  # [password] AES256CBC encrypted password.
  # [email]    e-mail address.
  #
  # return added user's ID
  def add(name, password, email)
    id = nil

    return if @content.exist_name(name)
    return if @content.exist_email(email)

    lock do
      read
      id = @content.add(name, password, email)
      append(id)
    end
    id
  end

  # 勝敗の記入(勝った方と負けた方に１加算)
  #
  # @param gwin 後手勝ちの時true
  # @param idb  先手のID
  # @param idw  後手のID
  #
  # @note draw非対応
  def give_win_lose(gwin, idb, idw)
    lock do
      read
      @content.give_win_lose(gwin, idb, idw)
      # @log.debug('userdb.write')
      write
    end
  end

  # userdbにあるかどうかの確認, パスワードの再設定
  # [email] e-mail address.
  # [newpw] password.
  def update_password(email, newpw)
    lock do
      read

      # userdbにあるかどうかの確認
      userdata = @content.findemail(email) # [id, name, pw]
      return unless userdata

      # パスワードの再設定
      dgpw = Digest::SHA256.hexdigest newpw
      @content.update_password(userdata[0], dgpw)

      write
      return userdata
    end
  end

  # パスワードの再設定
  # [uid] user id.
  # [newpw] password.
  def update_password_byid(uid, newpw)
    lock do
      read

      # パスワードの再設定
      dgpw = Digest::SHA256.hexdigest newpw
      @content.update_password(uid, dgpw)

      write
    end
  end

  # メールアドレスの再設定
  # [uid] user id.
  # [newem] メールアドレス.
  def update_email(uid, newem)
    lock do
      read

      # パスワードの再設定
      @content.update_email(uid, newem)

      write
    end
  end
end
