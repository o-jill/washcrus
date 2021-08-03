#!/bin/sh -x

# a script for travis ci

fold_begin() {
  echo -e "travis_fold:start:$1\033[33;1m$2\033[0m"
}

fold_end() {
  echo -e "\ntravis_fold:end:$1\r"
}

fold_begin prepare.1 "application configurations"

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

fold_end prepare.1

if [ "${TRAVIS_BUILD_TYPE}" = "test" ]; then
  fold_begin test.1 "unit test"
  echo "let us TEST !!"
  bundle exec rspec
  ret=$?
  fold_end test.1

  fold_begin test.2 "rubocop"
  bundle exec rubocop
  exitcode=$((ret+$?))
  exit ${exitcode}
  fold_end test.2
else
  fold_begin brtst.1 "browser tests"
  echo "normal . . ."
  # which ruby
  # ruby -v
  ruby travisci/browsertestmain.rb $@
  ret=$?
  if [ ${ret} -ne 0 ]; then
    cat ./log/newgamegenlog.txt
    cat ./log/gamelog.txt
    cat ./log/movelog.txt
    cat ./db/taikyoku.csv
    cat ./db/taikyokuchu.csv
    exit ${ret}
  fi
  fold_end brtst.1
fi
