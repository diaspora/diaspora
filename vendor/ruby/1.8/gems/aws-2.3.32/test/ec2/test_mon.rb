require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/../test_credentials.rb'
require 'pp'

class TestEc2 < Test::Unit::TestCase

    # Some of RightEc2 instance methods concerning instance launching and image registration
    # are not tested here due to their potentially risk.

    def setup
        TestCredentials.get_credentials
        @ec2 = Aws::Ec2.new(TestCredentials.aws_access_key_id,
                                   TestCredentials.aws_secret_access_key)
        @key = 'right_ec2_awesome_test_key'
        @group = 'right_ec2_awesome_test_security_group'
    end
end
