# -*- encoding: utf-8 -*-

# @return nil:succeeded. otherwise error.
def genadmin
  print 'username:'
  name = STDIN.gets.to_s.chomp

  print 'e-mail address:'
  email1 = STDIN.gets.to_s.chomp

  print 'e-mail address(again):'
  email2 = STDIN.gets.to_s.chomp

  if email1 != email2
    print 'e-mail addresses are not same!'
    return 100
  end

  print 'password:'
  pw1 = STDIN.gets.to_s.chomp

  print 'password(again):'
  pw2 = STDIN.gets.to_s.chomp

  if pw1 != pw2
    print 'passwords are not same!'
    return 200
  end

  require 'digest/sha2'
  dgpw = Digest::SHA256.hexdigest pw1

  require './file/userinfofile.rb'
  db = UserInfoFile.new
  db.read

  # return 300 if name or e-mail is already registered

  id = db.add(name, dgpw, email1)
  db.write

  print 'a user was added as a user.'

  require './file/adminconfigfile.rb'
  adb = AdminConfigFile.new
  adb.add(id)

  print 'the user was registered as an admin.'
end
