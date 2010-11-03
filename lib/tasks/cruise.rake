namespace :cruise do
  desc "Run all specs and features"
  task :cruise => :environment do
    puts "Starting virtual display..."
    `sh -e /etc/init.d/xvfb start`
    puts "Starting specs..."
    system('export DISPLAY=:99.0 && export SELENIUM_SERVER_PORT=53809 && bundle exec rake')
    exit_status = $?.exitstatus
    puts "Stopping virtual display..."
    `sh -e /etc/init.d/xvfb stop`
    raise "tests failed!" unless exit_status == 0
  end
end
task :cruise => "cruise:cruise"
