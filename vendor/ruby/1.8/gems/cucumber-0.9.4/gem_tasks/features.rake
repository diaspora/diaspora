$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cucumber/rake/task'
require 'cucumber/platform'

Cucumber::Rake::Task.new do |t|
  if(Cucumber::JRUBY)
    t.profile = Cucumber::WINDOWS ? 'jruby_win' : 'jruby'
  elsif(Cucumber::WINDOWS_MRI)
    t.profile = 'windows_mri'
  elsif(Cucumber::RUBY_1_9)
    t.profile = 'ruby_1_9'
  end
  t.rcov = ENV['RCOV']
end
