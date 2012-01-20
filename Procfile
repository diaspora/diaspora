web: bundle exec rails s thin -p $PORT
redis: redis-server
catchall_worker: env QUEUE=* bundle exec rake resque:work
slow_worker: env QUEUES=socket_webfinger,photos,http_service,receive_local,mail,receive,receive_salmon,http,delete_account bundle exec rake resque:work
priority_worker: env QUEUES=socket_webfinger,photos,http_service,mail,delete_account bundle exec rake resque:work
