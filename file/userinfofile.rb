# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'

require './secret_token.rb'

#
# ユーザー情報DB管理クラス
#
class UserInfoFile
  KEY = Globals::KEY

  def initialize(name = './db/userinfo.csv')
    @fname = name
    @names = {}
    @passwords = {}
    @emails = {}
    @stats = {}
  end

  attr_accessor :fname, :names, :passwords, :emails
  attr_reader :stats

  def read
    dec = OpenSSL::Cipher.new('AES-256-CBC')
    dec.decrypt
    # dec.pkcs5_keyivgen(KEY)
    begin
      File.open(@fname, 'r:utf-8') do |file|
        file.flock File::LOCK_EX

        file.each_line do |line|
          # comment
          next if line =~ /^#/

          # id, name, password, e-mail(encrypted)
          elements = line.chomp.split(',')
          next if elements.length != 8 # invalid line

          id = elements[0]
          @names[id]     = elements[1]
          @passwords[id] = elements[2]
          dec.pkcs5_keyivgen(KEY)
          em = ''
          em << dec.update([elements[3]].pack('H*'))
          em << dec.final
          @emails[id] = em
          @stats[id] = {
            swin: elements[4].to_i, slose: elements[5].to_i,
            gwin: elements[6].to_i, glose: elements[7].to_i
          }
        end
      end
    # 例外は小さい単位で捕捉する
    rescue SystemCallError => e
      puts "class=[#{e.class}] message=[#{e.message}] in read"
    rescue IOError => e
      puts "class=[#{e.class}] message=[#{e.message}] in read"
    end
  end

  def write
    enc = OpenSSL::Cipher.new('AES-256-CBC')
    enc.encrypt
    # enc.pkcs5_keyivgen(KEY)
    begin
      File.open(@fname, 'w') do |file|
        file.flock File::LOCK_EX
        file.puts '# user information ' + Time.now.to_s
        file.puts '# id, name, password, e-mail(encrypted), swn, sls, gwn, gls'
        names.each do |id, name|
          enc.pkcs5_keyivgen(KEY)
          crypted = ''
          crypted << enc.update(@emails[id])
          crypted << enc.final
          mailaddr = crypted.unpack('H*')[0]
          file.puts "#{id},#{name},#{@passwords[id]},#{mailaddr}," \
                    "#{@stats[id][:swin]},#{@stats[id][:slose]}," \
                    "#{@stats[id][:gwin]},#{@stats[id][:glose]}"
        end
      end
    # 例外は小さい単位で捕捉する
    rescue SystemCallError => e
      puts "class=[#{e.class}] message=[#{e.message}] in write"
    rescue IOError => e
      puts "class=[#{e.class}] message=[#{e.message}] in write"
    end
  end

  # get user information by id
  #
  # return nil if not found.
  def findid(id)
    [@names[id], @passwords[id], @emails[id]] if exist_id(id)
  end

  # get user information by id
  #
  # return nil if not found.
  def findname(name)
    found = @names.find { |_k, v| v == name }

    [(id = found[0]), found[1], @passwords[id], @emails[id]] unless found.nil?
  end

  # get user information by e-mail address
  #
  # return nil if not found.
  def findemail(addr)
    found = @emails.find { |_k, v| v == addr }

    [(id = found[0]), @names[id], @passwords[id]] unless found.nil?
  end

  # add user information and generate id
  # [name]     user name.
  # [password] AES256CBC encrypted password.
  # [email]    e-mail address.
  #
  # return added user's ID
  def add(name, password, email)
    id = Digest::SHA256.hexdigest name + '_' + password + '_' + email
    id = id[0, 8]
    @names[id]     = name
    @passwords[id] = password
    @emails[id]    = email
    @stats[id]     = { swin: 0, slose: 0, gwin: 0, glose: 0 }

    id
  end

  # duplication check
  def exist_id(id)
    @names.key?(id)
  end

  # duplication check
  def exist_name(name)
    @names.value?(name)
  end

  # duplication check?
  def exist_password(pw)
    @passwords.value?(pw)
  end

  # duplication check
  def exist_email(addr)
    @emails.value?(addr)
  end

  # duplication check
  def exist_name_or_email(name, addr)
    @names.value?(name) || @emails.value?(addr)
  end

  # @param sym [symbol] :swin, :slose, :gwin, :glose
  def win_lose(id, sym)
    @stats[id][sym] += 1
  end

  def dumphtml
    print <<-FNAME_AND_TABLE
      <table border=1> <Caption>path:#{fname}</caption>
      <tr><th>ID</th><TH>Name</TH><TH>Password</TH><TH>Mail</TH></TR>
      FNAME_AND_TABLE
    names.each do |id, name|
      puts "<TR><TD>#{id}</TD><TD>#{name}</TD>",
           "<TD>#{@passwords[id]}</TD><TD>#{@emails[id]}</TD></TR>"
    end
    puts '</table>'
  end
end
