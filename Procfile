web: bundle exec unicorn -c config/unicorn.rb -p $PORT
redis: redis-server
worker: QUEUE=* bundle exec rake resque:work
