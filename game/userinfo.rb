# -*- encoding: utf-8 -*-

require 'rubygems'
require 'unindent'

require './file/adminconfigfile.rb'
require './file/userinfofile.rb'

#
# ユーザー情報管理クラス
#
class UserInfo
  # 初期化
  #
  # @param count 訪問回数
  # @param id    ユーザーID
  # @param name  ユーザー名
  # @param addr  メールアドレス
  def initialize(count = -1, id = nil, name = nil, addr = nil)
    # 訪問回数
    @visitcount = count
    # ユーザーID
    @user_id = id
    # ユーザー名
    @user_name = name
    # メールアドレス
    @user_email = addr
    # 戦績
    @win_lose = { swin: 0, slose: 0, gwin: 0, glose: 0 }
    # 管理者権限
    @admin = id.nil? ? false : check_admin
  end

  attr_accessor :visitcount, :user_id, :user_name, :user_email, :win_lose
  attr_reader :admin

  # read data from session hash object.
  #
  # @param session セッションオブジェクト
  def readsession(session)
    # keys for session must be Strings, not symbols.
    @visitcount = session['count'].to_i + 1
    @user_id = session['user_id']
    @user_name = session['user_name']
    @user_email = session['user_email']
    @admin = session['adminright'] || false
  end

  # generate data hash object.
  #
  # @return {'count':, 'user_id':, 'user_name':, 'user_email':, 'adminright':}
  def hashsession
    {
      # keys for session must be Strings, not symbols.
      'count' => @visitcount, 'user_id' => @user_id,
      'user_name' => @user_name, 'user_email' => @user_email,
      'adminright' => @admin
    }
  end

  # check if data is valid.
  #
  # @return user_id, user_name, user_emailすべてが文字列を持っていればfalse
  def invalid?
    user_id.nil? || user_id.length.zero? || user_name.nil? \
    || user_name.length.zero? || user_email.nil? || user_email.length.zero?
  end

  # check if exist
  #
  # @return user_idがdbにあればtrue
  def exist_indb
    db = UserInfoFile.new
    db.read
    db.exist_id(@user_id)
  end

  # check and set if administrator.
  def check_admin
    ac = AdminConfigFile.new
    ac.read
    @admin = ac.exist?(@user_id)
  end

  # put data
  def dump
    print "userid:#{@user_id},username:#{@user_name}" \
          "useremail:#{@user_email},visitcount:#{@visitcount}," \
          "admin:#{@admin}"
  end

  # put data in html table format.
  def dumptable
    print <<-TABLEDATA.unindent
      <table>
       <tr><td>userid</td><td>#{@user_id}</td></tr>
       <tr><td>username</td><td>#{@user_name}</td></tr>
       <tr><td>useremail</td><td>#{@user_email}</td></tr>
       <tr><td>visitcount</td><td>#{@visitcount}</td></tr>
       <tr><td>admin</td><td>#{@admin}</td></tr>
      </table>
      TABLEDATA
  end
end
