cron "user stats" do
  minute 42
  hour 15
  command "cd /usr/local/app/diaspora && exec /usr/local/bin/ruby /usr/local/bin/bundle exec rake --trace statistics:users_splunk &> /usr/local/app/diaspora/log/stats.log"
end

cron "backup mysql" do
  minute 0
  command "cd /usr/local/app/diaspora && exec /usr/local/bin/ruby /usr/local/bin/bundle exec rake --trace backup:mysql"
end
