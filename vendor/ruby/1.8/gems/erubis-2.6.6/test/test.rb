##
## $Release: 2.6.6 $
## copyright(c) 2006-2010 kuwata-lab.com all rights reserved.
##


unless defined?(TESTDIR)
  TESTDIR = File.dirname(__FILE__)
  LIBDIR  = TESTDIR == '.' ? '../lib' : File.dirname(TESTDIR) + '/lib'
  $: << TESTDIR
  $: << LIBDIR
end


require 'test/unit'
#require 'test/unit/ui/console/testrunner'
require 'assert-text-equal'
require 'yaml'
require 'testutil'
require 'erubis'


if $0 == __FILE__
  require "#{TESTDIR}/test-erubis.rb"
  require "#{TESTDIR}/test-engines.rb"
  require "#{TESTDIR}/test-enhancers.rb"
  require "#{TESTDIR}/test-main.rb"
  require "#{TESTDIR}/test-users-guide.rb"
end
