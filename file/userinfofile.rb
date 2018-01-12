# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'
require 'timeout'
require 'unindent'
require './secret_token.rb'
require './file/pathlist.rb'
require './util/myerror.rb'

#
# ユーザー情報DB管理クラス
#
# @note draw非対応
#
class UserInfoFile
  KEY = Globals::KEY

  # 初期化
  def initialize
    @fname = PathList::USERINFOFILE
    @names = {}
    @passwords = {}
    @emails = {}
    @stats = {}
  end

  attr_reader :fname, :names, :passwords, :emails, :stats

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

  # decode enctypted mail address
  #
  # [dec]  decoder object.
  # [data] data to be decoded.
  #
  # returns decoded mail address
  def decode_mail(dec, data)
    dec.pkcs5_keyivgen(KEY)
    em = ''
    em << dec.update([data].pack('H*'))
    em << dec.final
    em
  end

  # number of wins and loses.
  #
  # [elem] user data got by spliting a line
  #
  # returns {swin:, slose:, gwin:, glose:}
  def hash_stats(elem)
    {
      swin: elem[4].to_i, slose: elem[5].to_i,
      gwin: elem[6].to_i, glose: elem[7].to_i
    }
  end

  # read a user's data.
  #
  # [elem] user data got by spliting a line
  def read_elements(line)
    # comment
    return if line =~ /^#/

    # id, name, password, e-mail(encrypted), swn, sls, gwn, gls
    elements = line.chomp.split(',')
    return if elements.length != 8 # invalid line

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

  # read data from a file
  def read
    File.open(@fname, 'r:utf-8') do |file|
      file.flock File::LOCK_EX

      file.each_line do |line|
        read_elements(line)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "#{er} in read"
  rescue IOError => er
    puts "#{er} in read"
  end

  # encode mail address
  #
  # [id] ID whose mail address will be encoded.
  #
  # returns encoded mail address
  def encode_mail(id)
    enc = OpenSSL::Cipher.new('AES-256-CBC')
    enc.encrypt
    enc.pkcs5_keyivgen(KEY)
    crypted = ''
    crypted << enc.update(@emails[id])
    crypted << enc.final
    crypted.unpack('H*')[0]
  end

  # put header part of the file.
  #
  # [file] File object
  def put_header(file)
    file.puts '# user information ' + Time.now.to_s
    file.puts '# id, name, password, e-mail(encrypted), swn, sls, gwn, gls'
  end

  # build a line which contains a user's information.
  #
  # [id]       a user's ID
  # [mailaddr] a user's encoded mail address
  def build_line(id, mailaddr)
    "#{id},#{@names[id]},#{@passwords[id]},#{mailaddr}," \
    "#{@stats[id][:swin]},#{@stats[id][:slose]}," \
    "#{@stats[id][:gwin]},#{@stats[id][:glose]}"
  end

  # write data to a file.
  # note: use with lock(*)
  def write
    File.open(@fname, 'w') do |file|
      file.flock File::LOCK_EX

      put_header(file)

      names.each_key do |id|
        mailaddr = encode_mail(id)

        file.puts build_line(id, mailaddr)
      end
    end
  # 例外は小さい単位で捕捉する
  rescue SystemCallError => er
    puts "#{er} in write"
  rescue IOError => er
    puts "#{er} in write"
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
    found = @names.find { |_ky, vl| vl == name }

    [(id = found[0]), found[1], @passwords[id], @emails[id]] if found
  end

  # get user information by e-mail address
  #
  # return nil if not found.
  def findemail(addr)
    found = @emails.find { |_ky, vl| vl == addr }

    [(id = found[0]), @names[id], @passwords[id]] if found
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

          mailaddr = encode_mail(id)

          file.puts build_line(id, mailaddr)
        end
      end
    # 例外は小さい単位で捕捉する
    rescue SystemCallError => er
      puts "class=[#{er.class}] message=[#{er.message}] in write"
    rescue IOError => er
      puts "class=[#{er.class}] message=[#{er.message}] in write"
    end
  end

  # duplication check
  #
  # [id] user's ID to be checked
  def exist_id(id)
    @names.key?(id)
  end

  # duplication check
  #
  # [name] user's name to be checked
  def exist_name(name)
    @names.value?(name)
  end

  # duplication check?
  #
  # [pw] user's PASSWORD to be checked
  def exist_password(pw)
    @passwords.value?(pw)
  end

  # duplication check
  #
  # [addr] user's mail address to be checked
  def exist_email(addr)
    @emails.value?(addr)
  end

  # 勝敗の記入(勝った方と負けた方に１加算)
  #
  # @param gwin 後手勝ちの時true
  # @param idb  先手のID
  # @param idw  後手のID
  #
  # @note draw非対応
  def give_win_lose(gwin, idb, idw)
    if gwin
      @stats[idb][:slose] += 1
      @stats[idw][:gwin] += 1
    else
      @stats[idb][:swin] += 1
      @stats[idw][:glose] += 1
    end
  end

  # build table of IDs and names
  #
  # returns html table text
  def to_table_id_name
    str = <<-FNAME_AND_TABLE.unindent
      <table border=1> <caption>path:#{fname}</caption>
      <tr><th>ID</th><TH>Name</TH></TR>
      FNAME_AND_TABLE
    names.each do |id, name|
      str += "<tr><td>#{id}</td><td>#{name}</td></tr>\n"
    end
    str += "</table>\n"
    str
  end

  # build select element of IDs and names.
  #
  # [sname]  name of select element.
  # [sid]    id of select element.
  # [sclass] class of select element.
  # [custom] additional attributes of select element.
  #
  # returns html select text whose options are "john_doe(abcdefg)".
  def to_select_id_name(sname, sid, sclass, custom)
    str = "<select id='#{sid}' class='#{sclass}' name='#{sname}' #{custom}>\n"
    str += " <option value=''>name(id)</option>\n"
    names.each do |id, name|
      str += " <option value='#{id}'>#{name}(#{id})</option>\n"
    end

    str += "</select>\n"
    str
  end

  # put content of this class in html table format.
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
