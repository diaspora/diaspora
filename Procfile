web: bundle exec unicorn -c config/unicorn.rb -p $PORT
redis: redis-server
catchall_worker: env QUEUE=* bundle exec rake resque:work
slow_worker: env QUEUES=socket_webfinger,photos,http_service,dispatch,receive_local,mail,receive,receive_salmon,http,delete_account bundle exec rake resque:work
priority_worker: env QUEUES=socket_webfinger,photos,http_service,dispatch,mail,delete_account bundle exec rake resque:work
super_slow_worker: env QUEUE=http,receive_salmon bundle exec rake resque:work