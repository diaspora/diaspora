require 'rspec/core/rake_task'

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.rcov = ENV['RCOV']
  t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
  t.verbose = true
end
