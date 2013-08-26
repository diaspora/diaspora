web: bundle exec unicorn_rails -c config/unicorn.rb -p $PORT
sidekiq: bundle exec sidekiq -c 2
slow_worker: bundle exec sidekiq -c 2 -q http_service -q dispatch -q receive_local -q mail -q receive -q receive_salmon -q delete_account 
priority_worker: bundle exec sidekiq -c 3 -q socket_webfinger -q photos -q http_service -q dispatch -q mail -q delete_account 
super_slow_worker: bundle exec sidekiq -c 2  -q http -q receive_salmon
salmon: bundle exec sidekiq -c 2 -q receive_salmon 
http: bundle exec sidekiq -c 1 http 

