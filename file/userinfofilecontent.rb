# -*- encoding: utf-8 -*-
# frozen_string_literal: true

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

  # @!attribute [r] names
  #   @return id:名前 のハッシュ
  # @!attribute [r] passwords
  #   @returnid:パスワードのダイジェスト のハッシュ
  # @!attribute [r] emails
  #   @return id:メールアドレス のハッシュ
  # @!attribute [r] stats
  #   @return id:勝敗 のハッシュ
  attr_reader :names, :passwords, :emails, :stats

  # decode enctypted mail address
  #
  # [dec]  decoder object.
  # [data] data to be decoded.
  #
  # returns decoded mail address
  def self.decode_mail(dec, data)
    dec.pkcs5_keyivgen(KEY)
    em = dec.update([data].pack('H*'))
    em << dec.final
    em
  end

  # number of wins and loses.
  #
  # [elem] user data got by spliting a line
  #
  # returns {swin:, slose:, gwin:, glose:, draw}
  def self.hash_stats(elem)
    e = elem[4, 4].map(&:to_i)
    draw = elem[8] || '0'
    { swin: e[0], slose: e[1], gwin: e[2], glose: e[3], draw: draw.to_i }
  end

  # read a user's data.
  #
  # [elem] user data got by spliting a line
  def read_elements(line)
    # comment
    return if line =~ /^#/

    # id, name, password, e-mail(encrypted), swn, sls, gwn, gls
    elements = line.chomp.split(',')
    return unless elements.length.between?(8, 9) # invalid line

    dec = OpenSSL::Cipher.new('AES-256-CBC')
    dec.decrypt
    (id, name, passwd, encemail) = elements
    # id = elements[0]
    @names[id] = name # elements[1]
    @passwords[id] = passwd # elements[2]
    @emails[id] = UserInfoFileContent.decode_mail(dec, encemail)
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
    crypted = enc.update(@emails[id])
    crypted << enc.final
    crypted.unpack('H*')[0]
  end

  # build a line which contains ins and loses.
  def build_winlose(swin:, slose:, gwin:, glose:, draw:)
    "#{swin},#{slose},#{gwin},#{glose},#{draw}"
  end

  # build a line which contains a user's information.
  #
  # [id]       a user's ID
  def build_line(id)
    mailaddr = encode_mail(id)
    status = @stats[id]
    "#{id},#{@names[id]},#{@passwords[id]},#{mailaddr}," \
    "#{build_winlose(**status)}"
  end

  # get user information by id
  #
  # return nil if not found.
  def findid(id)
    return nil unless exist?(id)

    { id: id, name: @names[id], pw: @passwords[id], email: @emails[id] }
  end

  # get user information by id
  #
  # return nil if not found.
  def findname(name)
    found = @names.find { |_ky, vl| vl == name }
    return nil unless found

    { id: (id = found[0]), name: name, pw: @passwords[id], email: @emails[id] }\
  end

  # get user information by e-mail address
  #
  # return nil if not found.
  def findemail(addr)
    found = @emails.find { |_ky, vl| vl == addr }
    return nil unless found

    { id: (id = found[0]), name: @names[id], pw: @passwords[id], email: addr }
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
    @stats[id]     = { swin: 0, slose: 0, gwin: 0, glose: 0, draw: 0 }

    id
  end

  # duplication check
  #
  # [id] user's ID to be checked
  def exist?(id)
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

  # updated name if id exists.
  #
  # [id] user id
  # [name] name
  def update_name(id, name)
    @names[id] = name if @names[id]
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

  # 勝敗の記入(draw)
  #
  # @param idb  先手のID
  # @param idw  後手のID
  def give_draw(idb, idw)
    if @stats[idb][:draw].nil?
      @stats[idb][:draw] = 1
    else
      @stats[idb][:draw] += 1
    end
    if @stats[idw][:draw].nil?
      @stats[idw][:draw] = 1
    else
      @stats[idw][:draw] += 1
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
