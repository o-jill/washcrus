[![license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://github.com/o-jill/washcrus/)
[![issues](https://img.shields.io/github/issues/o-jill/washcrus.svg)](https://github.com/o-jill/washcrus/issues/)
[![Code Climate](https://codeclimate.com/github/o-jill/washcrus/badges/gpa.svg)](https://codeclimate.com/github/o-jill/washcrus)
[![Inline docs](http://inch-ci.org/github/o-jill/washcrus.svg?branch=master)](http://inch-ci.org/github/o-jill/washcrus)
[![Firefox test](https://github.com/o-jill/washcrus/actions/workflows/firefoxtest.yml/badge.svg)](https://github.com/o-jill/washcrus/actions/workflows/firefoxtest.yml)
[![Chrome test](https://github.com/o-jill/washcrus/actions/workflows/chrometest.yml/badge.svg)](https://github.com/o-jill/washcrus/actions/workflows/chrometest.yml)
[![Firefox test](https://github.com/o-jill/washcrus/actions/workflows/firefoxtestruby2.yml/badge.svg)](https://github.com/o-jill/washcrus/actions/workflows/firefoxtestruby2.yml)
[![Chrome test](https://github.com/o-jill/washcrus/actions/workflows/chrometestruby2.yml/badge.svg)](https://github.com/o-jill/washcrus/actions/workflows/chrometestruby2.yml)
[![Rubocop](https://github.com/o-jill/washcrus/actions/workflows/rubocop.yml/badge.svg)](https://github.com/o-jill/washcrus/actions/workflows/rubocop.yml)
[![Rspec](https://github.com/o-jill/washcrus/actions/workflows/rspec.yml/badge.svg)](https://github.com/o-jill/washcrus/actions/workflows/rspec.yml)

"WashCrus" will be online shogi match management system.

"WashCrus" was named for "洗足池" which is a pond in Tokyo.

"WashCrus" is written in Ruby.

Lisence:  
Public domain

How to set up:  
1. Clone repo. or unzip WashCrus archive to certain path where is allowed to run CGI script.
2. Edit ./config/mail.yaml.sample and save it as ./config/mail.yaml
3. Edit ./config/signature.txt.sample and save it as ./config/signature.txt
4. Run "bundle install --path vendor/bundle" to get required gems.
5. Run "rake gen_token" to generate KEY to encrypt data.
6. Run "bundle exec rake add_admin" to add first administrator.
7. Run "rake init" to generate db file and change some files/directories's permissions.
8. Visit index.rb by your browser.

ruby path:  
please adjust ruby path to fit your actual ruby path.

Simple backup:  
"rake backup" stores all the data into a tarball in backup directory.  
you can use "backup.sh" after adjusting a path in the script and run it periodically, e.g. once a day.

Enable Time control:  
"periodic_tasks.sh" controls byo-yomi.  
you have to adjust a path in the script and period in minutes.

required "gem"s:  
* bundler
  * jkf(o-jill/jkf, kif_robust_time)
  * mail
  * rake
  * redcarpet
  * reek (for test)
  * rspec (for test)
  * rubocop (for test)
  * unindent

Enable pictures on SNS:  
SNS such as twitter utilize Open Graph Protocol and shows a picture according to a URL in your tweet. this term is for that picture.  
please adjust __SVG2PNG in sfenimage.rb__ according to your converter.  
supported SVG -> PNG converters:
  * Inkscape 0.92  
  * Inkscape 1.*  
  * rsvg-convert  

Other dependends:  
  * Kifu for JS(for replay)  

---
