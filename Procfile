redis:     redis-server
websocket: ruby script/websocket_server.rb
web:       bundle exec rails s thin -p $PORT
worker:    QUEUE=* rake resque:work
