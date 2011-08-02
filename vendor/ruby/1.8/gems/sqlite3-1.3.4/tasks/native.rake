# use rake-compiler for building the extension
require 'rake/extensiontask'

# NOTE: version used by cross compilation of Windows native extension
# It do not affect compilation under other operating systems
# The version indicated is the minimum DLL suggested for correct functionality
BINARY_VERSION = '3.7.7.1'
URL_VERSION = BINARY_VERSION.tr(".", "0")

# build sqlite3_native C extension
Rake::ExtensionTask.new('sqlite3_native', HOE.spec) do |ext|
  # where to locate the extension
  ext.ext_dir = 'ext/sqlite3'

  # where native extension will be copied (matches makefile)
  ext.lib_dir = "lib/sqlite3"

  # clean binary folders always
  CLEAN.include("#{ext.lib_dir}/?.?")

  # automatically add build options to avoid need of manual input
  if RUBY_PLATFORM =~ /mswin|mingw/ then
    # define target for extension (supporting fat binaries)
    RUBY_VERSION =~ /(\d+\.\d+)/
    ext.lib_dir = "lib/sqlite3/#{$1}"
    ext.config_options << "--enable-local"
  else
    ext.cross_compile = true
    ext.cross_platform = ['i386-mswin32-60', 'i386-mingw32']
    ext.cross_config_options << "--enable-local"
  end
end

# ensure things are compiled prior testing
task :test => [:compile]

# vim: syntax=ruby
