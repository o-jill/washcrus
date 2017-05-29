#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'

class UserInfoFile
  KEY = 'thirty two byte secure password.'

  def initialize(name = './userinfo.csv')
    @fname = name;
    @names = {}
    @passwords = {}
    @emails = {}
  end

  attr_accessor :fname, :names, :passwords, :emails

  def read
    dec = OpenSSL::Cipher.new('AES-256-CBC')
    dec.decrypt
    # dec.pkcs5_keyivgen(KEY)
    begin
      File.open(@fname, 'r:utf-8') do |file|
        file.flock File::LOCK_EX

        file.each_line do |line|
          if line =~ /^#/
            # commentq
          else
            # id, name, password, e-mail(encrypted)
            elements = line.chomp.split(',')
            if elements.length != 4
              # invalid line
            else
              id = elements[0]
              @names[id]     = elements[1]
              @passwords[id] = elements[2]
              dec.pkcs5_keyivgen(KEY)
              em = ''
              em << dec.update([elements[3]].pack('H*'))
              em << dec.final
              @emails[id] = em
            end
          end
        end
      end
    # 例外は小さい単位で捕捉する
    rescue SystemCallError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}] in read)
    rescue IOError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}] in read)
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
        file.puts '# id, name, password, e-mail(encrypted)'
        names.each { |id, name|
          enc.pkcs5_keyivgen(KEY)
          crypted = ''
          crypted << enc.update(@emails[id])
          crypted << enc.final
          file.puts id + ',' + name + ',' + @passwords[id] + ',' + crypted.unpack('H*')[0]
        }
      end
    # 例外は小さい単位で捕捉する
    rescue SystemCallError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}] in write)
    rescue IOError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}] in write)
    end
  end

  # get user information by id
  def findid(id)
    if exist_id(id)
      [@names[id], @passwords[id], @emails[id]]
    else
      nil
    end
  end

  # get user information by id
  def findname(name)
    found = @names.find { |_k, v| v == name }
    if !found.nil?
      id = found[0]
      [id, found[1], @passwords[id], @emails[id]]
    else
      nil
    end
  end

  # get user information by e-mail address
  def findemail(addr)
    found = @emails.find { |_k, v| v == addr }
    if !found.nil?
      id = found[0]
      [id, @names[id], @passwords[id]]
    else
      nil
    end
  end

  # add user information and generate id
  # [name]     user name.
  # [password] AES256CBC encrypted password.
  # [email]    e-mail address.
  def add(name, password, email)
    id = Digest::SHA256.hexdigest name + '_' + password + '_' + email
    id = id[0, 8]
    @names[id]     = name
    @passwords[id] = password
    @emails[id]    = email
  end

  # duplication check
  def exist_id(id)
    found = @names.find { |k, _v| k == id }
    !found.nil?
  end

  # duplication check
  def exist_name(name)
    found = @names.find { |_k, v| v == name }
    !found.nil?
  end

  # duplication check?
  def exist_password(pw)
    found = @passwords.find { |_k, v| v == pw }
    !found.nil?
  end

  # duplication check
  def exist_email(addr)
    found = @emails.find { |_k, v| v == addr }
    !found.nil?
  end

  def dumphtml
    print <<-FNAME_AND_TABLE
      <table border=1>
      <Caption>path:#{fname}</caption>
      <tr><th>ID</th><TH>Name</TH><TH>Password</TH><TH>Mail</TH></TR>
      FNAME_AND_TABLE
    names.each { |id, name|
      puts '<TR><TD>' + id + '</TD><TD>' + name + '</TD><TD>' + @passwords[id] + '</TD><TD>' + @emails[id] + '</TD></TR>'
    }
    puts '</table>'
  end
end
