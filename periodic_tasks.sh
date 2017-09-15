#!/bin/sh
#
# shell script for cron.
#

cd /home/nob-aoki/www/cgi-bin/washcrus/

ruby ./observer/byouyomichan.rb
# bundle exec ruby ./observer/byouyomichan.rb

