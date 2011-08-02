# encoding: utf-8
# -*- ruby -*-

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'rubygems'
require 'bundler/setup'

require "rake"
require "rake/clean"

require "fileutils"
require "i18n-inflector"

require 'i18n-inflector-rails/version'
require 'hoe'

task :default => [:test]

desc "install by setup.rb"
task :install do
  sh "sudo ruby setup.rb install"
end

### Gem

Hoe.plugin :bundler
Hoe.plugin :yard

Hoe.spec 'i18n-inflector-rails' do
  developer               I18n::Inflector::Rails::DEVELOPER, I18n::Inflector::Rails::EMAIL

  self.version         =  I18n::Inflector::Rails::VERSION
  self.rubyforge_name  =  I18n::Inflector::Rails::NAME
  self.summary         =  I18n::Inflector::Rails::SUMMARY
  self.description     =  I18n::Inflector::Rails::DESCRIPTION
  self.url             =  I18n::Inflector::Rails::URL

  self.remote_rdoc_dir = ''
  self.rsync_args      << '--chmod=a+rX'
  self.readme_file     = 'README.rdoc'
  self.history_file    = 'docs/HISTORY'

  extra_deps          << ['i18n-inflector',   '~> 2.6'] <<
                         ['railties',         '~> 3.0'] <<
                         ['actionpack',       '~> 3.0']
  extra_dev_deps      << ['rspec',            '>= 2.6.0']   <<
                         ['yard',             '>= 0.7.2']   <<
                         ['rdoc',             '>= 3.8.0']   <<
                         ['bundler',          '>= 1.0.10']  <<
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
  sh %{git tag -s v#{I18n::Inflector::Rails::VERSION} -m 'version #{I18n::Inflector::Rails::VERSION}'}
end

desc "Create external GnuPG signature for Gem"
task :gemsign do
  sh %{gpg -u #{I18n::Inflector::Rails::EMAIL} -ab pkg/#{I18n::Inflector::Rails::NAME}-#{I18n::Inflector::Rails::VERSION}.gem \
           -o pkg/#{I18n::Inflector::Rails::NAME}-#{I18n::Inflector::Rails::VERSION}.gem.sig}
end

