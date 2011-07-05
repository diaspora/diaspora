namespace :cruise do
  desc "Run all specs and features"
  task :cruise => [:environment, :'cruise:migrate'] do
    puts "Starting virtual display..."
    `sh -e /etc/init.d/xvfb start`
    puts "Starting specs..."
    system('export DISPLAY=:99.0 && CI=true bundle exec rake')
    exit_status = $?.exitstatus
    puts "Stopping virtual display..."
    `sh -e /etc/init.d/xvfb stop`
    puts "Cleaning up..."
    FileUtils.rm_rf("#{Rails.root}/public/uploads/images")
    FileUtils.rm_rf("#{Rails.root}/public/uploads/tmp")
    raise "tests failed!" unless exit_status == 0
    puts "All tests passed!"
  end

  task :migrate => ['db:drop', 'db:create', 'db:schema:load'] do
    system('bundle exec rake db:test:prepare')
    raise "migration failed!" unless $?.exitstatus == 0
  end

  task :travis do
    ["rspec spec", "rake cucumber", "jasmine:ci"].each do |cmd|
      system("bundle exec #{cmd}")
      raise "#{cmd} failed!" unless $?.exitstatus == 0
    end
  end
end
task :cruise => "cruise:cruise"
task :travis => "cruise:travis"
