web1: env RAILS_ENV=integration1 bundle exec rails s -p 3001
worker1: env RAILS_ENV=integration1 VVERBOSE=1 QUEUE=* bundle exec rake resque:work
redis1: env RAILS_ENV=integration1 redis-server ./redis-integration1.conf
web2: env RAILS_ENV=integration2 bundle exec rails s -p 3002
worker2: env RAILS_ENV=integration2 VVERBOSE=1 QUEUE=* bundle exec rake resque:work
redis2: env RAILS_ENV=integration2 redis-server ./redis-integration2.conf