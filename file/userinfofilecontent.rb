# -*- encoding: utf-8 -*-

require 'digest/sha2'
require 'openssl'
require 'unindent'

require './secret_token.rb'
require './file/pathlist.rb'

#
# ユーザー情報DB管理クラス
#
# @note draw非対応
#
class UserInfoFileContent
  KEY = Globals::KEY

  # 初期化
  def initialize
    @names = {}
    @passwords = {}
    @emails = {}
    @stats = {}
  end

  attr_reader :names, :passwords, :emails, :stats

  # decode enctypted mail address
  #
  # [dec]  decoder object.
  # [data] data to be decoded.
  #
  # returns decoded mail address
  def self.decode_mail(dec, data)
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
  def self.hash_stats(elem)
    e = elem[4, 4].map(&:to_i)
    { swin: e[0], slose: e[1], gwin: e[2], glose: e[3] }
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
    @emails[id] = UserInfoFileContent.decode_mail(dec, elements[3])
    @stats[id] = UserInfoFileContent.hash_stats(elements)
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

  # build a line which contains a user's information.
  #
  # [id]       a user's ID
  def build_line(id)
    mailaddr = encode_mail(id)
    status = @stats[id]
    "#{id},#{@names[id]},#{@passwords[id]},#{mailaddr}," \
    "#{status[:swin]},#{status[:slose]},#{status[:gwin]},#{status[:glose]}"
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
  # [pwd] user's PASSWORD to be checked
  def exist_password(pwd)
    @passwords.value?(pwd)
  end

  # duplication check
  #
  # [addr] user's mail address to be checked
  def exist_email(addr)
    @emails.value?(addr)
  end

  # updated password if id exists.
  #
  # [id] user id
  # [dgpw] digested password
  def update_password(id, dgpw)
    @passwords[id] = dgpw if @passwords[id]
  end

  # updated e-mail address if id exists.
  #
  # [id] user id
  # [dgpw] email address
  def update_email(id, email)
    @emails[id] = email if @emails[id]
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
    str = "<table border=1> <caption>path:#{fname}</caption>\n" \
          "<tr><th>ID</th><th>Name</th></tr>\n"

    names.each do |id, name|
      str += "<tr><td>#{id}</td><td>#{name}</td></tr>\n"
    end

    str + "</table>\n"
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
    str = "<select id='#{sid}' class='#{sclass}' name='#{sname}' #{custom}>\n" \
          " <option value=''>name(id)</option>\n"

    names.each do |id, name|
      str += " <option value='#{id}'>#{name}(#{id})</option>\n"
    end

    str + "</select>\n"
  end

  # put content of this class in html table format.
  def dumphtml
    puts <<-FNAME_AND_TABLE.unindent
      <table border=1> <caption>path:\#{fname}</caption>
      <tr><th>ID</th><TH>Name</TH><TH>Password</TH><TH>Mail</TH></TR>
      FNAME_AND_TABLE
    names.each do |id, name|
      puts "<tr><td>#{id}</td><td>#{name}</td>" \
           "<td>#{@passwords[id]}</td><td>#{@emails[id]}</td></tr>"
    end
    puts '</table>'
  end
end
