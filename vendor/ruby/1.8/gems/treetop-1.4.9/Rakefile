require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

task :default => :spec
Spec::Rake::SpecTask.new do |t|
  t.pattern = 'spec/**/*spec.rb'
  t.libs << 'spec'
end

load "./treetop.gemspec"
Rake::GemPackageTask.new($gemspec) do |pkg|
  pkg.need_tar = true
end

task :spec => 'lib/treetop/compiler/metagrammar.treetop'
file 'lib/treetop/compiler/metagrammar.treetop' do |t|
  unless $bootstrapped_gen_1_metagrammar
    load File.expand_path('../lib/treetop/bootstrap_gen_1_metagrammar.rb', __FILE__)
  end

  Treetop::Compiler::GrammarCompiler.new.compile(METAGRAMMAR_PATH)
end

task :version do
  puts RUBY_VERSION
end

desc 'Generate website files'
task :website_generate do
  `cd doc; ruby ./site.rb`
end

desc 'Upload website files'
task :website_upload do
  rubyforge_config_file = "#{ENV['HOME']}/.rubyforge/user-config.yml"
  rubyforge_config = YAML.load_file(rubyforge_config_file)
  `rsync -aCv doc/site/ #{rubyforge_config['username']}@rubyforge.org:/var/www/gforge-projects/treetop/`
end

desc 'Generate and upload website files'
task :website => [:website_generate, :website_upload]
