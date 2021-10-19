# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'digest/sha2'
require 'openssl'
require 'timeout'
require 'unindent'
require './file/mylock.rb'
require './file/pathlist.rb'
require './file/userinfofilecontent.rb'
require './util/myerror.rb'

#
# ユーザー情報DB管理クラス
#
# @note draw非対応
#
class UserInfoFile
  include MyLock
  # 初期化
  def initialize
    @fname = PathList::USERINFOFILE
    @content = UserInfoFileContent.new
  end

  # @!attribute fname
  #   @return ファイル名
  attr_reader :fname

  # @!attribute content
  #   @return 内容
  attr_reader :content

  # read data from a file
  def read
    File.open(@fname, 'r:utf-8') do |file|
      file.flock File::LOCK_EX

      file.each_line do |line|
        @content.read_elements(line)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "#{e} in read"
  rescue IOError => e
    puts "#{e} in read"
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
  rescue SystemCallError => e
    puts "#{e} in write"
  rescue IOError => e
    puts "#{e} in write"
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
  rescue SystemCallError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
  rescue IOError => e
    puts "class=[#{e.class}] message=[#{e.message}] in write"
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

    lock(PathList::USERINFOLOCKFILE) do
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
    lock(PathList::USERINFOLOCKFILE) do
      read
      @content.give_win_lose(gwin, idb, idw)
      # @log.debug('userdb.write')
      write
    end
  end

  # 勝敗の記入(draw)
  #
  # @param idb  先手のID
  # @param idw  後手のID
  def give_draw(idb, idw)
    lock(PathList::USERINFOLOCKFILE) do
      read
      @content.give_draw(idb, idw)
      write
    end
  end

  # userdbにあるかどうかの確認, パスワードの再設定
  # [email] e-mail address.
  # [newpw] password.
  def update_password(email, newpw)
    lock(PathList::USERINFOLOCKFILE) do
      read

      # userdbにあるかどうかの確認
      userdata = @content.findemail(email)
      return unless userdata

      # パスワードの再設定
      dgpw = Digest::SHA256.hexdigest newpw
      @content.update_password(userdata[:id], dgpw)

      write
      return userdata
    end
  end

  # パスワードの再設定
  # [uid] user id.
  # [newpw] password.
  def update_password_byid(uid, newpw)
    lock(PathList::USERINFOLOCKFILE) do
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
    read

    userdata = content.findid(uid) # [names:, pw:, email:]
    return '<span class="err">user information error...</span>' unless userdata

    return '<span class="err">e-mail address is already registered ...</span>' \
      if content.exist_email(newem)

    update_email_indb(uid, newem)
    nil
  end

  # メールアドレスのDBへの再設定
  # [uid] user id.
  # [newem] メールアドレス.
  def update_email_indb(uid, newem)
    lock(PathList::USERINFOLOCKFILE) do
      read

      # メールアドレスの再設定
      @content.update_email(uid, newem)

      write
    end
  end

  # 名前の再設定
  # [uid] user id.
  # [newnm] 名前.
  def update_name(uid, newnm)
    lock(PathList::USERINFOLOCKFILE) do
      read

      # 名前の再設定
      @content.update_name(uid, newnm)

      write
    end
  end
end
