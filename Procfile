web: bundle exec unicorn_rails -c config/unicorn.rb -p $PORT
worker: env QUEUE=* bundle exec rake resque:work
