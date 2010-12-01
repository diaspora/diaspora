require 'rake/gempackagetask'
require 'cucumber/rake/task'

eval("$specification = #{IO.read('factory_girl_rails.gemspec')}")
Rake::GemPackageTask.new($specification) do |package|
  package.need_zip = true
  package.need_tar = true
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.fork = true
  t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'progress')]
end

desc "Default: run the cucumber scenarios"
task :default => :cucumber
