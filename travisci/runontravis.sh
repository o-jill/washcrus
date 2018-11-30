#!/bin/sh

# a script for travis ci

if [ "${TRAVIS_BUILD_TYPE}" = "test" ]; then
  echo "let us TEST !!"
  bundle exec rspec
  bundle exec rubocop
else
  cp config/settings.yaml.sample config/settings.yaml
  cp config/mail.yaml.sample config/mail.yaml
  cp config/signature.txt.sample config/signature.txt
  rake gen_token
  bundle exec rake add_admin << ADMININFO
admin1
admin1@example.com
admin1@example.com
admin
admin
ADMININFO
  rake init
fi
