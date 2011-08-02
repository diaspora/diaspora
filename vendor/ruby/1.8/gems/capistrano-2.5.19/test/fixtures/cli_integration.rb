role :test, "www.capistrano.test"

task :testing, :roles => :test do
  set :testing_occurred, true
end
