# -*- ruby -*-

require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'

windows = RUBY_PLATFORM =~ /(mswin|mingw)/i
java    = RUBY_PLATFORM =~ /java/

GENERATED_PARSER    = "lib/nokogiri/css/generated_parser.rb"
GENERATED_TOKENIZER = "lib/nokogiri/css/generated_tokenizer.rb"
CROSS_DIR           = File.join(File.dirname(__FILE__), 'tmp', 'cross')

# Make sure hoe-debugging is installed
Hoe.plugin :debugging

HOE = Hoe.spec 'nokogiri' do
  developer('Aaron Patterson', 'aaronp@rubyforge.org')
  developer('Mike Dalessio', 'mike.dalessio@gmail.com')
  self.readme_file   = ['README', ENV['HLANG'], 'rdoc'].compact.join('.')
  self.history_file  = ['CHANGELOG', ENV['HLANG'], 'rdoc'].compact.join('.')
  self.extra_rdoc_files  = FileList['*.rdoc','ext/nokogiri/*.c']
  self.clean_globs = [
    'lib/nokogiri/*.{o,so,bundle,a,log,dll}',
    'lib/nokogiri/nokogiri.rb',
    'lib/nokogiri/1.{8,9}',
    GENERATED_PARSER,
    GENERATED_TOKENIZER,
    'cross',
  ]

  %w{ racc rexical rake-compiler }.each do |dep|
    self.extra_dev_deps << [dep, '>= 0']
  end
  self.extra_dev_deps << ["minitest", ">= 1.6.0"]

  self.spec_extras = { :extensions => ["ext/nokogiri/extconf.rb"] }

  self.testlib = :minitest
end
Hoe.add_include_dirs '.'

task :ws_docs do
  title = "#{HOE.name}-#{HOE.version} Documentation"

  options = []
  options << "--main=#{HOE.readme_file}"
  options << '--format=activerecord'
  options << '--threads=1'
  options << "--title=#{title.inspect}"

  options += HOE.spec.require_paths
  options += HOE.spec.extra_rdoc_files
  require 'rdoc/rdoc'
  ENV['RAILS_ROOT'] ||= File.expand_path(File.join('..', 'nokogiri_ws'))
  RDoc::RDoc.new.document options
end

unless java
  gem 'rake-compiler', '>= 0.4.1'
  require "rake/extensiontask"

  RET = Rake::ExtensionTask.new("nokogiri", HOE.spec) do |ext|
    ext.lib_dir = File.join(*['lib', 'nokogiri', ENV['FAT_DIR']].compact)

    ext.config_options << ENV['EXTOPTS']
    ext.cross_compile   = true
    ext.cross_platform  = 'i386-mingw32'
    ext.cross_config_options <<
      "--with-xml2-include=#{File.join(CROSS_DIR, 'include', 'libxml2')}"
    ext.cross_config_options <<
      "--with-xml2-lib=#{File.join(CROSS_DIR, 'lib')}"
    ext.cross_config_options << "--with-iconv-dir=#{CROSS_DIR}"
    ext.cross_config_options << "--with-xslt-dir=#{CROSS_DIR}"
    ext.cross_config_options << "--with-zlib-dir=#{CROSS_DIR}"
  end
end

namespace :gem do
  namespace :dev do
    task :spec => [ GENERATED_PARSER, GENERATED_TOKENIZER ] do
      File.open("#{HOE.name}.gemspec", 'w') do |f|
        HOE.spec.version = "#{HOE.version}.#{Time.now.strftime("%Y%m%d%H%M%S")}"
        f.write(HOE.spec.to_ruby)
      end
    end
  end

  desc "Build a gem targetted for JRuby"
  task :jruby => ['gem:jruby:spec'] do
    system "gem build nokogiri.gemspec"
    FileUtils.mkdir_p "pkg"
    FileUtils.mv Dir.glob("nokogiri*-java.gem"), "pkg"
  end

  namespace :jruby do
    task :spec => [GENERATED_PARSER, GENERATED_TOKENIZER] do
      File.open("#{HOE.name}.gemspec", 'w') do |f|
        HOE.spec.platform = 'java'
        HOE.spec.files << GENERATED_PARSER
        HOE.spec.files << GENERATED_TOKENIZER
        HOE.spec.files += Dir["ext/nokogiri/*.dll"]
        HOE.spec.extensions = []
        HOE.spec.add_dependency 'weakling', '>= 0.0.3'
        f.write(HOE.spec.to_ruby)
      end
    end
  end

  task :spec => ['gem:dev:spec']
end

file GENERATED_PARSER => "lib/nokogiri/css/parser.y" do |t|
  begin
    racc = Config::CONFIG['target_os'] =~ /mswin32/ ? '' : `which racc`.strip
    racc = "#{::Config::CONFIG['bindir']}/racc" if racc.empty?
    sh "#{racc} -l -o #{t.name} #{t.prerequisites.first}"
  rescue
    abort "need racc, sudo gem install racc"
  end
end

file GENERATED_TOKENIZER => "lib/nokogiri/css/tokenizer.rex" do |t|
  begin
    sh "rex --independent -o #{t.name} #{t.prerequisites.first}"
  rescue
    abort "need rexical, sudo gem install rexical"
  end
end

require 'tasks/test'
begin
  require 'tasks/cross_compile' unless java
rescue RuntimeError => e
  warn "WARNING: Could not perform some cross-compiling: #{e}"
end

desc "set environment variables to build and/or test with debug options"
task :debug do
  ENV['NOKOGIRI_DEBUG'] = "true"
  ENV['CFLAGS'] ||= ""
  ENV['CFLAGS'] += " -DDEBUG"
end

# required_ruby_version

# Only do this on unix, since we can't build on windows
unless windows || java || ENV['NOKOGIRI_FFI']
  [:compile, :check_manifest].each do |task_name|
    Rake::Task[task_name].prerequisites << GENERATED_PARSER
    Rake::Task[task_name].prerequisites << GENERATED_TOKENIZER
  end

  Rake::Task[:test].prerequisites << :compile
  if Hoe.plugins.include?(:debugging)
    ['valgrind', 'valgrind:mem', 'valgrind:mem0'].each do |task_name|
      Rake::Task["test:#{task_name}"].prerequisites << :compile
    end
  end
else
  [:test, :check_manifest].each do |task_name|
    if Rake::Task[task_name]
      Rake::Task[task_name].prerequisites << GENERATED_PARSER
      Rake::Task[task_name].prerequisites << GENERATED_TOKENIZER
    end
  end
end

namespace :install do
  desc "Install rex and racc for development"
  task :deps => %w(rexical racc)

  task :racc do |t|
    sh "sudo gem install racc"
  end

  task :rexical do
    sh "sudo gem install rexical"
  end
end

namespace :rip do
  task :install => [GENERATED_TOKENIZER, GENERATED_PARSER]
end

# vim: syntax=Ruby
