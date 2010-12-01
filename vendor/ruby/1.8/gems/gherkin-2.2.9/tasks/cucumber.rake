require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = "--profile default"
end

namespace :cucumber do
  Cucumber::Rake::Task.new(:rcov, "Run Cucumber using RCov") do |t|
    t.cucumber_opts = "--profile default"
    t.rcov = true
    t.rcov_opts = %w{--exclude spec\/}
  end

  Cucumber::Rake::Task.new(:native_lexer, "Run Native lexer Cucumber features") do |t|
    t.cucumber_opts = "--profile native_lexer"
  end
  task :native_lexer => [:clean, :compile]
end
