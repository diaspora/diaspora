namespace :cruise do
  desc "Run all specs and features"
  task :cruise => [:environment, :'cruise:migrate'] do
    puts "Starting virtual display..."
    `sh -e /etc/init.d/xvfb start`
    puts "Starting specs..."
    system('export DISPLAY=:99.0 && export SELENIUM_SERVER_PORT=53809 && bundle exec rake')
    exit_status = $?.exitstatus
    puts "Stopping virtual display..."
    `sh -e /etc/init.d/xvfb stop`
    puts "Cleaning up..."
    FileUtils.rm_rf("#{Rails.root}/public/uploads/images")
    FileUtils.rm_rf("#{Rails.root}/public/uploads/tmp")
    raise "tests failed!" unless exit_status == 0
    puts "All tests passed!"
  end

  task :migrate do
    system('bundle exec rake db:migrate')
    exit_status = $?.exitstatus
    raise "db:migrate failed!" unless exit_status == 0
  end
end
task :cruise => "cruise:cruise"
