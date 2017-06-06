#!d:\ruby193\bin\ruby.exe
# -*- encoding: utf-8 -*-

#
# ユーザー情報管理クラス
#
class UserInfo
  def initialize(count = -1, id = nil, name = nil, addr = nil)
    @visitcount = count
    @user_id = id
    @user_name = name
    @user_email = addr
  end

  attr_accessor :visitcount, :user_id, :user_name, :user_email

  def readsession(session)
    @visitcount = session['count'].to_i + 1
    @user_id = session['user_id']
    @user_name = session['user_name']
    @user_email = session['user_email']
  end

  def hashsession
    {
      'count' => @visitcount, 'user_id' => @user_id, 'user_name' => @user_name,
      'user_email' => @user_email
    }
  end

  def invalid?
    userinfo.user_id.nil? || userinfo.user_id == '' \
      || userinfo.user_name.nil? || userinfo.user_name == '' \
      || userinfo.user_email.nil? || userinfo.user_email == ''
  end

  def dump
    print 'userid:', @user_id, 'username:', @user_name,
          'useremail:', @user_email, 'visitcount:', @visitcount
  end

  def dumptable
    print '<TABLE><TR><TD>userid</TD><TD>', @user_id,
          '</TD></TR><TR><TD>username</TD><TD>', @user_name,
          '</TD></TR><TR><TD>useremail</TD><TD>', @user_email,
          '</TD></TR><TR><TD>visitcount</TD><TD>', @visitcount,
          '</TD></TR></TABLE>'
  end
end
