#!/bin/sh -x

# a script for travis ci

cp config/settings.yaml.sample config/settings.yaml
# cp config/mail.yaml.sample config/mail.yaml
cp config/mail.yaml.mailcatcher config/mail.yaml
cp config/signature.txt.sample config/signature.txt
rake gen_token
bundle exec rake add_admin << ADMININFO
admin1
admin1@example.com
admin1@example.com
admin
admin
ADMININFO
cat ./db/userinfo.csv
rake init

if [ "${TRAVIS_BUILD_TYPE}" = "test" ]; then
  echo "let us TEST !!"
  bundle exec rspec
  ret=$?
  bundle exec rubocop
  exitcode=$((ret+$?))
  exit ${exitcode}
else
  echo "normal . . ."
  # which ruby
  # ruby -v
  ruby travisci/browsertest.rb
fi
