require File.dirname(__FILE__) + '/test_helper.rb'
require 'pp'
require File.dirname(__FILE__) + '/../test_credentials.rb'

class TestEc2 < Test::Unit::TestCase

    # Some of RightEc2 instance methods concerning instance launching and image registration
    # are not tested here due to their potentially risk.

    def setup
        TestCredentials.get_credentials
        @ec2   = Aws::Ec2.new(TestCredentials.aws_access_key_id,
                              TestCredentials.aws_secret_access_key)
        @key   = 'right_ec2_awesome_test_key'
        @group = 'right_ec2_awesome_test_security_group'
    end

    def test_001_describe_availability_zones
        TestCredentials.get_credentials
        @ec2   = Aws::Ec2.new(TestCredentials.aws_access_key_id,
                              TestCredentials.aws_secret_access_key)
        zones = @ec2.describe_availability_zones
        puts zones.inspect
        assert zones.is_a? Array
        assert zones.size > 3
        zones.each do |z|
            puts z[:zone_name]
        end
        assert zones[0][:zone_name] == "us-east-1a"
    end

    def test_01_create_describe_key_pairs
        new_key = @ec2.create_key_pair(@key)
        assert new_key[:aws_material][/BEGIN RSA PRIVATE KEY/], "New key material is absent"
        keys = @ec2.describe_key_pairs
        assert keys.map { |key| key[:aws_key_name] }.include?(@key), "#{@key} must exist"
    end

    def test_02_create_security_group
        assert @ec2.create_security_group(@group, 'My awesone test group'), 'Create_security_group fail'
        group = @ec2.describe_security_groups([@group])[0]
        assert_equal @group, group[:aws_group_name], 'Group must be created but does not exist'
    end

    def test_03_perms_add
        assert @ec2.authorize_security_group_named_ingress(@group, TestCredentials.account_number, 'default')
        assert @ec2.authorize_security_group_IP_ingress(@group, 80, 80, 'udp', '192.168.1.0/8')
    end

    def test_04_check_new_perms_exist
        assert_equal 2, @ec2.describe_security_groups([@group])[0][:aws_perms].size
    end

    def test_05_perms_remove
        assert @ec2.revoke_security_group_IP_ingress(@group, 80, 80, 'udp', '192.168.1.0/8')
        assert @ec2.revoke_security_group_named_ingress(@group,
                                                        TestCredentials.account_number, 'default')
    end

    def test_06_describe_images
        images = describe_images
        # unknown image
        assert_raise(Aws::AwsError) { @ec2.describe_images(['ami-ABCDEFGH']) }
    end

    def test_07_describe_instanses
        assert @ec2.describe_instances
        # unknown image
        assert_raise(Aws::AwsError) { @ec2.describe_instances(['i-ABCDEFGH']) }
    end

    def test_08_delete_security_group
        assert @ec2.delete_security_group(@group), 'Delete_security_group fail'
    end

    def test_09_delete_key_pair
        assert @ec2.delete_key_pair(@key), 'Delete_key_pair fail'
