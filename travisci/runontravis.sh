#!/bin/sh

# a script for travis ci

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
  cp config/settings.yaml.sample config/settings.yaml
  cp config/mail.yaml.sample config/mail.yaml
  cp config/signature.txt.sample config/signature.txt
  bundle exec rspec
  bundle exec rubocop
else
#   bundle exec rake add_admin << ADMININFO
# admin1
# admin1@example.com
# admin1@example.com
# admin
# admin
# ADMININFO
fi
