TODO:
1. re add airbrake
2. re add newrelic
3. fix asset_sync

#Resque.workers.each {|w| w.unregister_worker}

#how I deploy jd.com to heroku
git pull
git checkout joindiapsora
git rebase TAGNUMBER
bundle

git add .

git commit -am 'updating gemfile.lock'

steps:

1. heroku maintenance:on -a diaspora-production
2. make sure all resque jobs are done.

3. heroku scale slow_worker=0 super_slow_worker=0 catchall_worker=0 priority_worker=0


4. add sidekiq config
heroku config:add SIDEKIQ_CONCURRENCY=2  SIDEKIQ_RETRY=3 -a diaspora-production


git push heroku joindiaspora:master -f
5. heroku run rake db:migrate -a diaspora-production

heroku run rake db:migrate
heroku run 'rails runner "AssetSync.sync"' && heroku restart  && heroku maintenance:off -a diaspora-production

heroku maintenance:off -a diaspora-production


kill heroku old cron jobs
=== http (2X): `bundle exec sidekiq -c 1 http`
http.1: up 2013/08/25 19:08:53 (~ 11m ago)
http.2: up 2013/08/25 19:08:54 (~ 11m ago)

=== priority_worker (1X): `bundle exec sidekiq -c 3 -q socket_webfinger -q photos -q http_service -q dispatch -q mail -q delete_account`
priority_worker.1: up 2013/08/25 19:08:53 (~ 11m ago)
priority_worker.2: up 2013/08/25 19:08:53 (~ 11m ago)

=== salmon (2X): `bundle exec sidekiq -c 2 -q receive_salmon`
salmon.1: up 2013/08/25 19:08:55 (~ 11m ago)
salmon.2: up 2013/08/25 19:08:50 (~ 11m ago)

=== slow_worker (1X): `bundle exec sidekiq -c 2 -q http_service -q dispatch -q receive_local -q mail -q receive -q receive_salmon -q delete_account`
slow_worker.1: up 2013/08/25 19:08:50 (~ 11m ago)
slow_worker.2: up 2013/08/25 19:08:58 (~ 11m ago)
slow_worker.3: up 2013/08/25 19:08:55 (~ 11m ago)
slow_worker.4: up 2013/08/25 19:08:53 (~ 11m ago)

=== super_slow_worker (1X): `bundle exec sidekiq -c 2  -q http -q receive_salmon`
super_slow_worker.1: up 2013/08/25 19:08:52 (~ 11m ago)
super_slow_worker.2: up 2013/08/25 19:08:53 (~ 11m ago)
super_slow_worker.3: up 2013/08/25 19:08:53 (~ 11m ago)
super_slow_worker.4: up 2013/08/25 19:08:52 (~ 11m ago)

=== web (1X): `bundle exec unicorn_rails -c config/unicorn.rb -p $PORT`
web.1: up 2013/08/25 19:09:10 (~ 11m ago)
web.2: up 2013/08/25 19:09:22 (~ 11m ago)
web.3: up 2013/08/25 19:09:51 (~ 10m ago)
web.4: up 2013/08/25 19:09:26 (~ 11m ago)

