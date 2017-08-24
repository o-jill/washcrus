"WashCrus" will be online shogi match management system.

"WashCrus" was named for "洗足池" which is a pond in Tokyo.

"WashCrus" is written in Ruby.

Lisence: Public domain

How to set up:
1. Clone repo. or unzip WashCrus archive to certain path where is allowed to run CGI script.
2. Edit ./config/mail.yaml.sample and save it as ./config/mail.yaml
3. Edit ./config/signature.txt.sample and save it as ./config/signature.txt
4. Run "bundle" to get required gems.
5. Run "rake gen_token" to generate KEY to encrypt data.
6. Run "rake init" to generate db file and change some files/directories's permissions.
7. Visit washcrus.rb by your browser.

ruby path:
please adjust ruby path to fit your actual ruby path.

required "gem"s
* bundler
  * jkf(o-jill/jkf, kif_robust_time)
  * mail
  * rake
  * rspec
  * unindent
