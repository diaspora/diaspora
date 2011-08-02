module Aws

    class Mon < Aws::AwsBase
        include Aws::AwsBaseInterface


        #Amazon EC2 API version being used
        API_VERSION = "2009-05-15"
        DEFAULT_HOST = "monitoring.amazonaws.com"
        DEFAULT_PATH = '/'
        DEFAULT_PROTOCOL = 'https'
        DEFAULT_PORT = 443

        # Available measures for EC2 instances:
        # NetworkIn NetworkOut DiskReadOps DiskWriteOps DiskReadBytes DiskWriteBytes CPUUtilization
        measures=%w(NetworkIn NetworkOut DiskReadOps DiskWriteOps DiskReadBytes DiskWriteBytes CPUUtilization)

        @@bench = Aws::AwsBenchmarkingBlock.new

        def self.bench_xml
            @@bench.xml
        end

        def self.bench_ec2
            @@bench.service
        end

        # Current API version (sometimes we have to check it outside the GEM).
        @@api = ENV['EC2_API_VERSION'] || API_VERSION

        def self.api
            @@api
        end


        def initialize(aws_access_key_id=nil, aws_secret_access_key=nil, params={})
            init({ :name => 'MON',
                   :default_host => ENV['MON_URL'] ? URI.parse(ENV['MON_URL']).host : DEFAULT_HOST,
                   :default_port => ENV['MON_URL'] ? URI.parse(ENV['MON_URL']).port : DEFAULT_PORT,
                   :default_service => ENV['MON_URL'] ? URI.parse(ENV['MON_URL']).path : DEFAULT_PATH,
                   :default_protocol => ENV['MON_URL'] ? URI.parse(ENV['MON_URL']).scheme : DEFAULT_PROTOCOL,
            :api_version => API_VERSION },
                 aws_access_key_id || ENV['AWS_ACCESS_KEY_ID'],
                 aws_secret_access_key|| ENV['AWS_SECRET_ACCESS_KEY'],
                 params)
        end


        def generate_request(action, params={})
            service_hash = {"Action" => action,
                            "AWSAccessKeyId" => @aws_access_key_id,
                            "Version" => @@api }
            service_hash.update(params)
            service_params = signed_service_params(@aws_secret_access_key, service_hash, :get, @params[:server], @params[:service])

            # use POST method if the length of the query string is too large
            if service_params.size > 2000
                if signature_version == '2'
                    # resign the request because HTTP verb is included into signature
                    service_params = signed_service_params(@aws_secret_access_key, service_hash, :post, @params[:server], @params[:service])
                end
                request = Net::HTTP::Post.new(service)
                request.body = service_params
                request['Content-Type'] = 'application/x-www-form-urlencoded'
            else
                request = Net::HTTP::Get.new("#{@params[:service]}?#{service_params}")
            end

            #puts "\n\n --------------- QUERY REQUEST TO AWS -------------- \n\n"
            #puts "#{@params[:service]}?#{service_params}\n\n"

            # prepare output hash
            { :request => request,
              :server => @params[:server],
              :port => @params[:port],
              :protocol => @params[:protocol] }
        end


        # Sends request to Amazon and parses the response
        # Raises AwsError if any banana happened
        def request_info(request, parser, options={})
            conn = get_conn(:mon_connection, @params, @logger)
            request_info_impl(conn, @@bench, request, parser, options)
        end

        #-----------------------------------------------------------------
        #      REQUESTS
        #-----------------------------------------------------------------

        def list_metrics(options={})

            next_token = options[:next_token] || nil

            params = { }
            params['NextToken'] = next_token unless next_token.nil?

            @logger.info("list Metrics ")

            link = generate_request("ListMetrics", params)
            resp = request_info(link, QMonListMetrics.new(:logger => @logger))

        rescue Exception
            on_exception
        end


        # measureName:  CPUUtilization (Units: Percent), NetworkIn (Units: Bytes), NetworkOut (Units: Bytes), DiskWriteOps (Units: Count)
        #               DiskReadBytes (Units: Bytes), DiskReadOps (Units: Count), DiskWriteBytes (Units: Bytes)
        # stats: 	array containing one or more of Minimum, Maximum, Sum, Average, Samples
        # start_time :   Timestamp to start
        # end_time:      Timestamp to end
        # unit: 	Either Seconds, Percent, Bytes, Bits, Count, Bytes, Bits/Second, Count/Second, and None
        #
        # Optional parameters:
        #    period: 	Integer 60 or multiple of 60
        #    dimensions:    Hash containing keys ImageId, AutoScalingGroupName, InstanceId, InstanceType
        #    customUnit:   nil. not supported currently.
        #    namespace:    AWS/EC2

        def get_metric_statistics ( measure_name, stats, start_time, end_time, unit, options={})

            period = options[:period] || 60
            dimensions = options[:dimensions] || nil
            custom_unit = options[:custom_unit] || nil
            namespace = options[:namespace] || "AWS/EC2"

            params = {}
            params['MeasureName'] = measure_name
            i=1
            stats.each do |s|
                params['Statistics.member.'+i.to_s] = s
                i = i+1
            end
            params['Period'] = period
            if (dimensions != nil)
                i = 1
                dimensions.each do |k, v|
                    params['Dimensions.member.'+i.to_s+".Name."+i.to_s] = k
                    params['Dimensions.member.'+i.to_s+".Value."+i.to_s] = v
                    i = i+1
                end
            end
            params['StartTime'] = start_time
            params['EndTime'] = end_time
            params['Unit'] = unit
            #params['CustomUnit'] = customUnit always nil
            params['Namespace'] = namespace

            link = generate_request("GetMetricStatistics", params)
            resp = request_info(link, QMonGetMetricStatistics.new(:logger => @logger))

        rescue Exception
            on_exception
        end


        #-----------------------------------------------------------------
        #      PARSERS: Instances
        #-----------------------------------------------------------------


        class QMonGetMetricStatistics < Aws::AwsParser

            def reset
                @result = []
            end

            def tagstart(name, attributes)
                @metric = {} if name == 'member'
            end

            def tagend(name)
                case name
                    when 'Timestamp' then
                        @metric[:timestamp] = @text
                    when 'Samples' then
                        @metric[:samples] = @text
                    when 'Unit' then
                        @metric[:unit] = @text
                    when 'Average' then
                        @metric[:average] = @text
                    when 'Minimum' then
                        @metric[:minimum] = @text
                    when 'Maximum' then
                        @metric[:maximum] = @text
                    when 'Sum' then
                        @metric[:sum] = @text
                    when 'Value' then
                        @metric[:value] = @text
                    when 'member' then
                        @result << @metric
                end
            end
        end

        class QMonListMetrics < Aws::AwsParser

            def reset
                @result = []
                @namespace = ""
                @measure_name = ""
            end

            def tagstart(name, attributes)
                @metric = {} if name == 'member'
            end

            def tagend(name)
                case name
                    when 'MeasureName' then
                        @measure_name = @text
                    when 'Namespace' then
                        @namespace = @text
                    when 'Name' then
                        @metric[:name] = @text
                    when 'Value' then
                        @metric[:value] = @text
                    when 'member' then
                        @metric[:namespace] = @namespace
                        @metric[:measure_name] = @measure_name
                        @result << @metric
                end
            end
        end


    end


end

