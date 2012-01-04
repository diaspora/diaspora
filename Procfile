web:       bundle exec rails s thin -p $PORT
redis:     redis-server
worker:    QUEUE=* bundle exec rake resque:work
