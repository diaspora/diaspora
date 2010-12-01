# Fail if the C extension module isn't installed.
#
# Only really intended to be used by internal build scripts.

require 'rubygems'
require 'mongo'
begin
  require 'bson_ext/cbson'
rescue LoadError
  Process.exit 1
end
