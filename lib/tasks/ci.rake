desc "Run all specs and features"
task :ci => [:environment] do
  system "bundle install"
  system "bundle exec rake"
end