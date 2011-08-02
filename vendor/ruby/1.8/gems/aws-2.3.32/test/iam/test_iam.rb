require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/aws'
require 'pp'
require File.dirname(__FILE__) + '/../test_credentials.rb'

class TestElb < Test::Unit::TestCase

    # Some of RightEc2 instance methods concerning instance launching and image registration
    # are not tested here due to their potentially risk.

    def setup
        TestCredentials.get_credentials

        @iam = Aws::Iam.new(TestCredentials.aws_access_key_id,
                            TestCredentials.aws_secret_access_key)

    end

    def test_01_list_server_certificates

        ret = @iam.list_server_certificates
        p ret
        assert_true(ret.size == 0)
    end

    def test_02_upload_server_certificate
        ret = @iam.upload_server_certificate("test_cert",
                                             IO.read('x').strip,
                                             IO.read('y').strip,
                                             :certificate_chain=>IO.read('z').strip)

        p ret
    end


end
