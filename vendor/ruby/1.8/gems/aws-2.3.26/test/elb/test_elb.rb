require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/aws'
require 'pp'
require File.dirname(__FILE__) + '/../test_credentials.rb'

class TestElb < Test::Unit::TestCase

    # Some of RightEc2 instance methods concerning instance launching and image registration
    # are not tested here due to their potentially risk.

    def setup
        TestCredentials.get_credentials

        @ec2 = Aws::Ec2.new(TestCredentials.aws_access_key_id,
                            TestCredentials.aws_secret_access_key)

        @elb = Aws::Elb.new(TestCredentials.aws_access_key_id,
                            TestCredentials.aws_secret_access_key)
        @key = 'right_ec2_awesome_test_key'
        @group = 'right_ec2_awesome_test_security_group'
    end

    def test_01_create_elb

    end

    def test_02_register_instances

    end

    def test_03_deregister_instances

    end


    def test_04_describe_elb
        desc = @elb.describe_load_balancers
        puts desc.inspect
    end

    def test_06_describe_instance_health

    end


    def test_15_delete_elb

    end


end
