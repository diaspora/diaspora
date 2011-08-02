gem 'rake-compiler', '~> 0.7.1'
require "rake/extensiontask"

MYSQL_VERSION = "5.1.51"
MYSQL_MIRROR  = ENV['MYSQL_MIRROR'] || "http://mysql.he.net/"

def gemspec
  @clean_gemspec ||= eval(File.read(File.expand_path('../../mysql2.gemspec', __FILE__)))
end

Rake::ExtensionTask.new("mysql2", gemspec) do |ext|
  # reference where the vendored MySQL got extracted
  mysql_lib = File.expand_path(File.join(File.dirname(__FILE__), '..', 'vendor', "mysql-#{MYSQL_VERSION}-win32"))

  # DRY options feed into compile or cross-compile process
  windows_options = [
    "--with-mysql-include=#{mysql_lib}/include",
    "--with-mysql-lib=#{mysql_lib}/lib/opt"
  ]

  # automatically add build options to avoid need of manual input
  if RUBY_PLATFORM =~ /mswin|mingw/ then
    ext.config_options = windows_options
  else
    ext.cross_compile = true
    ext.cross_platform = ['x86-mingw32', 'x86-mswin32-60']
    ext.cross_config_options = windows_options

    # inject 1.8/1.9 pure-ruby entry point when cross compiling only
    ext.cross_compiling do |spec|
      spec.files << 'lib/mysql2/mysql2.rb'
    end
  end

  ext.lib_dir = File.join 'lib', 'mysql2'

  # clean compiled extension
  CLEAN.include "#{ext.lib_dir}/*.#{RbConfig::CONFIG['DLEXT']}"
end
Rake::Task[:spec].prerequisites << :compile

file 'lib/mysql2/mysql2.rb' do |t|
  name = gemspec.name
  File.open(t.name, 'wb') do |f|
    f.write <<-eoruby
RUBY_VERSION =~ /(\\d+.\\d+)/
require "#{name}/\#{$1}/#{name}"
    eoruby
  end
end

if Rake::Task.task_defined?(:cross)
  Rake::Task[:cross].prerequisites << "lib/mysql2/mysql2.rb"
end
