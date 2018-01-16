[![license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://github.com/o-jill/washcrus/)
[![issues](https://img.shields.io/github/issues/o-jill/washcrus.svg)](https://github.com/o-jill/washcrus/issues/)
[![Code Climate](https://codeclimate.com/github/o-jill/washcrus/badges/gpa.svg)](https://codeclimate.com/github/o-jill/washcrus)
[![Inline docs](http://inch-ci.org/github/o-jill/washcrus.svg?branch=master)](http://inch-ci.org/github/o-jill/washcrus)
[![Dependency Status](https://gemnasium.com/badges/github.com/o-jill/washcrus.svg)](https://gemnasium.com/github.com/o-jill/washcrus)

"WashCrus" will be online shogi match management system.

"WashCrus" was named for "洗足池" which is a pond in Tokyo.

"WashCrus" is written in Ruby.

Lisence: Public domain

How to set up:
1. Clone repo. or unzip WashCrus archive to certain path where is allowed to run CGI script.
2. Edit ./config/mail.yaml.sample and save it as ./config/mail.yaml
3. Edit ./config/signature.txt.sample and save it as ./config/signature.txt
4. Edit ./config/settings.yaml.sample and save it as ./config/settings.yaml
5. Run "bundle" to get required gems.
6. Run "rake gen_token" to generate KEY to encrypt data.
7. Run "rake add_admin" to add first administrator.
8. Run "rake init" to generate db file and change some files/directories's permissions.
9. Visit washcrus.rb by your browser.

ruby path:
please adjust ruby path to fit your actual ruby path.

Simple backup:
"rake backup" stores all the data into a tarball in backup directory.
you can use "backup.sh" after adjusting a path in the script and run it periodically, e.g. once a day.

Enable Time control:
"periodic_tasks.sh" controls byo-yomi.
you have to adjust a path in the script and period in minutes.
you also have to fix "byouyomichan.rb" as below because sending a mail is disabled by default.
```ruby
>>>>> repo
mmgr = MailManager.new
# mmgr.send_mail(nply[:mail], subject, msg)
print <<-FAKE_MAIL.unindent
  to:#{nply[:name]}
  subject:#{subject}
  msg:#{msg}
  FAKE_MAIL
=====
mmgr = MailManager.new
mmgr.send_mail(nply[:mail], subject, msg) # enable this line!
# print <<-FAKE_MAIL.unindent
#   to:#{nply[:name]}
#   subject:#{subject}
#   msg:#{msg}
#   FAKE_MAIL
<<<<< enabled
```

required "gem"s
* bundler
  * jkf(o-jill/jkf, kif_robust_time)
  * mail
  * rake
  * redcarpet
  * rspec
  * unindent
