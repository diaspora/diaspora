require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require 'spec/rake/spectask'

GEM = "ohai"
GEM_VERSION = "0.5.8"
AUTHOR = "Adam Jacob"
EMAIL = "adam@opscode.com"
HOMEPAGE = "http://wiki.opscode.com/display/ohai"
SUMMARY = "Ohai profiles your system and emits JSON"

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE

  s.add_dependency "json", ">= 1.4.4", "<= 1.4.6"
  s.add_dependency "extlib"
  s.add_dependency "systemu"
  s.add_dependency "mixlib-cli"
  s.add_dependency "mixlib-config"
  s.add_dependency "mixlib-log"
  s.bindir = "bin"
  s.executables = %w(ohai)
  
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README.rdoc Rakefile) + Dir.glob("{docs,lib,spec}/**/*")
end

task :default => :spec

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-fs --color)
end


Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end
