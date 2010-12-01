require 'rubygems'
require 'rake'
require 'tmpdir'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "childprocess"
    gem.summary = %Q{Cross-platform ruby library for managing child processes.}
    gem.description = %Q{This gem aims at being a simple and reliable solution for controlling external programs running in the background on any Ruby / OS combination.}
    gem.email = "jari.bakken@gmail.com"
    gem.homepage = "http://github.com/jarib/childprocess"
    gem.authors = ["Jari Bakken"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"

    gem.add_dependency "ffi", "~> 0.6.3"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = %w[--exclude spec,ruby-debug,/Library/Ruby,.gem --include lib/childprocess]
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

task :clean do
  rm_rf "pkg"
  rm_rf "childprocess.jar"
end

desc 'Create jar to bundle in selenium-webdriver'
task :jar => [:clean, :build] do
  tmpdir = Dir.mktmpdir("childprocess-jar")
  gem_to_package = Dir['pkg/*.gem'].first
  gem_name = File.basename(gem_to_package, ".gem")
  p :gem_to_package => gem_to_package, :gem_name => gem_name
  
  sh "gem install -i #{tmpdir} #{gem_to_package} --ignore-dependencies --no-rdoc --no-ri"
  sh "jar cf childprocess.jar -C #{tmpdir}/gems/#{gem_name}/lib ."
  sh "jar tf childprocess.jar"
end
