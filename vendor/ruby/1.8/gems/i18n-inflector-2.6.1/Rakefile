# encoding: utf-8
# -*- ruby -*-

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'rubygems'
require 'bundler/setup'

require "rake"
require "rake/clean"

require "fileutils"
require 'i18n-inflector/version'

require 'hoe'

task :default do
  Rake::Task[:test].invoke
  Rake::Task[:test].reenable
  Rake::Task[:testv4].invoke
end

# Update Gemfile for I18n in version 4
task :gemfilev4 do
  gemprev = ENV['BUNDLE_GEMFILE']
  ENV['BUNDLE_GEMFILE'] = 'ci/i18nv4-Gemfile'
  `rake bundler:gemfile`
  ENV['BUNDLE_GEMFILE'] = gemprev
end

# Tests for I18n in version 4
task :testv4 do
  gemprev = ENV['BUNDLE_GEMFILE']
  ENV['BUNDLE_GEMFILE'] = 'ci/i18nv4-Gemfile'
  `bundle install`
  Rake::Task[:test].invoke
  ENV['BUNDLE_GEMFILE'] = gemprev
end

desc "install by setup.rb"
task :install do
  sh "sudo ruby setup.rb install"
end

### Gem

Hoe.plugin :bundler
Hoe.plugin :yard

Hoe.spec 'i18n-inflector' do
  developer               I18n::Inflector::DEVELOPER, I18n::Inflector::EMAIL

  self.version         =  I18n::Inflector::VERSION
  self.rubyforge_name  =  I18n::Inflector::NAME
  self.summary         =  I18n::Inflector::SUMMARY
  self.description     =  I18n::Inflector::DESCRIPTION
  self.url             =  I18n::Inflector::URL

  self.test_globs      = %w(test/**/*_test.rb)

  self.remote_rdoc_dir = ''
  self.rsync_args      << '--chmod=a+rX'
  self.readme_file     = 'README.rdoc'
  self.history_file    = 'docs/HISTORY'

  extra_deps          << ['i18n',             '>= 0.4.1']
  extra_dev_deps      << ['test_declarative', '>= 0.0.5']   <<
                         ['yard',             '>= 0.7.2']   <<
                         ['rdoc',             '>= 3.8.0']   <<
                         ['bundler',          '>= 1.0.15']  <<
                         ['hoe-bundler',      '>= 1.1.0']

  unless extra_dev_deps.flatten.include?('hoe-yard')
    extra_dev_deps << ['hoe-yard', '>= 0.1.2']
  end

end

task 'Manifest.txt' do
  puts 'generating Manifest.txt from git'
  sh %{git ls-files | grep -v gitignore > Manifest.txt}
  sh %{git add Manifest.txt}
end

task 'ChangeLog' do
  sh %{git log > ChangeLog}
end

desc "Fix documentation's file permissions"
task :docperm do
  sh %{chmod -R a+rX doc}
end

### Sign & Publish

desc "Create signed tag in Git"
task :tag do
  sh %{git tag -s v#{I18n::Inflector::VERSION} -m 'version #{I18n::Inflector::VERSION}'}
end

desc "Create external GnuPG signature for Gem"
task :gemsign do
  sh %{gpg -u #{I18n::Inflector::EMAIL} -ab pkg/#{I18n::Inflector::NAME}-#{I18n::Inflector::VERSION}.gem \
           -o pkg/#{I18n::Inflector::NAME}-#{I18n::Inflector::VERSION}.gem.sig}
end

