require 'rubygems'
require 'test/unit'
require 'shoulda'
gem 'jnunemaker-matchy', '>= 0.4.0'
require 'matchy'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'crack'

class Test::Unit::TestCase
end
