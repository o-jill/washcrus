#!/bin/sh
#
# shell script for cron.
#
# cron setting example:
#  */10 * * * * /home/nob-aoki/www/cgi-bin/washcrus/periodic_tasks.sh
#         > /home/nob-aoki/www/cgi-bin/washcrus/periodic_tasks.log
#

# period in minutes to check something in this program.
PERIOD_MIN=10

cd /home/nob-aoki/www/cgi-bin/washcrus/

ruby ./observer/byouyomichan.rb $PERIOD_MIN
# bundle exec ruby ./observer/byouyomichan.rb $PERIOD_MIN
