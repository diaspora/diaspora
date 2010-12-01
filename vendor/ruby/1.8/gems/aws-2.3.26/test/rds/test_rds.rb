require 'test/unit'
require File.dirname(__FILE__) + '/../../lib/aws'
require 'rds/rds'
require 'pp'
require File.dirname(__FILE__) + '/../test_credentials.rb'

class TestRds < Test::Unit::TestCase

    # Some of RightEc2 instance methods concerning instance launching and image registration
    # are not tested here due to their potentially risk.

    def setup
        TestCredentials.get_credentials

        @rds = Aws::Rds.new(TestCredentials.aws_access_key_id,
                            TestCredentials.aws_secret_access_key)

        @identifier = 'test-db-instance1b'
        # deleting this one....
        #@identifier2 = 'my-db-instance2'
    end


    def test_00_describe_db_instances_empty
        instances = @rds.describe_db_instances
#        puts "instances_result=" + instances_result.inspect
#        instances = instances_result["DescribeDBInstancesResult"]["DBInstances"]["DBInstance"]
        puts "instances count = " + instances.count.to_s
        puts 'instances=' + instances.inspect
        assert instances.size == 0
    end


    def test_01_create_db_instance
        begin
            db_instance3 = @rds.create_db_instance('bad_test_key', "db.m1.small", 5, "master", "masterpass")
        rescue => ex
            #puts "msg=" + ex.message
            #puts "response=" + ex.response
            assert ex.message[0, "InvalidParameterValue".size] == "InvalidParameterValue"
        end

        db_instance = @rds.create_db_instance(@identifier, "db.m1.small", 5, "master", "masterpass")
        assert db_instance[:db_instance_status] == "creating"

        start = Time.now
        tries=0
        catch (:done)  do
            while tries < 100
                instances = @rds.describe_db_instances

                #puts "INSTANCES -----> " + instances.inspect

                instances.each do |i|
                    db_status = i[:db_instance_status]
                    puts 'i=' + db_status.to_s
                    next unless i[:db_instance_identifier] == @identifier
                    throw :done if db_status == "available"
                    puts "Database not ready yet.... attempt #{tries.to_s} of 100, db state --> #{i[:db_instance_status].to_s}"
                    tries += 1
                    sleep 5
                end
            end
        end
        puts "Duration to start db instance: #{Time.now-start}"
    end


    def test_02_describe_db_instances
        instances = @rds.describe_db_instances
#        puts "instances_result=" + instances_result.inspect
#        instances = instances_result["DescribeDBInstancesResult"]["DBInstances"]["DBInstance"]
        puts "instances count = " + instances.count.to_s
        puts 'instances=' + instances.inspect
        assert instances.size > 0
        i_describe = nil
        instances.each do |rdi|
            puts 'rdi=' + rdi.inspect
            i_describe = rdi if rdi[:db_instance_identifier] == @identifier
        end
        assert i_describe

        puts 'response_metadata=' + instances.response_metadata.inspect
        assert instances.response_metadata
        assert instances.response_metadata[:request_id]
    end


    def test_03_describe_security_groups
        security_groups = @rds.describe_db_security_groups()
        puts "security_groups=" + security_groups.inspect
        default_present = false
        assert security_groups.is_a?(Array)
        security_groups.each do |security_group|
            security_group.inspect
            if security_group[:db_security_group_name] == "default"
                default_present=true
            end
            assert security_group[:ec2_security_groups].is_a? Array
        end
        assert default_present
    end


    def test_04_authorize_security_groups_ingress
        # Create
#        security_groups = @rds.describe_db_security_groups
#        @security_info = security_groups[0]
        @rds.authorize_db_security_group_ingress_range("default", "122.122.122.122/12")

        # Check
        security_groups = @rds.describe_db_security_groups
        @security_info = security_groups[0]

        ip_found = @security_info.inspect.include? "122.122.122.122/12"
        assert ip_found
    end


    def test_05_delete_db_instance
        @rds.delete_db_instance(@identifier) # todo: can't delete unless it's in "available" state
        #@rds.delete_db_instance(@identifier2)
        sleep 3

        instances = @rds.describe_db_instances(:db_instance_identifier=>@identifier)
        #puts "instances_result=" + instances_result.inspect

        instances.each do |i|
            next unless i[:db_instance_identifier] == @identifier
            db_status = i[:db_instance_status]
            puts "Trying to delete and getting i[DBInstanceStatus] -----------> " + db_status
            @rds.delete_db_instance(i[:db_instance_identifier]) if db_status == "available"
            assert db_status == "deleting"
        end
        sleep 2

    end


    def test_06_create_security_groups
        group_present=false

        @rds.create_db_security_group("new_sample_group", "new_sample_group_description")

        security_groups = @rds.describe_db_security_groups

        security_groups.each do |security_group|
            if (security_group[:db_security_group_name]=="new_sample_group")&&(security_group[:db_security_group_description]=="new_sample_group_description")
                group_present = true
            end
        end

        assert group_present
    end


    def test_07_revoking_security_groups_ingress
#        sleep 15
        @rds.revoke_db_security_group_ingress("default", "122.122.122.122/12")
        sleep 2
        security_groups = @rds.describe_db_security_groups
        revoking = security_groups[0].inspect.include? "revoking"
        assert revoking
    end


    def test_08_delete_security_group
        group_present=false
        @rds.delete_db_security_group("new_sample_group")
        sleep 2
        security_groups = @rds.describe_db_security_groups
        security_groups.each do |security_group|
            if (security_group[:db_security_group_name]=="new_sample_group")
                group_present=true
            end
        end
        assert !group_present
    end


end