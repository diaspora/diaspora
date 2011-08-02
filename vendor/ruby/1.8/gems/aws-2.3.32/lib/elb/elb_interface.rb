module Aws

    require 'xmlsimple'

    class Elb < AwsBase

        include AwsBaseInterface


        #Amazon ELB API version being used
        API_VERSION = "2009-05-15"
        DEFAULT_HOST = "elasticloadbalancing.amazonaws.com"
        DEFAULT_PATH = '/'
        DEFAULT_PROTOCOL = 'https'
        DEFAULT_PORT = 443


        @@bench = AwsBenchmarkingBlock.new

        def self.bench_xml
            @@bench.xml
        end

        def self.bench_ec2
            @@bench.service
        end

        # Current API version (sometimes we have to check it outside the GEM).
        @@api = ENV['ELB_API_VERSION'] || API_VERSION

        def self.api
            @@api
        end


        def initialize(aws_access_key_id=nil, aws_secret_access_key=nil, params={})
            init({ :name => 'ELB',
                   :default_host => ENV['ELB_URL'] ? URI.parse(ENV['ELB_URL']).host : DEFAULT_HOST,
                   :default_port => ENV['ELB_URL'] ? URI.parse(ENV['ELB_URL']).port : DEFAULT_PORT,
                   :default_service => ENV['ELB_URL'] ? URI.parse(ENV['ELB_URL']).path : DEFAULT_PATH,
                   :default_protocol => ENV['ELB_URL'] ? URI.parse(ENV['ELB_URL']).scheme : DEFAULT_PROTOCOL,
            :api_version => API_VERSION },
                 aws_access_key_id || ENV['AWS_ACCESS_KEY_ID'],
                 aws_secret_access_key|| ENV['AWS_SECRET_ACCESS_KEY'],
                 params)
        end


        # Sends request to Amazon and parses the response
        # Raises AwsError if any banana happened
        def request_info(request, parser, options={})
            request_info2(request, parser, @params, :elb_connection, @logger, @@bench, options)
        end

        # todo: convert to xml-simple version and get rid of parser below
        def do_request(action, params, options={})
            link = generate_request(action, params)
            resp = request_info_xml_simple(:rds_connection, @params, link, @logger,
                                           :group_tags=>{"LoadBalancersDescriptions"=>"LoadBalancersDescription",
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
        # name: name of load balancer
        # availability_zones: array of zones
        # listeners: array of hashes containing :load_balancer_port, :instance_port, :protocol
        #       eg: {:load_balancer_port=>80, :instance_port=>8080, :protocol=>"HTTP"}
        def create_load_balancer(name, availability_zones, listeners)
            params = hash_params('AvailabilityZones.member', availability_zones)
            i = 1
            listeners.each do |l|
                params["Listeners.member.#{i}.Protocol"] = "#{l[:protocol]}"
                params["Listeners.member.#{i}.LoadBalancerPort"] = "#{l[:load_balancer_port]}"
                params["Listeners.member.#{i}.InstancePort"] = "#{l[:instance_port]}"
                i += 1
            end
            params['LoadBalancerName'] = name

            @logger.info("Creating LoadBalancer called #{params['LoadBalancerName']}")

            link = generate_request("CreateLoadBalancer", params)
            resp = request_info(link, QElbCreateParser.new(:logger => @logger))

        rescue Exception
            on_exception
        end


        # name: name of load balancer
        # instance_ids: array of instance_id's to add to load balancer
        def register_instances_with_load_balancer(name, instance_ids)
            params = {}
            params['LoadBalancerName'] = name

            i = 1
            instance_ids.each do |l|
                params["Instances.member.#{i}.InstanceId"] = "#{l}"
                i += 1
            end

            @logger.info("Registering Instances #{instance_ids.join(',')} with Load Balancer '#{name}'")

            link = generate_request("RegisterInstancesWithLoadBalancer", params)
            resp = request_info(link, QElbRegisterInstancesParser.new(:logger => @logger))

        rescue Exception
            on_exception
        end

        def deregister_instances_from_load_balancer(name, instance_ids)
            params = {}
            params['LoadBalancerName'] = name

            i = 1
            instance_ids.each do |l|
                params["Instances.member.#{i}.InstanceId"] = "#{l}"
                i += 1
            end

            @logger.info("Deregistering Instances #{instance_ids.join(',')} from Load Balancer '#{name}'")

            link = generate_request("DeregisterInstancesFromLoadBalancer", params) # Same response as register I believe
            resp = request_info(link, QElbRegisterInstancesParser.new(:logger => @logger))

        rescue Exception
            on_exception
        end


        def describe_load_balancers(lparams={})
            @logger.info("Describing Load Balancers")

            params = {}
            params.update( hash_params('LoadBalancerNames.member', lparams[:names]) ) if lparams[:names]

            link = generate_request("DescribeLoadBalancers", params)

            resp = request_info(link, QElbDescribeLoadBalancersParser.new(:logger => @logger))

        rescue Exception
            on_exception
        end


        def describe_instance_health(name, instance_ids=[])
            instance_ids = [instance_ids] if instance_ids.is_a?(String)
#            @logger.info("Describing Instance Health")
            params = {}
            params['LoadBalancerName'] = name

            i = 1
            instance_ids.each do |l|
                params["Instances.member.#{i}.InstanceId"] = "#{l}"
                i += 1
            end

            @logger.info("Describing Instances Health #{instance_ids.join(',')} with Load Balancer '#{name}'")

            link = generate_request("DescribeInstanceHealth", params)
            resp = request_info(link, QElbDescribeInstancesHealthParser.new(:logger => @logger))


        rescue Exception
            on_exception
        end


        def delete_load_balancer(name)
            @logger.info("Deleting Load Balancer - " + name.to_s)

            params = {}
            params['LoadBalancerName'] = name

            link = generate_request("DeleteLoadBalancer", params)

            resp = request_info(link, QElbDeleteParser.new(:logger => @logger))

        rescue Exception
            on_exception
        end


        #-----------------------------------------------------------------
        #      PARSERS: Instances
        #-----------------------------------------------------------------


        class QElbCreateParser < AwsParser

            def reset
                @result = {}
            end


            def tagend(name)
                case name
                    when 'DNSName' then
                        @result[:dns_name] = @text
                end
            end
        end

        class QElbDescribeLoadBalancersParser < AwsParser

            def reset
                @result = []
            end

            def tagstart(name, attributes)
#                puts 'tagstart ' + name + ' -- ' + @xmlpath
                if (name == 'member' && @xmlpath == 'DescribeLoadBalancersResponse/DescribeLoadBalancersResult/LoadBalancerDescriptions/member/Listeners')
                    @listener = { }
                end
                if (name == 'member' && @xmlpath == 'DescribeLoadBalancersResponse/DescribeLoadBalancersResult/LoadBalancerDescriptions/member/AvailabilityZones')
                    @availability_zone = { }
                end
                if (name == 'member' && @xmlpath == 'DescribeLoadBalancersResponse/DescribeLoadBalancersResult/LoadBalancerDescriptions/member/Instances')
                    @instance = {}
                end
                if (name == 'member' && @xmlpath == 'DescribeLoadBalancersResponse/DescribeLoadBalancersResult/LoadBalancerDescriptions')
                    @member = { :listeners=>[], :availability_zones=>[], :health_check=>{}, :instances=>[] }
                end

            end


            def tagend(name)
                case name
                    when 'LoadBalancerName' then
                        @member[:load_balancer_name] = @text
                        @member[:name] = @text
                    when 'CreatedTime' then
                        @member[:created_time] = Time.parse(@text)
                        @member[:created] = @member[:created_time]
                    when 'DNSName' then
                        @member[:dns_name] = @text
                    # Instances
                    when 'InstanceId' then
                        @instance[:instance_id] = @text
                    # Listeners
                    when 'Protocol' then
                        @listener[:protocol] = @text
                    when 'LoadBalancerPort' then
                        @listener[:load_balancer_port] = @text.to_i
                    when 'InstancePort' then
                        @listener[:instance_port] = @text.to_i
                    # HEALTH CHECK STUFF
                    when 'Interval' then
                        @member[:health_check][:interval] = @text.to_i
                    when 'Target' then
                        @member[:health_check][:target] = @text
                    when 'HealthyThreshold' then
                        @member[:health_check][:healthy_threshold] = @text.to_i
                    when 'Timeout' then
                        @member[:health_check][:timeout] = @text.to_i
                    when 'UnhealthyThreshold' then
                        @member[:health_check][:unhealthy_threshold] = @text.to_i
                    # AvailabilityZones
                    when 'member' then
                        if @xmlpath == 'DescribeLoadBalancersResponse/DescribeLoadBalancersResult/LoadBalancerDescriptions/member/Listeners'
                            @member[:listeners] << @listener
                        elsif @xmlpath == 'DescribeLoadBalancersResponse/DescribeLoadBalancersResult/LoadBalancerDescriptions/member/AvailabilityZones'
                            @availability_zone = @text
                            @member[:availability_zones] << @availability_zone
                        elsif @xmlpath == 'DescribeLoadBalancersResponse/DescribeLoadBalancersResult/LoadBalancerDescriptions/member/Instances'
                            @member[:instances] << @instance
                        elsif @xmlpath == 'DescribeLoadBalancersResponse/DescribeLoadBalancersResult/LoadBalancerDescriptions'
                            @result << @member
                        end

                end
            end
        end

        class QElbRegisterInstancesParser < AwsParser

            def reset
                @result = []
            end

            def tagstart(name, attributes)
#                puts 'tagstart ' + name + ' -- ' + @xmlpath
                if (name == 'member' &&
                        (@xmlpath == 'RegisterInstancesWithLoadBalancerResponse/RegisterInstancesWithLoadBalancerResult/Instances' ||
                                @xmlpath == 'DeregisterInstancesFromLoadBalancerResponse/DeregisterInstancesFromLoadBalancerResult/Instances')
                )
                    @member = { }
                end

            end

            def tagend(name)
                case name
                    when 'InstanceId' then
                        @member[:instance_id] = @text
                    when 'member' then
                        @result << @member
                end
            end
#
        end

        class QElbDescribeInstancesHealthParser < AwsParser

            def reset
                @result = []
            end

            def tagstart(name, attributes)
#                puts 'tagstart ' + name + ' -- ' + @xmlpath
                if (name == 'member' && @xmlpath == 'DescribeInstanceHealthResponse/DescribeInstanceHealthResult/InstanceStates')
                    @member = { }
                end
            end

            def tagend(name)
                case name
                    when 'Description' then
                        @member[:description] = @text
                    when 'State' then
                        @member[:state] = @text
                    when 'InstanceId' then
                        @member[:instance_id] = @text
                    when 'ReasonCode' then
                        @member[:reason_code] = @text
                    when 'member' then
                        @result << @member
                end
            end
#
        end

        class QElbDeleteParser < AwsParser
            def reset
                @result = true
            end
        end


    end


end