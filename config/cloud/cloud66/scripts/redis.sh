#!/bin/bash
FILE=/tmp/redis_done

if [ -f $FILE ]
then
	echo "File $FILE exists..."
else
	source /var/.cloud66_env
    cd $RAILS_STACK_PATH
    echo "
    production:
      environment:
        redis: redis://$REDIS_ADDRESS:6379
    development:
      environment:
        redis: redis://$REDIS_ADDRESS:6379" >> config/diaspora.yml
    sudo bluepill cloud66_web_server stop
    sudo bluepill load /etc/bluepill/autoload/cloud66_web_server.pill
    service nginx restart
    touch /tmp/redis_done
fi