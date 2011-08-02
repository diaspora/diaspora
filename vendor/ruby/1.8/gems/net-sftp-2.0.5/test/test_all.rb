#  $ ruby -I../net-ssh/lib -Ilib -Itest -rrubygems test/test_all.rb
#require 'net/ssh'
#puts Net::SSH::Version::CURRENT
require 'common'
Dir.chdir(File.dirname(__FILE__)) do
  Dir['**/test_*.rb'].each { |file| require(file) }
end