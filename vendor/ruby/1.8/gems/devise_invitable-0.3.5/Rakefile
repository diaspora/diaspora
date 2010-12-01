require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "devise_invitable"
    gem.summary = %Q{An invitation strategy for devise}
    gem.description = %Q{It adds support for send invitations by email (it requires to be authenticated) and accept the invitation setting the password}
    gem.email = "sergio@entrecables.com"
    gem.homepage = "http://github.com/scambra/devise_invitable"
    gem.authors = ["Sergio Cambra"]
    gem.add_development_dependency 'mocha', '>= 0.9.8'
    gem.add_development_dependency 'capybara', '>= 0.3.9'
    gem.add_development_dependency 'rails', '~> 3.0.0'
    gem.add_development_dependency 'sqlite3-ruby'
    gem.add_dependency 'devise', '~> 1.1.0'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "devise_invitable #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
