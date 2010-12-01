if RUBY_PLATFORM != 'java'
  puts "You need JRuby to run these specs"
  exit -1
end

require File.dirname(__FILE__) + '/../lib/culerity'
require File.dirname(__FILE__) + '/../lib/culerity/celerity_server'