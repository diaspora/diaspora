web: bundle exec unicorn -c config/unicorn.rb -p $PORT
worker: env QUEUE=* bundle exec rake resque:work