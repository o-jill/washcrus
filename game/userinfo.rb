# -*- encoding: utf-8 -*-

require './file/userinfofile.rb'

#
# ユーザー情報管理クラス
#
class UserInfo
  def initialize(count = -1, id = nil, name = nil, addr = nil)
    @visitcount = count
    @user_id = id
    @user_name = name
    @user_email = addr
    @win_lose = { swin: 0, slose: 0, gwin: 0, glose: 0 }
  end

  attr_accessor :visitcount, :user_id, :user_name, :user_email, :win_lose

  def readsession(session)
    # keys for session must be Strings, not symbols.
    @visitcount = session['count'].to_i + 1
    @user_id = session['user_id']
    @user_name = session['user_name']
    @user_email = session['user_email']
  end

  def hashsession
    {
      # keys for session must be Strings, not symbols.
      'count' => @visitcount, 'user_id' => @user_id,
      'user_name' => @user_name, 'user_email' => @user_email
    }
  end

  def invalid?
    user_id.nil? || user_id.length.zero? || user_name.nil? \
    || user_name.length.zero? || user_email.nil? || user_email.length.zero?
  end

  def exist_indb
    db = UserInfoFile.new
    db.read
    db.exist_id(@user_id)
  end

  def dump
    print "userid:#{@user_id}username:#{@user_name}",
          "useremail:#{@user_email}visitcount:#{@visitcount}"
  end

  def dumptable
    print "<TABLE><TR><TD>userid</TD><TD>#{@user_id}</TD></TR>",
          "<TR><TD>username</TD><TD>#{@user_name}</TD></TR>",
          "<TR><TD>useremail</TD><TD>#{@user_email}</TD></TR>",
          "<TR><TD>visitcount</TD><TD>#{@visitcount}</TD></TR></TABLE>"
  end
end
