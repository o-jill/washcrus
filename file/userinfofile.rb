# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'
require 'timeout'
require 'unindent'
require './secret_token.rb'
require './util/myerror.rb'

#
# ユーザー情報DB管理クラス
#
class UserInfoFile
  KEY = Globals::KEY
  LOCKFILE = './db/userinfofile.lock'.freeze

  def initialize(name = './db/userinfo.csv')
    @fname = name
    @names = {}
    @passwords = {}
    @emails = {}
    @stats = {}
  end

  attr_accessor :fname, :names, :passwords, :emails
  attr_reader :stats

  # usage:
  # lock do
  #   do_something
  # end
  def lock(*)
    Timeout.timeout(10) do
      File.open(LOCKFILE, 'w') do |file|
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

  def decode_mail(dec, data)
    dec.pkcs5_keyivgen(KEY)
    em = ''
    em << dec.update([data].pack('H*'))
    em << dec.final
    em
  end

  def hash_stats(elem)
    {
      swin: elem[4].to_i, slose: elem[5].to_i,
      gwin: elem[6].to_i, glose: elem[7].to_i
    }
  end

  def read_elements(elements)
    dec = OpenSSL::Cipher.new('AES-256-CBC')
    dec.decrypt

    id = elements[0]
    @names[id]     = elements[1]
    @passwords[id] = elements[2]
    # dec.pkcs5_keyivgen(KEY)
    # em = ''
    # em << dec.update([elements[3]].pack('H*'))
    # em << dec.final
    # @emails[id] = em
    @emails[id] = decode_mail(dec, elements[3])
    # @emails[id] = elements[3]
    @stats[id] = hash_stats(elements)
  end

  def read
    File.open(@fname, 'r:utf-8') do |file|
      file.flock File::LOCK_EX

      file.each_line do |line|
        # comment
        next if line =~ /^#/

        # id, name, password, e-mail(encrypted), swn, sls, gwn, gls
        elements = line.chomp.split(',')
        next if elements.length != 8 # invalid line

        read_elements(elements)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "#{e} in read"
  rescue IOError => e
    puts "#{e} in read"
  end

  def encode_mail(id)
    enc = OpenSSL::Cipher.new('AES-256-CBC')
    enc.encrypt
    enc.pkcs5_keyivgen(KEY)
    crypted = ''
    crypted << enc.update(@emails[id])
    crypted << enc.final
    crypted.unpack('H*')[0]
  end

  def put_header(file)
    file.puts '# user information ' + Time.now.to_s
    file.puts '# id, name, password, e-mail(encrypted), swn, sls, gwn, gls'
  end

  def build_line(id, mailaddr)
    "#{id},#{@names[id]},#{@passwords[id]},#{mailaddr}," \
    "#{@stats[id][:swin]},#{@stats[id][:slose]}," \
    "#{@stats[id][:gwin]},#{@stats[id][:glose]}"
  end

  # note: use with lock(*)
  def write
    File.open(@fname, 'w') do |file|
      file.flock File::LOCK_EX

      put_header(file)

      names.each do |id, _name|
        mailaddr = encode_mail(id)

        file.puts build_line(id, mailaddr)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => e
    puts "#{e} in write"
  rescue IOError => e
    puts "#{e} in write"
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

  # append a set of data to a db file.
  #
  # [id] user's ID to append
  def append(id)
    enc = OpenSSL::Cipher.new('AES-256-CBC')
    enc.encrypt
    # enc.pkcs5_keyivgen(KEY)
    begin
      lock do
        File.open(@fname, 'a') do |file|
          file.flock File::LOCK_EX

          mailaddr = encode_mail(enc, id)

          file.puts build_line(id, mailaddr)
        end
      end
    # 例外は小さい単位で捕捉する
    rescue SystemCallError => e
      puts "class=[#{e.class}] message=[#{e.message}] in write"
    rescue IOError => e
      puts "class=[#{e.class}] message=[#{e.message}] in write"
    end
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

  def to_table_id_name
    str = <<-FNAME_AND_TABLE.unindent
      <table border=1> <Caption>path:#{fname}</caption>
      <tr><th>ID</th><TH>Name</TH></TR>
      FNAME_AND_TABLE
    names.each do |id, name|
      str += "<tr><td>#{id}</td><td>#{name}</td></tr>\n"
    end
    str += "</table>\n"
    str
  end

  def to_select_id_name(sname, sid, sclass, custom)
    str = "<select id='#{sid}' class='#{sclass}' name='#{sname}' #{custom}>\n"
    str += " <option value=''>name(id)</option>\n"
    names.each do |id, name|
      str += " <option value='#{id}'>#{name}(#{id})</option>\n"
    end

    str += "</select>\n"
    str
  end

  def dumphtml
    print <<-FNAME_AND_TABLE.unindent
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
