# -*- encoding: utf-8 -*-

require 'digest/sha2'

require './file/adminconfigfile.rb'
require './file/userinfofile.rb'

# 標準入力からの読み込み
def line_stdin
  STDIN.gets.to_s.chomp
end

# メールアドレスの確認
def velify_email
  print 'e-mail address:'
  email = line_stdin

  print 'e-mail address(again):'
  emaila = line_stdin

  if email != emaila
    puts 'e-mail addresses are not same!'
  else
    email
  end
end

# パスワードの確認
def velify_pw
  print 'password:'
  pw = line_stdin

  print 'password(again):'
  pwa = line_stdin

  if pw != pwa
    puts 'passwords are not same!'
  else
    pw
  end
end

# 管理者権限付きアカウントの作成
#
# @return nil:succeeded. otherwise error.
def genadmin
  print 'username:'
  name = line_stdin

  email = velify_email
  return 100 unless email

  pw = velify_pw
  return 200 unless pw

  dgpw = Digest::SHA256.hexdigest pw

  db = UserInfoFile.new
  db.read

  # return 300 if name or e-mail is already registered

  id = db.add(name, dgpw, email)
  db.append(id)

  puts 'a user was added as a user.'

  adb = AdminConfigFile.new
  adb.add(id)

  puts 'the user was registered as an admin.'
end
