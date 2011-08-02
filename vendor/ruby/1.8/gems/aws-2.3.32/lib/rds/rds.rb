module Aws
    require 'xmlsimple'

    # API Reference: http://docs.amazonwebservices.com/AmazonRDS/latest/APIReference/
    class Rds < AwsBase
        include AwsBaseInterface


        # Amazon API version being used
        API_VERSION = nil
        DEFAULT_HOST = "rds.amazonaws.com"
        DEFAULT_PATH = '/'
        DEFAULT_PROTOCOL = 'https'
        DEFAULT_PORT = 443

        @@api = ENV['RDS_API_VERSION'] || API_VERSION


        def self.api
            @@api
        end


        @@bench = AwsBenchmarkingBlock.new


        def self.bench_xml
            @@bench.xml
        end


        def self.bench_ec2
            @@bench.service
        end


        def initialize(aws_access_key_id=nil, aws_secret_access_key=nil, params={})
            uri = ENV['RDS_URL'] ? URI.parse(ENV['RDS_URL']) : nil
            init({ :name => 'RDS',
                   :default_host => uri ? uri.host : DEFAULT_HOST,
                   :default_port => uri ? uri.port : DEFAULT_PORT,
                   :default_service => uri ? uri.path : DEFAULT_PATH,
                   :default_protocol => uri ? uri.scheme : DEFAULT_PROTOCOL,
            :api_version => API_VERSION },
                 aws_access_key_id || ENV['AWS_ACCESS_KEY_ID'],
                 aws_secret_access_key|| ENV['AWS_SECRET_ACCESS_KEY'],
                 params)
        end


        def do_request(action, params, options={})
            link = generate_request(action, params)
            resp = request_info_xml_simple(:rds_connection, @params, link, @logger,
                                           :group_tags=>{"DBInstances"=>"DBInstance",
                                                            "DBParameterGroups"=>"DBParameterGroup",
                                                            "DBSecurityGroups"=>"DBSecurityGroup",
                                                            "EC2SecurityGroups"=>"EC2SecurityGroup",
                                                            "IPRanges"=>"IPRange"},
                                           :force_array=>["DBInstances",
                                                          "DBParameterGroups",
                                                          "DBSecurityGroups",
                                                          "EC2SecurityGroups",
                                                          "IPRanges"],
                                           :pull_out_array=>options[:pull_out_array],
                                           :pull_out_single=>options[:pull_out_single],
                                           :wrapper=>options[:wrapper])
        end


        #-----------------------------------------------------------------
        #      REQUESTS
        #-----------------------------------------------------------------

        #
        # identifier: db instance identifier. Must be unique per account per zone.
        # instance_class: db.m1.small | db.m1.large | db.m1.xlarge | db.m2.2xlarge | db.m2.4xlarge
        # See this for other values: http://docs.amazonwebservices.com/AmazonRDS/latest/APIReference/
        #
        # options:
        #    db_name: if you want a database created at the same time as the instance, specify :db_name option.
        #    availability_zone: default is random zone.
        def create_db_instance(identifier, instance_class, allocated_storage, master_username, master_password, options={})
            params = {}
            params['DBInstanceIdentifier'] = identifier
            params['DBInstanceClass'] = instance_class
            params['AllocatedStorage'] = allocated_storage
            params['MasterUsername'] = master_username
            params['MasterUserPassword'] = master_password

            params['Engine'] = options[:engine] || "MySQL5.1"
            params['DBName'] = options[:db_name] if options[:db_name]
            params['AvailabilityZone'] = options[:availability_zone] if options[:availability_zone]
            params['PreferredMaintenanceWindow'] = options[:preferred_maintenance_window] if options[:preferred_maintenance_window]
            params['BackupRetentionPeriod'] = options[:preferred_retention_period] if options[:preferred_retention_period]
            params['PreferredBackupWindow'] = options[:preferred_backup_window] if options[:preferred_backup_window]

            @logger.info("Creating DB Instance called #{identifier}")

            link = do_request("CreateDBInstance", params, :pull_out_single=>[:create_db_instance_result, :db_instance])

        rescue Exception
            on_exception
        end


        # options:
        #      DBInstanceIdentifier
        #      MaxRecords
        #      Marker
        #
        # Returns array of instances as hashes.
        # Response metadata can be retreived by calling array.response_metadata on the returned array.
        def describe_db_instances(options={})
            params = {}
            params['DBInstanceIdentifier'] = options[:db_instance_identifier] if options[:db_instance_identifier]
            params['MaxRecords'] = options[:max_records] if options[:max_records]
            params['Marker'] = options[:marker] if options[:marker]

            resp = do_request("DescribeDBInstances", params, :pull_out_array=>[:describe_db_instances_result, :db_instances])

        rescue Exception
            on_exception
        end


        # identifier: identifier of db instance to delete.
        # final_snapshot_identifier: if specified, RDS will crate a final snapshot before deleting so you can restore it later.
        def delete_db_instance(identifier, final_snapshot_identifier=nil)
            @logger.info("Deleting DB Instance - " + identifier.to_s)

            params = {}
            params['DBInstanceIdentifier'] = identifier
            if final_snapshot_identifier
                params['FinalDBSnapshotIdentifier'] = final_snapshot_identifier
            else
                params['SkipFinalSnapshot'] = true
            end

            link = do_request("DeleteDBInstance", params, :pull_out_single=>[:delete_db_instance_result, :db_instance])

        rescue Exception
            on_exception
        end


        def create_db_security_group(group_name, description, options={})
            params = {}
            params['DBSecurityGroupName'] = group_name
            params['DBSecurityGroupDescription'] = description

            link = do_request("CreateDBSecurityGroup", params, :pull_out_single => [:create_db_security_group_result, :db_security_group])

        rescue Exception
            on_exception
        end


        def delete_db_security_group(group_name, options={})
            params = {}
            params['DBSecurityGroupName'] = group_name

            link = do_request("DeleteDBSecurityGroup", params)

        rescue Exception
            on_exception
        end


        def describe_db_security_groups(options={})
            params = {}
            params['DBSecurityGroupName'] = options[:DBSecurityGroupName] if options[:DBSecurityGroupName]
            params['MaxRecords'] = options[:MaxRecords] if options[:MaxRecords]

            link = do_request("DescribeDBSecurityGroups", params, :pull_out_array=>[:describe_db_security_groups_result, :db_security_groups], :wrapper=>:db_security_group)


        rescue Exception
            on_exception
        end


        def authorize_db_security_group_ingress_ec2group(group_name, ec2_group_name, ec2_group_owner_id, options={})
            params = {}
            params['DBSecurityGroupName'] = group_name
            params['EC2SecurityGroupOwnerId'] = ec2_group_owner_id
            params['EC2SecurityGroupName'] = ec2_group_name
            link = do_request("AuthorizeDBSecurityGroupIngress", params)
        rescue Exception
            on_exception
        end


        def authorize_db_security_group_ingress_range(group_name, ip_range, options={})
            params = {}
            params['DBSecurityGroupName'] = group_name
            params['CIDRIP'] = ip_range
            link = do_request("AuthorizeDBSecurityGroupIngress", params)
        rescue Exception
            on_exception
        end


        def revoke_db_security_group_ingress(group_name, ip_range, options={})
            params = {}
            params['DBSecurityGroupName'] = group_name
            params['CIDRIP'] = ip_range
            link = do_request("RevokeDBSecurityGroupIngress", params)
        rescue Exception
            on_exception
        end



    end

end