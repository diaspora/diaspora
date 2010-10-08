desc "Run all specs and features"
task :ci => [:environment] do
  system "export DISPLAY=:99"
  system "/etc/init.d/xvfb start"
  system "bundle exec rake"
  exit_status = $?.exitstatus
  system "/etc/init.d/xvfb stop"
  raise "tests failed!" unless exit_status == 0
end