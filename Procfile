web:       bundle exec rails s thin -p $PORT
redis:     redis-server
websocket: ruby script/websocket_server.rb
worker:    QUEUE=* bundle exec rake resque:work
