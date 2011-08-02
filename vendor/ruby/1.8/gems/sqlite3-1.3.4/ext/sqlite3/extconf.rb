ENV['RC_ARCHS'] = '' if RUBY_PLATFORM =~ /darwin/

require 'mkmf'

# :stopdoc:

RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

# --with-sqlite3-{dir,include,lib}
dir_config("sqlite3")

# prioritize local builds
if enable_config("local", false)
  $LDFLAGS = ENV.fetch("LDFLAGS", nil)
end

if RbConfig::CONFIG["host_os"] =~ /mswin/
  $CFLAGS << ' -W3'
end

def asplode missing
  if RUBY_PLATFORM =~ /mingw|mswin/
    abort "#{missing} is missing. Install SQLite3 from " +
          "http://www.sqlite.org/ first."
  else
    abort <<-error
#{missing} is missing. Try 'port install sqlite3 +universal'
or 'yum install sqlite3-devel' and check your shared library search path (the
location where your sqlite3 shared library is located).
    error
  end
end

asplode('sqlite3.h')  unless find_header  'sqlite3.h'
asplode('sqlite3') unless find_library 'sqlite3', 'sqlite3_libversion_number'

# Functions defined in 1.9 but not 1.8
have_func('rb_proc_arity')

# These functions may not be defined
have_func('sqlite3_initialize')
have_func('sqlite3_backup_init')
have_func('sqlite3_column_database_name')
have_func('sqlite3_enable_load_extension')
have_func('sqlite3_load_extension')

create_makefile('sqlite3/sqlite3_native')
