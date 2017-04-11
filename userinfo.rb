#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

class UserInfo
  def initialize(count = -1, id = nil, name = nil)
    @visitcount = count
    @user_id = id
    @user_name = name
  end

  attr_accessor :visitcount, :user_id, :user_name

  def readsession(session)
    @visitcount = session['count'].to_i+1
    @user_id = session['user_id']
    @user_name = session['user_name']
  end

  def dump
    print "userid:", @user_id,
          "username:", @user_name,
          "visitcount:", @visitcount
  end

  def dumptable
    print "<TABLE><TR><TD>userid</TD><TD>", @user_id,
          "</TD></TR><TR><TD>username</TD><TD>", @user_name,
          "</TD></TR><TR><TD>visitcount</TD><TD>", @visitcount,
          "</TD></TR></TABLE>"
  end
end
