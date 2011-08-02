# Test suite for the DBI tests.  No DBD tests are run as part of this
# test suite.
Dir.chdir("..") if File.basename(Dir.pwd) == "test"
$LOAD_PATH.unshift(Dir.pwd + "/lib")
Dir.chdir("test") rescue nil

require 'dbi/tc_columninfo'
require 'dbi/tc_date'
require 'dbi/tc_dbi'
require 'dbi/tc_row'
require 'dbi/tc_sqlbind'
require 'dbi/tc_statementhandle'
require 'dbi/tc_time'
require 'dbi/tc_timestamp'
require 'dbi/tc_types'
