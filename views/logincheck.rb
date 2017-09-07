# -*- encoding: utf-8 -*-

require 'cgi'
require 'cgi/session'
require 'digest/sha2'
require 'unindent'
require './file/userinfofile.rb'
require './views/common_ui.rb'

def check_pswd(pswd)
  errmsg = ''
  errmsg += 'wrong password ...<BR>' if pswd.nil? || pswd.length < 4
  errmsg
end

def check_email(email)
  errmsg = ''
  errmsg += 'wrong e-mail address ...<BR>' if email.nil? || email.length < 4
  errmsg
end

def check_datalost(pswd, email)
  pswd.nil? || pswd.length.zero? || email.nil? || email.length.zero?
end

def check_login(params)
  pswd = params['sipassword']
  email = params['siemail']
  return { errmsg: 'data lost ...<BR>' } if check_datalost(pswd, email)

  errmsg = ''

  pswd = pswd[0]
  errmsg += check_pswd(pswd)

  email = email[0]
  errmsg += check_email(email)

  userdb = UserInfoFile.new
  userdb.read
  userdata = userdb.findemail(email) # [id, @names[id], @passwords[id]]

  dgpw = Digest::SHA256.hexdigest pswd

  if userdata.nil? || dgpw != userdata[2]
    errmsg += 'e-mail address or password is wrong ...<BR>'
    return { errmsg: errmsg }
  end

  userinfo = UserInfo.new(1, userdata[0], userdata[1], email)

  { errmsg: errmsg, userinfo: userinfo }
end

def gen_new_session(cgi, userinfo)
  expire = Time.now + 2_592_000 # 30days
  session = CGI::Session.new(cgi,
                             'new_session' => true,
                             'session_key' => '_washcrus_session',
                             'tmpdir' => './tmp',
                             'session_expires' => expire)

  userinfo.hashsession.each { |k, v| session[k] = v }

  session['session_expires'] = expire

  session.update
end

#
# ログイン完了orログインエラー画面
#
def logincheck_screen(session, title, name, cgi)
  if session.nil?
    ret = check_login(cgi.params)
    errmsg = ret[:errmsg]
  else
    errmsg = 'you are already logged in!'
  end

  if errmsg.length.zero?
    gen_new_session(cgi, ret[:userinfo])

    msg = <<-LOGINMSG.unindent
      Logged in successfully.<BR>
      username:#{userinfo.user_name}<BR>
      password:****<BR>
      email address:#{userinfo.user_email}<BR>
      LOGINMSG
  else
    # エラー
    msg = "<SPAN class='err'>Unfortunately failed ...<BR>#{errmsg}</SPAN>\n"
  end

  header = cgi.header('charset' => 'UTF-8',
                      'Pragma' => 'no-cache',
                      'Cache-Control' => 'no-cache')

  header = header.gsub("\r\n", "\n")

  CommonUI::HTMLHead(header, title)
  CommonUI::HTMLmenu(name)
  print msg
  # puts "<pre>header:#{header}</pre>"
  CommonUI::HTMLfoot()
end
