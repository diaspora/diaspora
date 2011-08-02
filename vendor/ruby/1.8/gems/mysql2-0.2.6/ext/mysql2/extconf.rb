# encoding: UTF-8
require 'mkmf'

def asplode lib
  abort "-----\n#{lib} is missing.  please check your installation of mysql and try again.\n-----"
end

# 1.9-only
have_func('rb_thread_blocking_region')

# borrowed from mysqlplus
# http://github.com/oldmoe/mysqlplus/blob/master/ext/extconf.rb
dirs = ENV['PATH'].split(File::PATH_SEPARATOR) + %w[
  /opt
  /opt/local
  /opt/local/mysql
  /opt/local/lib/mysql5
  /usr
  /usr/local
  /usr/local/mysql
  /usr/local/mysql-*
  /usr/local/lib/mysql5
].map{|dir| "#{dir}/bin" }

GLOB = "{#{dirs.join(',')}}/{mysql_config,mysql_config5}"

if RUBY_PLATFORM =~ /mswin|mingw/
  inc, lib = dir_config('mysql')
  exit 1 unless have_library("libmysql")
elsif mc = (with_config('mysql-config') || Dir[GLOB].first) then
  mc = Dir[GLOB].first if mc == true
  cflags = `#{mc} --cflags`.chomp
  exit 1 if $? != 0
  libs = `#{mc} --libs`.chomp
  exit 1 if $? != 0
  $CPPFLAGS += ' ' + cflags
  $libs = libs + " " + $libs
else
  inc, lib = dir_config('mysql', '/usr/local')
  libs = ['m', 'z', 'socket', 'nsl', 'mygcc']
  while not find_library('mysqlclient', 'mysql_query', lib, "#{lib}/mysql") do
    exit 1 if libs.empty?
    have_library(libs.shift)
  end
end

if have_header('mysql.h') then
  prefix = nil
elsif have_header('mysql/mysql.h') then
  prefix = 'mysql'
else
  asplode 'mysql.h'
end

%w{ errmsg.h mysqld_error.h }.each do |h|
  header = [prefix, h].compact.join '/'
  asplode h unless have_header h
end

unless RUBY_PLATFORM =~ /mswin/ or RUBY_PLATFORM =~ /sparc/
  $CFLAGS << ' -Wall -funroll-loops'
end
# $CFLAGS << ' -O0 -ggdb3 -Wextra'

create_makefile('mysql2/mysql2')
