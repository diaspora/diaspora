require 'test/unit'
require 'rubygems'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'
require 'oauth'
require 'mocha'
require 'stringio'

class Test::Unit::TestCase

  def assert_matching_headers(expected, actual)
    # transform into sorted arrays
    auth_intro, auth_params = actual.split(' ', 2)
    assert_equal auth_intro, 'OAuth'
    expected    = expected.split(/(,|\s)/).reject {|v| v == '' || v =~ /^[\,\s]+/}.sort
    auth_params = auth_params.split(/(,|\s)/).reject {|v| v == '' || v =~ /^[\,\s]+/}.sort
    assert_equal expected, auth_params
  end

end