##  Hmmm... Amazon does not through the exception any more. It now just returns a 'true' if the key does not exist any more...
##      # key must be deleted already
##    assert_raise(Aws::AwsError) { @ec2.delete_key_pair(@key) }
    end

    def test_10_signature_version_0
        ec2 = Aws::Ec2.new(TestCredentials.aws_access_key_id, TestCredentials.aws_secret_access_key, :signature_version => '0')
        images = ec2.describe_images
        assert images.size>0, 'Amazon must have at least some public images'
        # check that the request has correct signature version
        assert ec2.last_request.path.include?('SignatureVersion=0')
    end

    def test_11_regions
        regions = nil
        assert_nothing_raised do
            regions = @ec2.describe_regions
        end
        # check we got more that 0 regions
        assert regions.size > 0
        # check an access to regions
        regions.each do |region|
            regional_ec2 = Aws::Ec2.new(TestCredentials.aws_access_key_id, TestCredentials.aws_secret_access_key, :region => region)
            # do we have a correct endpoint server?
            assert_equal "#{region}.ec2.amazonaws.com", regional_ec2.params[:server]
            # get a list of images from every region
            images = nil
            assert_nothing_raised do
                images = regional_ec2.describe_regions
            end
            # every region must have images
            assert images.size > 0
        end
    end

    def test_12_endpoint_url
        ec2 = Aws::Ec2.new(TestCredentials.aws_access_key_id, TestCredentials.aws_secret_access_key, :endpoint_url => 'a://b.c:0/d/', :region => 'z')
        # :endpoint_url has a priority hence :region should be ommitted
        assert_equal 'a', ec2.params[:protocol]
        assert_equal 'b.c', ec2.params[:server]
        assert_equal '/d/', ec2.params[:service]
        assert_equal 0, ec2.params[:port]
        assert_nil ec2.params[:region]
    end

    def test_13a_create_describe_delete_tag
      images = describe_images
      resource_id = images.first[:aws_id]
      
      assert @ec2.create_tag(resource_id, 'testkey', 'testvalue').inspect, "Could not add a tag to #{resource_id}"
      assert_equal(
        [{:aws_resource_id=>resource_id, :aws_resource_type=>"image", :aws_key=>"testkey", :aws_value=>"testvalue"}],
        @ec2.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => resource_id)
      )
      assert_equal(
        [],
        @ec2.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => '__blah__')
      )
      
      assert @ec2.delete_tag(resource_id, 'testkey').inspect, "Could not delete tag 'testkey' from #{resource_id}"
      sleep 1 # :(
      assert_equal(
        [],
        @ec2.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => resource_id)
      )
    end

    def test_13b_create_describe_delete_tag_by_value
      images = describe_images
      resource_id = images.first[:aws_id]
      
      assert @ec2.create_tag(resource_id, 'testkey', 'testvalue').inspect, "Could not add a tag to #{resource_id}"
      assert_equal(
        [{:aws_resource_id=>resource_id, :aws_resource_type=>"image", :aws_key=>"testkey", :aws_value=>"testvalue"}],
        @ec2.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => resource_id, 'Filter.2.Name' => 'key', 'Filter.2.Value.1' => 'testkey')
      )
      assert_equal(
        [],
        @ec2.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => resource_id, 'Filter.2.Name' => 'key', 'Filter.2.Value.1' => '__blah__')
      )
      
      assert @ec2.delete_tag(resource_id, 'testkey', 'testvalue').inspect, "Could not delete tag 'testkey' from #{resource_id}"
      sleep 1 # :(
      assert_equal(
        [],
        @ec2.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => resource_id, 'Filter.2.Name' => 'key', 'Filter.2.Value.1' => 'testkey')
      )
    end

    def test_13c_delete_tag_with_empty_or_nil_value
      images = describe_images
      resource_id = images.first[:aws_id]
      
      assert @ec2.create_tag(resource_id, 'testkey', 'testvalue').inspect, "Could not add a tag to #{resource_id}"
      assert_equal(
        [{:aws_resource_id=>resource_id, :aws_resource_type=>"image", :aws_key=>"testkey", :aws_value=>"testvalue"}],
        @ec2.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => resource_id)
      )
      
      # Delete a tag with an empty string value...
      assert @ec2.delete_tag(resource_id, 'testkey', '').inspect, "Could not delete tag 'testkey' from #{resource_id}"
      sleep 1 # :(
      # ... does nothing
      assert_equal(
        [{:aws_resource_id=>resource_id, :aws_resource_type=>"image", :aws_key=>"testkey", :aws_value=>"testvalue"}],
        @ec2.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => resource_id)
      )
      
      # Delete a tag with value = nil...
      assert @ec2.delete_tag(resource_id, 'testkey', nil).inspect, "Could not delete tag 'testkey' from #{resource_id}"
      sleep 1 # :(
      # ... deletes all tags with the given key
      assert_equal(
        [],
        @ec2.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => resource_id)
      )
    end

  private

    # Memoize the images to speed up the tests
    def describe_images
      @@images ||= @ec2.describe_images
      assert @@images.size>0, 'Amazon must have at least some public images'
      @@images
    end

end
