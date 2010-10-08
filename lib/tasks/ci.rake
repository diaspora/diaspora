desc "Run all specs and features"
task :ci => [:environment] do
  system "bundle exec rake"
  raise "tests failed!" unless $?.exitstatus == 0
end