#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'

class UserInfoFile
  KEY = "thirty two byte secure password."

  def initialize(name = "./userinfo.csv")
    @fname = name;
    @names = Hash.new
    @passwords = Hash.new
    @emails = Hash.new
  end

  attr_accessor :fname, :names, :passwords, :emails

  def read
    dec = OpenSSL::Cipher.new("AES-256-CBC")
    dec.decrypt
    dec.pkcs5_keyivgen(KEY)
    begin
      File.open(@fname, "r") do |file|
        file.flock File::LOCK_EX

        file.each_line do |line|
          if line =~ /^#/
            # comment
          else
            # id, name, password, e-mail(encrypted)
            elements = line.chomp.split(',')
            if elements.length != 4
              # invalid line
            else
              id = elements[0];
              @names[id]     = elements[1]
              @passwords[id] = elements[2]
              em = ""
              em << dec.update([elements[3]].pack("H*"))
              em << dec.final
              @emails[id]    = em
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
    enc = OpenSSL::Cipher.new("AES-256-CBC")
    enc.encrypt
    enc.pkcs5_keyivgen(KEY)
    begin
      File.open(@fname, "w") do |file|
        file.flock File::LOCK_EX
        file.puts "# user information "+ Time.now.to_s
        file.puts "# id, name, password, e-mail(encrypted)"
        names.each{ |id, name|
          crypted = ""
          crypted << enc.update(@emails[id])
          crypted << enc.final
          file.puts id+","+name+","+@passwords[id]+","+crypted.unpack("H*")[0]
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
      return [@names[id], @passwords[id], @emails[id]]
    else
      return nil
    end
  end
  # get user information by id
  def findname(name)
    found = @names.find {|k, v| v == name}
    if (found != nill)
      id = found[0]
      return [id, found[1], @passwords[id], @emails[id]]
    else
      return nil
    end
  end
  # get user information by e-mail address
  def findemail(addr)
    found = @emails.find {|k, v| v == addr}
    if (found != nil)
      id = found[0]
      return [id, @names[id], @passwords[id]]
    else
      return nil
    end
  end
  # add user information
  # [name]     user name.
  # [password] AES256CBC encrypted password.
  # [email]    e-mail address.
  def add(name, password, email)
    id = Digest::SHA256.hexdigest name+'_'+password+'_'+email

    @names[id]     = name
    @passwords[id] = password
    @emails[id]    = email
  end
  # duplication check
  def exist_id(id)
    found = @names.find {|k, v| k == id}
    return found != nil
  end
  # duplication check
  def exist_name(name)
    found = @names.find {|k, v| v == name}
    return found != nil
  end
  # duplication check?
  def exist_password(pw)
    found = @passwords.find {|k, v| v == pw}
    return found != nil
  end
  # duplication check
  def exist_email(addr)
    found = @emails.find {|k, v| v == addr}
    return found != nil
  end
end
