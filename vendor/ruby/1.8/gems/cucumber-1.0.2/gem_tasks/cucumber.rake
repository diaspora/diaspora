require 'cucumber/rake/task'
require 'cucumber/platform'

Cucumber::Rake::Task.new(:features) do |t|
  t.fork = false
end

Cucumber::Rake::Task.new(:legacy_features) do |t|
  t.fork = false
  t.cucumber_opts = %w{legacy_features}
  if(Cucumber::JRUBY)
    t.profile = Cucumber::WINDOWS ? 'jruby_win' : 'jruby'
  elsif(Cucumber::WINDOWS_MRI)
    t.profile = 'windows_mri'
  elsif(Cucumber::RUBY_1_9)
    t.profile = 'ruby_1_9'
  end
  t.rcov = ENV['RCOV']
end

task :cucumber => [:features, :legacy_features]