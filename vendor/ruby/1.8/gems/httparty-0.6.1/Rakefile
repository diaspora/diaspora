require 'rake'
require File.expand_path('../lib/httparty', __FILE__)

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "httparty"
    gem.summary     = %Q{Makes http fun! Also, makes consuming restful web services dead easy.}
    gem.description = %Q{Makes http fun! Also, makes consuming restful web services dead easy.}
    gem.email       = "nunemaker@gmail.com"
    gem.homepage    = "http://httparty.rubyforge.org"
    gem.authors     = ["John Nunemaker", "Sandro Turriate"]
    gem.version     = HTTParty::VERSION

    gem.add_dependency 'crack', HTTParty::CRACK_DEPENDENCY

    gem.add_development_dependency "activesupport", "~>2.3"
    gem.add_development_dependency "cucumber", "~>0.7"
    gem.add_development_dependency "fakeweb", "~>1.2"
    gem.add_development_dependency "mongrel", "~>1.1"
    gem.add_development_dependency "rspec", "~>1.3"
    gem.post_install_message = "When you HTTParty, you must party hard!"
    gem.rubyforge_project = 'httparty'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.ruby_opts << '-rubygems'
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts = ['--options', 'spec/spec.opts']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)

  task :features => :check_dependencies
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

task :default => [:spec, :features]

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "httparty #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('lib/httparty.rb')
end

desc 'Upload website files to rubyforge'
task :website do
  sh %{rsync -av website/ jnunemaker@rubyforge.org:/var/www/gforge-projects/httparty}
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = ['--verbose']
  end
rescue LoadError
end
