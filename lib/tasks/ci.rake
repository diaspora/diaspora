desc "Run all specs and features"
task :ci => [:environment] do
  system "bundle exec rake"
end