# -*- encoding: utf-8 -*-

require 'digest/sha2'

require './file/adminconfigfile.rb'
require './file/userinfofile.rb'

def velify_email
  print 'e-mail address:'
  email1 = STDIN.gets.to_s.chomp

  print 'e-mail address(again):'
  email2 = STDIN.gets.to_s.chomp

  if email1 != email2
    puts 'e-mail addresses are not same!'
  else
    email1
  end
end

def velify_pw
  print 'password:'
  pw1 = STDIN.gets.to_s.chomp

  print 'password(again):'
  pw2 = STDIN.gets.to_s.chomp

  if pw1 != pw2
    puts 'passwords are not same!'
  else
    pw1
  end
end

# @return nil:succeeded. otherwise error.
def genadmin
  print 'username:'
  name = STDIN.gets.to_s.chomp

  email = velify_email
  return 100 if email.nil?

  pw = velify_pw
  return 200 if pw.nil?

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
