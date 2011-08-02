# -*- coding: utf-8 -*-
#
# Copyright (c) 2007-2008 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

module Aws

  # = Aws::EC2 -- RightScale Amazon EC2 interface
  # The Aws::EC2 class provides a complete interface to Amazon's
  # Elastic Compute Cloud service, as well as the associated EBS (Elastic Block
  # Store).
  # For explanations of the semantics
  # of each call, please refer to Amazon's documentation at
  # http://developer.amazonwebservices.com/connect/kbcategory.jspa?categoryID=87
  #
  # Examples:
  #
  # Create an EC2 interface handle:
  #
  #   @ec2   = Aws::Ec2.new(aws_access_key_id,
  #                               aws_secret_access_key)
  # Create a new SSH key pair:
  #  @key   = 'right_ec2_awesome_test_key'
  #  new_key = @ec2.create_key_pair(@key)
  #  keys = @ec2.describe_key_pairs
  #
  # Create a security group:
  #  @group = 'right_ec2_awesome_test_security_group'
  #  @ec2.create_security_group(@group,'My awesome test group')
  #  group = @ec2.describe_security_groups([@group])[0]
  #
  # Configure a security group:
  #  @ec2.authorize_security_group_named_ingress(@group, account_number, 'default')
  #  @ec2.authorize_security_group_IP_ingress(@group, 80,80,'udp','192.168.1.0/8')
  #
  # Describe the available images:
  #  images = @ec2.describe_images
  #
  # Launch an instance:
  #  ec2.run_instances('ami-9a9e7bf3', 1, 1, ['default'], @key, 'SomeImportantUserData', 'public')
  #
  #
  # Describe running instances:
  #  @ec2.describe_instances
  #
  # Error handling: all operations raise an Aws::AwsError in case
  # of problems. Note that transient errors are automatically retried.

  class Ec2 < AwsBase
    include AwsBaseInterface

    # Amazon EC2 API version being used
    API_VERSION       = "2010-08-31"
    DEFAULT_HOST      = "ec2.amazonaws.com"
    DEFAULT_PATH      = '/'
    DEFAULT_PROTOCOL  = 'https'
    DEFAULT_PORT      = 443

    # Default addressing type (public=NAT, direct=no-NAT) used when launching instances.
    DEFAULT_ADDRESSING_TYPE =  'public'
    DNS_ADDRESSING_SET      = ['public','direct']

    # Amazon EC2 Instance Types : http://www.amazon.com/b?ie=UTF8&node=370375011
    # Default EC2 instance type (platform)
    DEFAULT_INSTANCE_TYPE   =  'm1.small'
    INSTANCE_TYPES          = ['t1.micro', 'm1.small','c1.medium','m1.large','m1.xlarge','c1.xlarge']

    @@bench = AwsBenchmarkingBlock.new
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

    # Create a new handle to an EC2 account. All handles share the same per process or per thread
    # HTTP connection to Amazon EC2. Each handle is for a specific account. The params have the
    # following options:
    # * <tt>:endpoint_url</tt> a fully qualified url to Amazon API endpoint (this overwrites: :server, :port, :service, :protocol and :region). Example: 'https://eu-west-1.ec2.amazonaws.com/'
    # * <tt>:server</tt>: EC2 service host, default: DEFAULT_HOST
    # * <tt>:region</tt>: EC2 region (North America by default)
    # * <tt>:port</tt>: EC2 service port, default: DEFAULT_PORT
    # * <tt>:protocol</tt>: 'http' or 'https', default: DEFAULT_PROTOCOL
    # * <tt>:multi_thread</tt>: true=HTTP connection per thread, false=per process
    # * <tt>:logger</tt>: for log messages, default: Rails.logger else STDOUT
    # * <tt>:signature_version</tt>:  The signature version : '0' or '1'(default)
    # * <tt>:cache</tt>: true/false: caching for: ec2_describe_images, describe_instances,
    # describe_images_by_owner, describe_images_by_executable_by, describe_availability_zones,
    # describe_security_groups, describe_key_pairs, describe_addresses,
    # describe_volumes, describe_snapshots methods, default: false.
    #
    def initialize(aws_access_key_id=nil, aws_secret_access_key=nil, params={})
      init({ :name             => 'EC2',
             :default_host     => ENV['EC2_URL'] ? URI.parse(ENV['EC2_URL']).host   : DEFAULT_HOST,
             :default_port     => ENV['EC2_URL'] ? URI.parse(ENV['EC2_URL']).port   : DEFAULT_PORT,
             :default_service  => ENV['EC2_URL'] ? URI.parse(ENV['EC2_URL']).path   : DEFAULT_PATH,
             :default_protocol => ENV['EC2_URL'] ? URI.parse(ENV['EC2_URL']).scheme : DEFAULT_PROTOCOL,
            :api_version => API_VERSION },
           aws_access_key_id    || ENV['AWS_ACCESS_KEY_ID'] ,
           aws_secret_access_key|| ENV['AWS_SECRET_ACCESS_KEY'],
           params)
      # EC2 doesn't really define any transient errors to retry, and in fact,
      # when they return a 503 it is usually for 'request limit exceeded' which
      # we most certainly should not retry.  So let's pare down the list of
      # retryable errors to InternalError only (see AwsBase for the default
      # list)
      amazon_problems = ['InternalError']
    end


    def generate_request(action, params={}) #:nodoc:
      service_hash = {"Action"         => action,
                      "AWSAccessKeyId" => @aws_access_key_id,
                      "Version"        => @@api }
      service_hash.update(params)
      service_params = signed_service_params(@aws_secret_access_key, service_hash, :get, @params[:server], @params[:service])

      # use POST method if the length of the query string is too large
      if service_params.size > 2000
        if signature_version == '2'
          # resign the request because HTTP verb is included into signature
          service_params = signed_service_params(@aws_secret_access_key, service_hash, :post, @params[:server], @params[:service])
        end
        request = Net::HTTP::Post.new(@params[:service])
        request.body = service_params
        request['Content-Type'] = 'application/x-www-form-urlencoded'
      else
        request        = Net::HTTP::Get.new("#{@params[:service]}?#{service_params}")
      end
        # prepare output hash
      { :request  => request,
        :server   => @params[:server],
        :port     => @params[:port],
        :protocol => @params[:protocol] }
    end

      # Sends request to Amazon and parses the response
      # Raises AwsError if any banana happened
    def request_info(request, parser, options={})  #:nodoc:
      conn = get_conn(:ec2_connection, @params, @logger)
      request_info_impl(conn, @@bench, request, parser, options)
    end

    def hash_params(prefix, list) #:nodoc:
      groups = {}
      list.each_index{|i| groups.update("#{prefix}.#{i+1}"=>list[i])} if list
      return groups
    end

  #-----------------------------------------------------------------
  #      Images
  #-----------------------------------------------------------------

    # params:
    #   { 'ImageId'      => ['id1', ..., 'idN'],
    #     'Owner'        => ['self', ..., 'userN'],
    #     'ExecutableBy' => ['self', 'all', ..., 'userN']
    #   }
    def ec2_describe_images(params={}, image_type=nil, cache_for=nil) #:nodoc:
      request_hash = {}
      params.each do |list_by, list|
        request_hash.merge! hash_params(list_by, list.to_a)
      end
      if image_type
        request_hash['Filter.1.Name'] = "image-type"
        request_hash['Filter.1.Value.1'] = image_type
      end
      link = generate_request("DescribeImages", request_hash)
      request_cache_or_info cache_for, link,  QEc2DescribeImagesParser, @@bench, cache_for
    rescue Exception
      on_exception
    end

      # Retrieve a list of images. Returns array of hashes describing the images or an exception:
      # +image_type+ = 'machine' || 'kernel' || 'ramdisk'
      #
      #  ec2.describe_images #=>
      #    [{:aws_owner => "522821470517",
      #      :aws_id => "ami-e4b6538d",
      #      :aws_state => "available",
      #      :aws_location => "marcins_cool_public_images/ubuntu-6.10.manifest.xml",
      #      :aws_is_public => true,
      #      :aws_architecture => "i386",
      #      :aws_image_type => "machine"},
      #     {...},
      #     {...} ]
      #
      # If +list+ param is set, then retrieve information about the listed images only:
      #
      #  ec2.describe_images(['ami-e4b6538d']) #=>
      #    [{:aws_owner => "522821470517",
      #      :aws_id => "ami-e4b6538d",
      #      :aws_state => "available",
      #      :aws_location => "marcins_cool_public_images/ubuntu-6.10.manifest.xml",
      #      :aws_is_public => true,
      #      :aws_architecture => "i386",
      #      :aws_image_type => "machine"}]
      #
    def describe_images(list=[], image_type=nil)
      list = list.to_a
      cache_for = list.empty? && !image_type ? :describe_images : nil
      ec2_describe_images({ 'ImageId' => list }, image_type, cache_for)
    end

      #
      #  Example:
      #
      #   ec2.describe_images_by_owner('522821470517')
      #   ec2.describe_images_by_owner('self')
      #
    def describe_images_by_owner(list=['self'], image_type=nil)
      list = list.to_a
      cache_for = list==['self'] && !image_type ? :describe_images_by_owner : nil
      ec2_describe_images({ 'Owner' => list }, image_type, cache_for)
    end

      #
      #  Example:
      #
      #   ec2.describe_images_by_executable_by('522821470517')
      #   ec2.describe_images_by_executable_by('self')
      #   ec2.describe_images_by_executable_by('all')
      #
    def describe_images_by_executable_by(list=['self'], image_type=nil)
      list = list.to_a
      cache_for = list==['self'] && !image_type ? :describe_images_by_executable_by : nil
      ec2_describe_images({ 'ExecutableBy' => list }, image_type, cache_for)
    end


      # Register new image at Amazon.
      # Returns new image id or an exception.
      #
      #  ec2.register_image('bucket/key/manifest') #=> 'ami-e444444d'
      #
    def register_image(image_location)
      link = generate_request("RegisterImage",
                              'ImageLocation' => image_location.to_s)
      request_info(link, QEc2RegisterImageParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Deregister image at Amazon. Returns +true+ or an exception.
      #
      #  ec2.deregister_image('ami-e444444d') #=> true
      #
    def deregister_image(image_id)
      link = generate_request("DeregisterImage",
                              'ImageId' => image_id.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end


      # Describe image attributes. Currently 'launchPermission', 'productCodes', 'kernel', 'ramdisk' and 'blockDeviceMapping'  are supported.
      #
      #  ec2.describe_image_attribute('ami-e444444d') #=> {:groups=>["all"], :users=>["000000000777"]}
      #
    def describe_image_attribute(image_id, attribute='launchPermission')
      link = generate_request("DescribeImageAttribute",
                              'ImageId'   => image_id,
                              'Attribute' => attribute)
      request_info(link, QEc2DescribeImageAttributeParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Reset image attribute. Currently, only 'launchPermission' is supported. Returns +true+ or an exception.
      #
      #  ec2.reset_image_attribute('ami-e444444d') #=> true
      #
    def reset_image_attribute(image_id, attribute='launchPermission')
      link = generate_request("ResetImageAttribute",
                              'ImageId'   => image_id,
                              'Attribute' => attribute)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Modify an image's attributes. It is recommended that you use
      # modify_image_launch_perm_add_users, modify_image_launch_perm_remove_users, etc.
      # instead of modify_image_attribute because the signature of
      # modify_image_attribute may change with EC2 service changes.
      #
      #  attribute      : currently, only 'launchPermission' is supported.
      #  operation_type : currently, only 'add' & 'remove' are supported.
      #  vars:
      #    :user_group  : currently, only 'all' is supported.
      #    :user_id
      #    :product_code
    def modify_image_attribute(image_id, attribute, operation_type = nil, vars = {})
      params =  {'ImageId'   => image_id,
                 'Attribute' => attribute}
      params['OperationType'] = operation_type if operation_type
      params.update(hash_params('UserId',      vars[:user_id].to_a))    if vars[:user_id]
      params.update(hash_params('UserGroup',   vars[:user_group].to_a)) if vars[:user_group]
      params.update(hash_params('ProductCode', vars[:product_code]))    if vars[:product_code]
      link = generate_request("ModifyImageAttribute", params)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Grant image launch permissions to users.
      # Parameter +userId+ is a list of user AWS account ids.
      # Returns +true+ or an exception.
      #
      #  ec2.modify_image_launch_perm_add_users('ami-e444444d',['000000000777','000000000778']) #=> true
    def modify_image_launch_perm_add_users(image_id, user_id=[])
      modify_image_attribute(image_id, 'launchPermission', 'add', :user_id => user_id.to_a)
    end

      # Revokes image launch permissions for users. +userId+ is a list of users AWS accounts ids. Returns +true+ or an exception.
      #
      #  ec2.modify_image_launch_perm_remove_users('ami-e444444d',['000000000777','000000000778']) #=> true
      #
    def modify_image_launch_perm_remove_users(image_id, user_id=[])
      modify_image_attribute(image_id, 'launchPermission', 'remove', :user_id => user_id.to_a)
    end

      # Add image launch permissions for users groups (currently only 'all' is supported, which gives public launch permissions).
      # Returns +true+ or an exception.
      #
      #  ec2.modify_image_launch_perm_add_groups('ami-e444444d') #=> true
      #
    def modify_image_launch_perm_add_groups(image_id, user_group=['all'])
      modify_image_attribute(image_id, 'launchPermission', 'add', :user_group => user_group.to_a)
    end

      # Remove image launch permissions for users groups (currently only 'all' is supported, which gives public launch permissions).
      #
      #  ec2.modify_image_launch_perm_remove_groups('ami-e444444d') #=> true
      #
    def modify_image_launch_perm_remove_groups(image_id, user_group=['all'])
      modify_image_attribute(image_id, 'launchPermission', 'remove', :user_group => user_group.to_a)
    end

      # Add product code to image
      #
      #  ec2.modify_image_product_code('ami-e444444d','0ABCDEF') #=> true
      #
    def modify_image_product_code(image_id, product_code=[])
      modify_image_attribute(image_id, 'productCodes', nil, :product_code => product_code.to_a)
    end

  #-----------------------------------------------------------------
  #      Instances
  #-----------------------------------------------------------------

    def get_desc_instances(instances)  # :nodoc:
      result = []
      instances.each do |reservation|
        reservation[:instances_set].each do |instance|
          # Parse and remove timestamp from the reason string. The timestamp is of
          # the request, not when EC2 took action, thus confusing & useless...
          instance[:aws_reason]         = instance[:aws_reason].sub(/\(\d[^)]*GMT\) */, '')
          instance[:aws_owner]          = reservation[:aws_owner]
          instance[:aws_reservation_id] = reservation[:aws_reservation_id]
          instance[:aws_groups]         = reservation[:aws_groups]
          result << instance
        end
      end
      result
    rescue Exception
      on_exception
    end

   def describe_availability_zones(options={})
      link = generate_request("DescribeAvailabilityZones", options={})
      request_info_xml_simple(:rds_connection, @params, link, @logger,
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
    rescue Exception
      on_exception
    end

      # Retrieve information about EC2 instances. If +list+ is omitted then returns the
      # list of all instances.
      #
      #  ec2.describe_instances #=>
      #    [{:aws_image_id       => "ami-e444444d",
      #      :aws_reason         => "",
      #      :aws_state_code     => "16",
      #      :aws_owner          => "000000000888",
      #      :aws_instance_id    => "i-123f1234",
      #      :aws_reservation_id => "r-aabbccdd",
      #      :aws_state          => "running",
      #      :dns_name           => "domU-12-34-67-89-01-C9.usma2.compute.amazonaws.com",
      #      :ssh_key_name       => "staging",
      #      :aws_groups         => ["default"],
      #      :private_dns_name   => "domU-12-34-67-89-01-C9.usma2.compute.amazonaws.com",
      #      :aws_instance_type  => "m1.small",
      #      :aws_launch_time    => "2008-1-1T00:00:00.000Z"},
      #      :aws_availability_zone => "us-east-1b",
      #      :aws_kernel_id      => "aki-ba3adfd3",
      #      :aws_ramdisk_id     => "ari-badbad00",
      #      :monitoring_state         => ...,
      #       ..., {...}]
      #
    def describe_instances(list=[])
      link = generate_request("DescribeInstances", hash_params('InstanceId',list.to_a))
      request_cache_or_info(:describe_instances, link,  QEc2DescribeInstancesParser, @@bench, list.blank?) do |parser|
        get_desc_instances(parser.result)
      end
    rescue Exception
      on_exception
    end

      # Return the product code attached to instance or +nil+ otherwise.
      #
      #  ec2.confirm_product_instance('ami-e444444d','12345678') #=> nil
      #  ec2.confirm_product_instance('ami-e444444d','00001111') #=> "000000000888"
      #
    def confirm_product_instance(instance, product_code)
      link = generate_request("ConfirmProductInstance", { 'ProductCode' => product_code,
                                'InstanceId'  => instance })
      request_info(link, QEc2ConfirmProductInstanceParser.new(:logger => @logger))
    end

      # DEPRECATED, USE launch_instances instead.
      #
      # Launch new EC2 instances. Returns a list of launched instances or an exception.
      #
      #  ec2.run_instances('ami-e444444d',1,1,['my_awesome_group'],'my_awesome_key', 'Woohoo!!!', 'public') #=>
      #   [{:aws_image_id       => "ami-e444444d",
      #     :aws_reason         => "",
      #     :aws_state_code     => "0",
      #     :aws_owner          => "000000000888",
      #     :aws_instance_id    => "i-123f1234",
      #     :aws_reservation_id => "r-aabbccdd",
      #     :aws_state          => "pending",
      #     :dns_name           => "",
      #     :ssh_key_name       => "my_awesome_key",
      #     :aws_groups         => ["my_awesome_group"],
      #     :private_dns_name   => "",
      #     :aws_instance_type  => "m1.small",
      #     :aws_launch_time    => "2008-1-1T00:00:00.000Z"
      #     :aws_ramdisk_id     => "ari-8605e0ef"
      #     :aws_kernel_id      => "aki-9905e0f0",
      #     :ami_launch_index   => "0",
      #     :aws_availability_zone => "us-east-1b"
      #     }]
      #
    def run_instances(image_id, min_count, max_count, group_ids, key_name, user_data='',
                      addressing_type = nil, instance_type = nil,
                      kernel_id = nil, ramdisk_id = nil, availability_zone = nil,
                      block_device_mappings = nil)
 	    launch_instances(image_id, { :min_count       => min_count,
 	                                 :max_count       => max_count,
 	                                 :user_data       => user_data,
                                   :group_ids       => group_ids,
                                   :key_name        => key_name,
                                   :instance_type   => instance_type,
                                   :addressing_type => addressing_type,
                                   :kernel_id       => kernel_id,
                                   :ramdisk_id      => ramdisk_id,
                                   :availability_zone     => availability_zone,
                                   :block_device_mappings => block_device_mappings
                                 })
    end


      # Launch new EC2 instances. Returns a list of launched instances or an exception.
      #
      # +lparams+ keys (default values in parenthesis):
      #  :min_count              fixnum, (1)
      #  :max_count              fixnum, (1)
      #  :group_ids              array or string ([] == 'default')
      #  :instance_type          string (DEFAULT_INSTACE_TYPE)
      #  :addressing_type        string (DEFAULT_ADDRESSING_TYPE
      #  :key_name               string
      #  :kernel_id              string
      #  :ramdisk_id             string
      #  :availability_zone      string
      #  :block_device_mappings  string
      #  :user_data              string
      #  :monitoring_enabled     boolean (default=false)
      #
      #  ec2.launch_instances('ami-e444444d', :group_ids => 'my_awesome_group',
      #                                       :user_data => "Woohoo!!!",
      #                                       :addressing_type => "public",
      #                                       :key_name => "my_awesome_key",
      #                                       :availability_zone => "us-east-1c") #=>
      #   [{:aws_image_id       => "ami-e444444d",
      #     :aws_reason         => "",
      #     :aws_state_code     => "0",
      #     :aws_owner          => "000000000888",
      #     :aws_instance_id    => "i-123f1234",
      #     :aws_reservation_id => "r-aabbccdd",
      #     :aws_state          => "pending",
      #     :dns_name           => "",
      #     :ssh_key_name       => "my_awesome_key",
      #     :aws_groups         => ["my_awesome_group"],
      #     :private_dns_name   => "",
      #     :aws_instance_type  => "m1.small",
      #     :aws_launch_time    => "2008-1-1T00:00:00.000Z",
      #     :aws_ramdisk_id     => "ari-8605e0ef"
      #     :aws_kernel_id      => "aki-9905e0f0",
      #     :ami_launch_index   => "0",
      #     :aws_availability_zone => "us-east-1c"
      #     }]
      #
    def launch_instances(image_id, options={})
      @logger.info("Launching instance of image #{image_id} for #{@aws_access_key_id}, " +
                   "key: #{options[:key_name]}, groups: #{(options[:group_ids]).to_a.join(',')}")
      # careful: keyName and securityGroups may be nil
      params = hash_params('SecurityGroup', options[:group_ids].to_a)
      params.update( {'ImageId'        => image_id,
                      'MinCount'       => (options[:min_count] || 1).to_s,
                      'MaxCount'       => (options[:max_count] || 1).to_s,
                      'AddressingType' => options[:addressing_type] || DEFAULT_ADDRESSING_TYPE,
                      'InstanceType'   => options[:instance_type]   || DEFAULT_INSTANCE_TYPE })
      # optional params
      params['KeyName']                    = options[:key_name]              unless options[:key_name].blank?
      params['KernelId']                   = options[:kernel_id]             unless options[:kernel_id].blank?
      params['RamdiskId']                  = options[:ramdisk_id]            unless options[:ramdisk_id].blank?
      params['Placement.AvailabilityZone'] = options[:availability_zone]     unless options[:availability_zone].blank?
      params['BlockDeviceMappings']        = options[:block_device_mappings] unless options[:block_device_mappings].blank?
      params['Monitoring.Enabled']         = options[:monitoring_enabled]    unless options[:monitoring_enabled].blank?
      params['SubnetId']                          = options[:subnet_id]                            unless options[:subnet_id].blank?
      params['AdditionalInfo']                    = options[:additional_info]                      unless options[:additional_info].blank?
      params['DisableApiTermination']             = options[:disable_api_termination].to_s         unless options[:disable_api_termination].nil?
      params['InstanceInitiatedShutdownBehavior'] = options[:instance_initiated_shutdown_behavior] unless options[:instance_initiated_shutdown_behavior].blank?
      unless options[:user_data].blank?
        options[:user_data].strip!
          # Do not use CGI::escape(encode64(...)) as it is done in Amazons EC2 library.
          # Amazon 169.254.169.254 does not like escaped symbols!
          # And it doesn't like "\n" inside of encoded string! Grrr....
          # Otherwise, some of UserData symbols will be lost...
        params['UserData'] = Base64.encode64(options[:user_data]).delete("\n").strip unless options[:user_data].blank?
      end
      link = generate_request("RunInstances", params)
        #debugger
      instances = request_info(link, QEc2DescribeInstancesParser.new(:logger => @logger))
      get_desc_instances(instances)
    rescue Exception
      on_exception
    end

    def monitor_instances(list=[])
      link = generate_request("MonitorInstances", hash_params('InstanceId',list.to_a))
      request_info(link, QEc2TerminateInstancesParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Terminates EC2 instances. Returns a list of termination params or an exception.
      #
      #  ec2.terminate_instances(['i-f222222d','i-f222222e']) #=>
      #    [{:aws_shutdown_state      => "shutting-down",
      #      :aws_instance_id         => "i-f222222d",
      #      :aws_shutdown_state_code => 32,
      #      :aws_prev_state          => "running",
      #      :aws_prev_state_code     => 16},
      #     {:aws_shutdown_state      => "shutting-down",
      #      :aws_instance_id         => "i-f222222e",
      #      :aws_shutdown_state_code => 32,
      #      :aws_prev_state          => "running",
      #      :aws_prev_state_code     => 16}]
      #
    def terminate_instances(list=[])
      link = generate_request("TerminateInstances", hash_params('InstanceId',list.to_a))
      request_info(link, QEc2TerminateInstancesParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Retreive EC2 instance OS logs. Returns a hash of data or an exception.
      #
      #  ec2.get_console_output('i-f222222d') =>
      #    {:aws_instance_id => 'i-f222222d',
      #     :aws_timestamp   => "2007-05-23T14:36:07.000-07:00",
      #     :timestamp       => Wed May 23 21:36:07 UTC 2007,          # Time instance
      #     :aws_output      => "Linux version 2.6.16-xenU (builder@patchbat.amazonsa) (gcc version 4.0.1 20050727 ..."
    def get_console_output(instance_id)
      link = generate_request("GetConsoleOutput", { 'InstanceId.1' => instance_id })
      request_info(link, QEc2GetConsoleOutputParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Reboot an EC2 instance. Returns +true+ or an exception.
      #
      #  ec2.reboot_instances(['i-f222222d','i-f222222e']) #=> true
      #
    def reboot_instances(list)
      link = generate_request("RebootInstances", hash_params('InstanceId', list.to_a))
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

  #-----------------------------------------------------------------
  #      Instances: Windows addons
  #-----------------------------------------------------------------

      # Get initial Windows Server setup password from an instance console output.
      #
      #  my_awesome_key = ec2.create_key_pair('my_awesome_key') #=>
      #    {:aws_key_name    => "my_awesome_key",
      #     :aws_fingerprint => "01:02:03:f4:25:e6:97:e8:9b:02:1a:26:32:4e:58:6b:7a:8c:9f:03",
      #     :aws_material    => "-----BEGIN RSA PRIVATE KEY-----\nMIIEpQIBAAK...Q8MDrCbuQ=\n-----END RSA PRIVATE KEY-----"}
      #
      #  my_awesome_instance = ec2.run_instances('ami-a000000a',1,1,['my_awesome_group'],'my_awesome_key', 'WindowsInstance!!!') #=>
      #   [{:aws_image_id       => "ami-a000000a",
      #     :aws_instance_id    => "i-12345678",
      #     ...
      #     :aws_availability_zone => "us-east-1b"
      #     }]
      #
      #  # wait until instance enters 'operational' state and get it's initial password
      #
      #  puts ec2.get_initial_password(my_awesome_instance[:aws_instance_id], my_awesome_key[:aws_material]) #=> "MhjWcgZuY6"
      #
    def get_initial_password(instance_id, private_key)
      console_output = get_console_output(instance_id)
      crypted_password = console_output[:aws_output][%r{<Password>(.+)</Password>}m] && $1
      unless crypted_password
        raise AwsError.new("Initial password was not found in console output for #{instance_id}")
      else
        OpenSSL::PKey::RSA.new(private_key).private_decrypt(Base64.decode64(crypted_password))
      end
    rescue Exception
      on_exception
    end

    # Bundle a Windows image.
    # Internally, it queues the bundling task and shuts down the instance.
    # It then takes a snapshot of the Windows volume bundles it, and uploads it to
    # S3. After bundling completes, Aws::Ec2#register_image may be used to
    # register the new Windows AMI for subsequent launches.
    #
    #   ec2.bundle_instance('i-e3e24e8a', 'my-awesome-bucket', 'my-win-image-1') #=>
    #    [{:aws_update_time => "2008-10-16T13:58:25.000Z",
    #      :s3_bucket       => "kd-win-1",
    #      :s3_prefix       => "win2pr",
    #      :aws_state       => "pending",
    #      :aws_id          => "bun-26a7424f",
    #      :aws_instance_id => "i-878a25ee",
    #      :aws_start_time  => "2008-10-16T13:58:02.000Z"}]
    #
    def bundle_instance(instance_id, s3_bucket, s3_prefix,
                        s3_owner_aws_access_key_id=nil, s3_owner_aws_secret_access_key=nil,
                        s3_expires = S3Interface::DEFAULT_EXPIRES_AFTER,
                        s3_upload_policy='ec2-bundle-read')
      # S3 access and signatures
      s3_owner_aws_access_key_id     ||= @aws_access_key_id
      s3_owner_aws_secret_access_key ||= @aws_secret_access_key
      s3_expires = Time.now.utc + s3_expires if s3_expires.is_a?(Fixnum) && (s3_expires < S3Interface::ONE_YEAR_IN_SECONDS)
      # policy
      policy = { 'expiration' => s3_expires.strftime('%Y-%m-%dT%H:%M:%SZ'),
                 'conditions' => [ { 'bucket' => s3_bucket },
                                   { 'acl'    => s3_upload_policy },
                                   [ 'starts-with', '$key', s3_prefix ] ] }.to_json
      policy64        = Base64.encode64(policy).gsub("\n","")
      signed_policy64 = AwsUtils.sign(s3_owner_aws_secret_access_key, policy64)
      # fill request params
      params = { 'InstanceId'                       => instance_id,
                 'Storage.S3.AWSAccessKeyId'        => s3_owner_aws_access_key_id,
                 'Storage.S3.UploadPolicy'          => policy64,
                 'Storage.S3.UploadPolicySignature' => signed_policy64,
                 'Storage.S3.Bucket'                => s3_bucket,
                 'Storage.S3.Prefix'                => s3_prefix,
                 }
      link = generate_request("BundleInstance", params)
      request_info(link, QEc2BundleInstanceParser.new)
    rescue Exception
      on_exception
    end

      # Describe the status of the Windows AMI bundlings.
      # If +list+ is omitted the returns the whole list of tasks.
      #
      #  ec2.describe_bundle_tasks(['bun-4fa74226']) #=>
      #    [{:s3_bucket         => "my-awesome-bucket"
      #      :aws_id            => "bun-0fa70206",
      #      :s3_prefix         => "win1pr",
      #      :aws_start_time    => "2008-10-14T16:27:57.000Z",
      #      :aws_update_time   => "2008-10-14T16:37:10.000Z",
      #      :aws_error_code    => "Client.S3Error",
      #      :aws_error_message =>
      #       "AccessDenied(403)- Invalid according to Policy: Policy Condition failed: [\"eq\", \"$acl\", \"aws-exec-read\"]",
      #      :aws_state         => "failed",
      #      :aws_instance_id   => "i-e3e24e8a"}]
      #
    def describe_bundle_tasks(list=[])
      link = generate_request("DescribeBundleTasks", hash_params('BundleId', list.to_a))
      request_info(link, QEc2DescribeBundleTasksParser.new)
    rescue Exception
      on_exception
    end

      # Cancel an in‐progress or pending bundle task by id.
      #
      #  ec2.cancel_bundle_task('bun-73a7421a') #=>
      #   [{:s3_bucket         => "my-awesome-bucket"
      #     :aws_id            => "bun-0fa70206",
      #     :s3_prefix         => "win02",
      #     :aws_start_time    => "2008-10-14T13:00:29.000Z",
      #     :aws_error_message => "User has requested bundling operation cancellation",
      #     :aws_state         => "failed",
      #     :aws_update_time   => "2008-10-14T13:01:31.000Z",
      #     :aws_error_code    => "Client.Cancelled",
      #     :aws_instance_id   => "i-e3e24e8a"}
      #
    def cancel_bundle_task(bundle_id)
      link = generate_request("CancelBundleTask", { 'BundleId' => bundle_id })
      request_info(link, QEc2BundleInstanceParser.new)
    rescue Exception
      on_exception
    end

  #-----------------------------------------------------------------
  #      Security groups
  #-----------------------------------------------------------------

      # Retrieve Security Group information. If +list+ is omitted the returns the whole list of groups.
      #
      #  ec2.describe_security_groups #=>
      #    [{:aws_group_name  => "default-1",
      #      :aws_owner       => "000000000888",
      #      :aws_description => "Default allowing SSH, HTTP, and HTTPS ingress",
      #      :aws_perms       =>
      #        [{:owner => "000000000888", :group => "default"},
      #         {:owner => "000000000888", :group => "default-1"},
      #         {:to_port => "-1",  :protocol => "icmp", :from_port => "-1",  :cidr_ips => "0.0.0.0/0"},
      #         {:to_port => "22",  :protocol => "tcp",  :from_port => "22",  :cidr_ips => "0.0.0.0/0"},
      #         {:to_port => "80",  :protocol => "tcp",  :from_port => "80",  :cidr_ips => "0.0.0.0/0"},
      #         {:to_port => "443", :protocol => "tcp",  :from_port => "443", :cidr_ips => "0.0.0.0/0"}]},
      #    ..., {...}]
      #
    def describe_security_groups(list=[])
      link = generate_request("DescribeSecurityGroups", hash_params('GroupName',list.to_a))
      request_cache_or_info( :describe_security_groups, link,  QEc2DescribeSecurityGroupsParser, @@bench, list.blank?) do |parser|
        result = []
        parser.result.each do |item|
          perms = []
          item.ipPermissions.each do |perm|
            perm.groups.each do |ngroup|
              perms << {:group => ngroup.groupName,
                        :owner => ngroup.userId}
            end
            perm.ipRanges.each do |cidr_ip|
              perms << {:from_port => perm.fromPort,
                        :to_port   => perm.toPort,
                        :protocol  => perm.ipProtocol,
                        :cidr_ips  => cidr_ip}
            end
          end

             # delete duplication
          perms.each_index do |i|
            (0...i).each do |j|
              if perms[i] == perms[j] then perms[i] = nil; break; end
            end
          end
          perms.compact!

          result << {:aws_owner       => item.ownerId,
                     :aws_group_name  => item.groupName,
                     :aws_description => item.groupDescription,
                     :aws_perms       => perms}

        end
        result
      end
    rescue Exception
      on_exception
    end

      # Create new Security Group. Returns +true+ or an exception.
      #
      #  ec2.create_security_group('default-1',"Default allowing SSH, HTTP, and HTTPS ingress") #=> true
      #
    def create_security_group(name, description)
      # EC2 doesn't like an empty description...
      description = " " if description.blank?
      link = generate_request("CreateSecurityGroup",
                              'GroupName'        => name.to_s,
                              'GroupDescription' => description.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Remove Security Group. Returns +true+ or an exception.
      #
      #  ec2.delete_security_group('default-1') #=> true
      #
    def delete_security_group(name)
      link = generate_request("DeleteSecurityGroup",
                              'GroupName' => name.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Authorize named ingress for security group. Allows instances that are member of someone
      # else's security group to open connections to instances in my group.
      #
      #  ec2.authorize_security_group_named_ingress('my_awesome_group', '7011-0219-8268', 'their_group_name') #=> true
      #
    def authorize_security_group_named_ingress(name, owner, group)
      link = generate_request("AuthorizeSecurityGroupIngress",
                              'GroupName'                  => name.to_s,
                                'SourceSecurityGroupName'    => group.to_s,
                              'SourceSecurityGroupOwnerId' => owner.to_s.gsub(/-/,''))
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Revoke named ingress for security group.
      #
      #  ec2.revoke_security_group_named_ingress('my_awesome_group', aws_user_id, 'another_group_name') #=> true
      #
    def revoke_security_group_named_ingress(name, owner, group)
      link = generate_request("RevokeSecurityGroupIngress",
                              'GroupName'                  => name.to_s,
                              'SourceSecurityGroupName'    => group.to_s,
                              'SourceSecurityGroupOwnerId' => owner.to_s.gsub(/-/,''))
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Add permission to a security group. Returns +true+ or an exception. +protocol+ is one of :'tcp'|'udp'|'icmp'.
      #
      #  ec2.authorize_security_group_IP_ingress('my_awesome_group', 80, 82, 'udp', '192.168.1.0/8') #=> true
      #  ec2.authorize_security_group_IP_ingress('my_awesome_group', -1, -1, 'icmp') #=> true
      #
    def authorize_security_group_IP_ingress(name, from_port, to_port, protocol='tcp', cidr_ip='0.0.0.0/0')
      link = generate_request("AuthorizeSecurityGroupIngress",
                              'GroupName'  => name.to_s,
                              'IpProtocol' => protocol.to_s,
                              'FromPort'   => from_port.to_s,
                              'ToPort'     => to_port.to_s,
                              'CidrIp'     => cidr_ip.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Remove permission from a security group. Returns +true+ or an exception. +protocol+ is one of :'tcp'|'udp'|'icmp' ('tcp' is default).
      #
      #  ec2.revoke_security_group_IP_ingress('my_awesome_group', 80, 82, 'udp', '192.168.1.0/8') #=> true
      #
    def revoke_security_group_IP_ingress(name, from_port, to_port, protocol='tcp', cidr_ip='0.0.0.0/0')
      link = generate_request("RevokeSecurityGroupIngress",
                              'GroupName'  => name.to_s,
                              'IpProtocol' => protocol.to_s,
                              'FromPort'   => from_port.to_s,
                              'ToPort'     => to_port.to_s,
                              'CidrIp'     => cidr_ip.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

  #-----------------------------------------------------------------
  #      Keys
  #-----------------------------------------------------------------

      # Retrieve a list of SSH keys. Returns an array of keys or an exception. Each key is
      # represented as a two-element hash.
      #
      #  ec2.describe_key_pairs #=>
      #    [{:aws_fingerprint=> "01:02:03:f4:25:e6:97:e8:9b:02:1a:26:32:4e:58:6b:7a:8c:9f:03", :aws_key_name=>"key-1"},
      #     {:aws_fingerprint=> "1e:29:30:47:58:6d:7b:8c:9f:08:11:20:3c:44:52:69:74:80:97:08", :aws_key_name=>"key-2"},
      #      ..., {...} ]
      #
    def describe_key_pairs(list=[])
      link = generate_request("DescribeKeyPairs", hash_params('KeyName',list.to_a))
      request_cache_or_info :describe_key_pairs, link,  QEc2DescribeKeyPairParser, @@bench, list.blank?
    rescue Exception
      on_exception
    end

      # Create new SSH key. Returns a hash of the key's data or an exception.
      #
      #  ec2.create_key_pair('my_awesome_key') #=>
      #    {:aws_key_name    => "my_awesome_key",
      #     :aws_fingerprint => "01:02:03:f4:25:e6:97:e8:9b:02:1a:26:32:4e:58:6b:7a:8c:9f:03",
      #     :aws_material    => "-----BEGIN RSA PRIVATE KEY-----\nMIIEpQIBAAK...Q8MDrCbuQ=\n-----END RSA PRIVATE KEY-----"}
      #
    def create_key_pair(name)
      link = generate_request("CreateKeyPair",
                              'KeyName' => name.to_s)
      request_info(link, QEc2CreateKeyPairParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

      # Delete a key pair. Returns +true+ or an exception.
      #
      #  ec2.delete_key_pair('my_awesome_key') #=> true
      #
    def delete_key_pair(name)
      link = generate_request("DeleteKeyPair",
                              'KeyName' => name.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

  #-----------------------------------------------------------------
  #      Elastic IPs
  #-----------------------------------------------------------------

    # Acquire a new elastic IP address for use with your account.
    # Returns allocated IP address or an exception.
    #
    #  ec2.allocate_address #=> '75.101.154.140'
    #
    def allocate_address
      link = generate_request("AllocateAddress")
      request_info(link, QEc2AllocateAddressParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

    # Associate an elastic IP address with an instance.
    # Returns +true+ or an exception.
    #
    #  ec2.associate_address('i-d630cbbf', '75.101.154.140') #=> true
    #
    def associate_address(instance_id, public_ip)
      link = generate_request("AssociateAddress",
                              "InstanceId" => instance_id.to_s,
                              "PublicIp"   => public_ip.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

    # List elastic IP addresses assigned to your account.
    # Returns an array of 2 keys (:instance_id and :public_ip) hashes:
    #
    #  ec2.describe_addresses  #=> [{:instance_id=>"i-d630cbbf", :public_ip=>"75.101.154.140"},
    #                               {:instance_id=>nil, :public_ip=>"75.101.154.141"}]
    #
    #  ec2.describe_addresses('75.101.154.140') #=> [{:instance_id=>"i-d630cbbf", :public_ip=>"75.101.154.140"}]
    #
    def describe_addresses(list=[])
      link = generate_request("DescribeAddresses",
                              hash_params('PublicIp',list.to_a))
      request_cache_or_info :describe_addresses, link,  QEc2DescribeAddressesParser, @@bench, list.blank?
    rescue Exception
      on_exception
    end

    # Disassociate the specified elastic IP address from the instance to which it is assigned.
    # Returns +true+ or an exception.
    #
    #  ec2.disassociate_address('75.101.154.140') #=> true
    #
    def disassociate_address(public_ip)
      link = generate_request("DisassociateAddress",
                              "PublicIp" => public_ip.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

    # Release an elastic IP address associated with your account.
    # Returns +true+ or an exception.
    #
    #  ec2.release_address('75.101.154.140') #=> true
    #
    def release_address(public_ip)
      link = generate_request("ReleaseAddress",
                              "PublicIp" => public_ip.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

  #-----------------------------------------------------------------
  #      Availability zones
  #-----------------------------------------------------------------

    # Describes availability zones that are currently available to the account and their states.
    # Returns an array of 2 keys (:zone_name and :zone_state) hashes:
    #
    #  ec2.describe_availability_zones  #=> [{:region_name=>"us-east-1",
    #                                         :zone_name=>"us-east-1a",
    #                                         :zone_state=>"available"}, ... ]
    #
    #  ec2.describe_availability_zones('us-east-1c') #=> [{:region_name=>"us-east-1",
    #                                                      :zone_state=>"available",
    #                                                      :zone_name=>"us-east-1c"}]
    #
    def describe_availability_zones(list=[])
      link = generate_request("DescribeAvailabilityZones",
                              hash_params('ZoneName',list.to_a))
      request_cache_or_info :describe_availability_zones, link,  QEc2DescribeAvailabilityZonesParser, @@bench, list.blank?
    rescue Exception
      on_exception
    end

  #-----------------------------------------------------------------
  #      Regions
  #-----------------------------------------------------------------

    # Describe regions.
    #
    #  ec2.describe_regions  #=> ["eu-west-1", "us-east-1"]
    #
    def describe_regions(list=[])
      link = generate_request("DescribeRegions",
                              hash_params('RegionName',list.to_a))
      request_cache_or_info :describe_regions, link,  QEc2DescribeRegionsParser, @@bench, list.blank?
    rescue Exception
      on_exception
    end


  #-----------------------------------------------------------------
  #      EBS: Volumes
  #-----------------------------------------------------------------

    # Describe all EBS volumes.
    #
    #  ec2.describe_volumes #=>
    #      [{:aws_size              => 94,
    #        :aws_device            => "/dev/sdc",
    #        :aws_attachment_status => "attached",
    #        :zone                  => "merlot",
    #        :snapshot_id           => nil,
    #        :aws_attached_at       => Wed Jun 18 08:19:28 UTC 2008,
    #        :aws_status            => "in-use",
    #        :aws_id                => "vol-60957009",
    #        :aws_created_at        => Wed Jun 18 08:19:20s UTC 2008,
    #        :aws_instance_id       => "i-c014c0a9"},
    #       {:aws_size       => 1,
    #        :zone           => "merlot",
    #        :snapshot_id    => nil,
    #        :aws_status     => "available",
    #        :aws_id         => "vol-58957031",
    #        :aws_created_at => Wed Jun 18 08:19:21 UTC 2008,}, ... ]
    #
    def describe_volumes(list=[])
      link = generate_request("DescribeVolumes",
                              hash_params('VolumeId',list.to_a))
      request_cache_or_info :describe_volumes, link,  QEc2DescribeVolumesParser, @@bench, list.blank?
    rescue Exception
      on_exception
    end

    # Create new EBS volume based on previously created snapshot.
    # +Size+ in Gigabytes.
    #
    #  ec2.create_volume('snap-000000', 10, zone) #=>
    #      {:snapshot_id    => "snap-e21df98b",
    #       :aws_status     => "creating",
    #       :aws_id         => "vol-fc9f7a95",
    #       :zone           => "merlot",
    #       :aws_created_at => Tue Jun 24 18:13:32 UTC 2008,
    #       :aws_size       => 94}
    #
    def create_volume(snapshot_id, size, zone)
      link = generate_request("CreateVolume",
                              "SnapshotId"        => snapshot_id.to_s,
                              "Size"              => size.to_s,
                              "AvailabilityZone"  => zone.to_s )
      request_info(link, QEc2CreateVolumeParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

    # Delete the specified EBS volume.
    # This does not deletes any snapshots created from this volume.
    #
    #  ec2.delete_volume('vol-b48a6fdd') #=> true
    #
    def delete_volume(volume_id)
      link = generate_request("DeleteVolume",
                              "VolumeId" => volume_id.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

    # Attach the specified EBS volume to a specified instance, exposing the
    # volume using the specified device name.
    #
    #  ec2.attach_volume('vol-898a6fe0', 'i-7c905415', '/dev/sdh') #=>
    #    { :aws_instance_id => "i-7c905415",
    #      :aws_device      => "/dev/sdh",
    #      :aws_status      => "attaching",
    #      :aws_attached_at => "2008-03-28T14:14:39.000Z",
    #      :aws_id          => "vol-898a6fe0" }
    #
    def attach_volume(volume_id, instance_id, device)
      link = generate_request("AttachVolume",
                              "VolumeId"   => volume_id.to_s,
                              "InstanceId" => instance_id.to_s,
                              "Device"     => device.to_s)
      request_info(link, QEc2AttachAndDetachVolumeParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

    # Detach the specified EBS volume from the instance to which it is attached.
    #
    #   ec2.detach_volume('vol-898a6fe0') #=>
    #     { :aws_instance_id => "i-7c905415",
    #       :aws_device      => "/dev/sdh",
    #       :aws_status      => "detaching",
    #       :aws_attached_at => "2008-03-28T14:38:34.000Z",
    #       :aws_id          => "vol-898a6fe0"}
    #
    def detach_volume(volume_id, instance_id=nil, device=nil, force=nil)
      hash = { "VolumeId" => volume_id.to_s }
      hash["InstanceId"] = instance_id.to_s unless instance_id.blank?
      hash["Device"]     = device.to_s      unless device.blank?
      hash["Force"]      = 'true'           if     force
      #
      link = generate_request("DetachVolume", hash)
      request_info(link, QEc2AttachAndDetachVolumeParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end


  #-----------------------------------------------------------------
  #      EBS: Snapshots
  #-----------------------------------------------------------------

     # Describe all EBS snapshots.
     #
     # ec2.describe_snapshots #=>
     #   [ { :aws_progress   => "100%",
     #       :aws_status     => "completed",
     #       :aws_id         => "snap-72a5401b",
     #       :aws_volume_id  => "vol-5582673c",
     #       :aws_started_at => "2008-02-23T02:50:48.000Z"},
     #     { :aws_progress   => "100%",
     #       :aws_status     => "completed",
     #       :aws_id         => "snap-75a5401c",
     #       :aws_volume_id  => "vol-5582673c",
     #       :aws_started_at => "2008-02-23T16:23:19.000Z" },...]
     #
    def describe_snapshots(list=[])
      link = generate_request("DescribeSnapshots",
                              hash_params('SnapshotId',list.to_a))
      request_cache_or_info :describe_snapshots, link,  QEc2DescribeSnapshotsParser, @@bench, list.blank?
    rescue Exception
      on_exception
    end

    # Create a snapshot of specified volume.
    #
    #  ec2.create_snapshot('vol-898a6fe0') #=>
    #      {:aws_volume_id  => "vol-fd9f7a94",
    #       :aws_started_at => Tue Jun 24 18:40:40 UTC 2008,
    #       :aws_progress   => "",
    #       :aws_status     => "pending",
    #       :aws_id         => "snap-d56783bc"}
    #
    def create_snapshot(volume_id)
      link = generate_request("CreateSnapshot",
                              "VolumeId" => volume_id.to_s)
      request_info(link, QEc2CreateSnapshotParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

    # Create a snapshot of specified volume, but with the normal retry algorithms disabled.
    # This method will return immediately upon error.  The user can specify connect and read timeouts (in s)
    # for the connection to AWS.  If the user does not specify timeouts, try_create_snapshot uses the default values
    # in Rightscale::HttpConnection.
    #
    #  ec2.try_create_snapshot('vol-898a6fe0') #=>
    #      {:aws_volume_id  => "vol-fd9f7a94",
    #       :aws_started_at => Tue Jun 24 18:40:40 UTC 2008,
    #       :aws_progress   => "",
    #       :aws_status     => "pending",
    #       :aws_id         => "snap-d56783bc"}
    #
    def try_create_snapshot(volume_id, connect_timeout = nil, read_timeout = nil)
      # For safety in the ensure block...we don't want to restore values
      # if we never read them in the first place
      orig_reiteration_time = nil
      orig_http_params = nil

      orig_reiteration_time = Aws::AWSErrorHandler::reiteration_time
      Aws::AWSErrorHandler::reiteration_time = 0

      orig_http_params = Rightscale::HttpConnection::params()
      new_http_params = orig_http_params.dup
      new_http_params[:http_connection_retry_count] = 0
      new_http_params[:http_connection_open_timeout] = connect_timeout if !connect_timeout.nil?
      new_http_params[:http_connection_read_timeout] = read_timeout if !read_timeout.nil?
      Rightscale::HttpConnection::params = new_http_params

      link = generate_request("CreateSnapshot",
                              "VolumeId" => volume_id.to_s)
      request_info(link, QEc2CreateSnapshotParser.new(:logger => @logger))

    rescue Exception
      on_exception
    ensure
      Aws::AWSErrorHandler::reiteration_time = orig_reiteration_time if orig_reiteration_time
      Rightscale::HttpConnection::params = orig_http_params if orig_http_params
    end

    # Delete the specified snapshot.
    #
    #  ec2.delete_snapshot('snap-55a5403c') #=> true
    #
    def delete_snapshot(snapshot_id)
      link = generate_request("DeleteSnapshot",
                              "SnapshotId" => snapshot_id.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end
    
    # Add/replace one tag to a resource
    # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/index.html?ApiReference_query_CreateTags.html
    #
    #  ec2.create_tag('ami-1a2b3c4d', 'webserver') #=> true
    #  ec2.create_tag('i-7f4d3a2b',   'stack', 'Production') #=> true
    #
    def create_tag(resource_id, key, value = nil)
      link = generate_request("CreateTags",
                              "ResourceId.1" => resource_id.to_s,
                              "Tag.1.Key" => key.to_s,
                              "Tag.1.Value" => value.to_s)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end
    
    # Describe tags
    # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/index.html?ApiReference_query_DescribeTags.html
    #
    #  ec2.describe_tags
    #  ec2.describe_tags(
    #    'Filter.1.Name' => 'resource-type', 'Filter.1.Value.1' => 'instance',
    #    'Filter.2.Name' => 'value',         'Filter.2.Value.1' => 'Test', 'Filter.2.Value.2' => 'Production'
    #  )
    #
    def describe_tags(filters = {})
      link = generate_request("DescribeTags", filters)
      request_info(link, QEc2DescribeTagsParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end
    
    # Delete one or all tags from a resource
    # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/index.html?ApiReference_query_DeleteTags.html
    #
    #  ec2.delete_tag('i-7f4d3a2b', 'stack') #=> true
    #  ec2.delete_tag('i-7f4d3a2b', 'stack', 'Production') #=> true
    #
    # "If you omit Tag.n.Value, we delete the tag regardless of its value. If
    # you specify this parameter with an empty string as the value, we delete the
    # key only if its value is an empty string."
    # http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/ApiReference_query_DeleteTags.html
    #
    def delete_tag(resource_id, key, value = nil)
      request_args = {"ResourceId.1" => resource_id.to_s, "Tag.1.Key" => key.to_s}
      request_args["Tag.1.Value"] = value.to_s if value
      
      link = generate_request("DeleteTags", request_args)
      request_info(link, RightBoolResponseParser.new(:logger => @logger))
    rescue Exception
      on_exception
    end

  #-----------------------------------------------------------------
  #      PARSERS: Boolean Response Parser
  #-----------------------------------------------------------------

    class RightBoolResponseParser < AwsParser #:nodoc:
      def tagend(name)
        @result = @text=='true' ? true : false if name == 'return'
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: Key Pair
  #-----------------------------------------------------------------

    class QEc2DescribeKeyPairParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        @item = {} if name == 'item'
      end
      def tagend(name)
        case name
          when 'keyName'        then @item[:aws_key_name]    = @text
          when 'keyFingerprint' then @item[:aws_fingerprint] = @text
          when 'item'           then @result                << @item
        end
      end
      def reset
        @result = [];
      end
    end

    class QEc2CreateKeyPairParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        @result = {} if name == 'CreateKeyPairResponse'
      end
      def tagend(name)
        case name
          when 'keyName'        then @result[:aws_key_name]    = @text
          when 'keyFingerprint' then @result[:aws_fingerprint] = @text
          when 'keyMaterial'    then @result[:aws_material]    = @text
        end
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: Security Groups
  #-----------------------------------------------------------------

    class QEc2UserIdGroupPairType #:nodoc:
      attr_accessor :userId
      attr_accessor :groupName
    end

    class QEc2IpPermissionType #:nodoc:
      attr_accessor :ipProtocol
      attr_accessor :fromPort
      attr_accessor :toPort
      attr_accessor :groups
      attr_accessor :ipRanges
    end

    class QEc2SecurityGroupItemType #:nodoc:
      attr_accessor :groupName
      attr_accessor :groupDescription
      attr_accessor :ownerId
      attr_accessor :ipPermissions
    end


    class QEc2DescribeSecurityGroupsParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        case name
          when 'item'
            if @xmlpath=='DescribeSecurityGroupsResponse/securityGroupInfo'
              @group = QEc2SecurityGroupItemType.new
              @group.ipPermissions = []
            elsif @xmlpath=='DescribeSecurityGroupsResponse/securityGroupInfo/item/ipPermissions'
              @perm = QEc2IpPermissionType.new
              @perm.ipRanges = []
              @perm.groups   = []
            elsif @xmlpath=='DescribeSecurityGroupsResponse/securityGroupInfo/item/ipPermissions/item/groups'
              @sgroup = QEc2UserIdGroupPairType.new
            end
        end
      end
      def tagend(name)
        case name
          when 'ownerId'          then @group.ownerId   = @text
          when 'groupDescription' then @group.groupDescription = @text
          when 'groupName'
            if @xmlpath=='DescribeSecurityGroupsResponse/securityGroupInfo/item'
              @group.groupName  = @text
            elsif @xmlpath=='DescribeSecurityGroupsResponse/securityGroupInfo/item/ipPermissions/item/groups/item'
              @sgroup.groupName = @text
            end
          when 'ipProtocol'       then @perm.ipProtocol = @text
          when 'fromPort'         then @perm.fromPort   = @text
          when 'toPort'           then @perm.toPort     = @text
          when 'userId'           then @sgroup.userId   = @text
          when 'cidrIp'           then @perm.ipRanges  << @text
          when 'item'
            if @xmlpath=='DescribeSecurityGroupsResponse/securityGroupInfo/item/ipPermissions/item/groups'
              @perm.groups << @sgroup
            elsif @xmlpath=='DescribeSecurityGroupsResponse/securityGroupInfo/item/ipPermissions'
              @group.ipPermissions << @perm
            elsif @xmlpath=='DescribeSecurityGroupsResponse/securityGroupInfo'
              @result << @group
            end
        end
      end
      def reset
        @result = []
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: Images
  #-----------------------------------------------------------------

    class QEc2DescribeImagesParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        if name == 'item' && @xmlpath[%r{.*/imagesSet$}]
          @image = {}
        end
      end
      def tagend(name)
        case name
          when 'imageId'       then @image[:aws_id]       = @text
          when 'name'          then @image[:aws_name]     = @text
          when 'description'    then @image[:aws_description] = @text
          when 'imageLocation' then @image[:aws_location] = @text
          when 'imageState'    then @image[:aws_state]    = @text
          when 'imageOwnerId'  then @image[:aws_owner]    = @text
          when 'isPublic'      then @image[:aws_is_public]= @text == 'true' ? true : false
          when 'productCode'   then (@image[:aws_product_codes] ||= []) << @text
          when 'architecture'  then @image[:aws_architecture] = @text
          when 'imageType'     then @image[:aws_image_type] = @text
          when 'kernelId'      then @image[:aws_kernel_id]  = @text
          when 'ramdiskId'     then @image[:aws_ramdisk_id] = @text
          when 'item'          then @result << @image if @xmlpath[%r{.*/imagesSet$}]
        end
      end
      def reset
        @result = []
      end
    end

    class QEc2RegisterImageParser < AwsParser #:nodoc:
      def tagend(name)
        @result = @text if name == 'imageId'
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: Image Attribute
  #-----------------------------------------------------------------

    class QEc2DescribeImageAttributeParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        case name
          when 'launchPermission'
            @result[:groups] = []
            @result[:users]  = []
          when 'productCodes'
            @result[:aws_product_codes] = []
        end
      end
      def tagend(name)
          # right now only 'launchPermission' is supported by Amazon.
          # But nobody know what will they xml later as attribute. That is why we
          # check for 'group' and 'userId' inside of 'launchPermission/item'
        case name
          when 'imageId'            then @result[:aws_id] = @text
          when 'group'              then @result[:groups] << @text if @xmlpath == 'DescribeImageAttributeResponse/launchPermission/item'
          when 'userId'             then @result[:users]  << @text if @xmlpath == 'DescribeImageAttributeResponse/launchPermission/item'
          when 'productCode'        then @result[:aws_product_codes] << @text
          when 'kernel'             then @result[:aws_kernel]  = @text
          when 'ramdisk'            then @result[:aws_ramdisk] = @text
          when 'blockDeviceMapping' then @result[:block_device_mapping] = @text
        end
      end
      def reset
        @result = {}
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: Instances
  #-----------------------------------------------------------------

    class QEc2DescribeInstancesParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
           # DescribeInstances property
        if (name == 'item' && @xmlpath == 'DescribeInstancesResponse/reservationSet') ||
           # RunInstances property
           (name == 'RunInstancesResponse')
            @reservation = { :aws_groups    => [],
                             :instances_set => [] }

        elsif (name == 'item') &&
                # DescribeInstances property
              ( @xmlpath=='DescribeInstancesResponse/reservationSet/item/instancesSet' ||
               # RunInstances property
                @xmlpath=='RunInstancesResponse/instancesSet' )
              # the optional params (sometimes are missing and we dont want them to be nil)
            @instance = { :aws_reason       => '',
                          :dns_name         => '',
                          :private_dns_name => '',
                          :ami_launch_index => '',
                          :ssh_key_name     => '',
                          :aws_state        => '',
                          :aws_product_codes => [],
                          :tags             => {} }
        end
      end
      def tagend(name)
        case name
          # reservation
          when 'reservationId'    then @reservation[:aws_reservation_id] = @text
          when 'ownerId'          then @reservation[:aws_owner]          = @text
          when 'groupId'          then @reservation[:aws_groups]        << @text
          # instance
          when 'instanceId'       then @instance[:aws_instance_id]    = @text
          when 'imageId'          then @instance[:aws_image_id]       = @text
          when 'dnsName'          then @instance[:dns_name]           = @text
          when 'privateDnsName'   then @instance[:private_dns_name]   = @text
          when 'reason'           then @instance[:aws_reason]         = @text
          when 'keyName'          then @instance[:ssh_key_name]       = @text
          when 'amiLaunchIndex'   then @instance[:ami_launch_index]   = @text
          when 'code'             then @instance[:aws_state_code]     = @text
          when 'name'             then @instance[:aws_state]          = @text
          when 'productCode'      then @instance[:aws_product_codes] << @text
          when 'instanceType'     then @instance[:aws_instance_type]  = @text
          when 'launchTime'       then @instance[:aws_launch_time]    = @text
          when 'kernelId'         then @instance[:aws_kernel_id]      = @text
          when 'ramdiskId'        then @instance[:aws_ramdisk_id]     = @text
          when 'platform'         then @instance[:aws_platform]       = @text
          when 'availabilityZone' then @instance[:aws_availability_zone] = @text
          when 'privateIpAddress' then @instance[:aws_private_ip_address] = @text
          when 'key'              then @tag_key = @text
          when 'value'            then @tag_value = @text
          when 'state'
            if @xmlpath == 'DescribeInstancesResponse/reservationSet/item/instancesSet/item/monitoring' || # DescribeInstances property
               @xmlpath == 'RunInstancesResponse/instancesSet/item/monitoring'            # RunInstances property
              @instance[:monitoring_state] = @text
            end
          when 'item'
            if @xmlpath=='DescribeInstancesResponse/reservationSet/item/instancesSet/item/tagSet'    # Tags
              @instance[:tags][@tag_key] = @tag_value
            elsif @xmlpath == 'DescribeInstancesResponse/reservationSet/item/instancesSet' || # DescribeInstances property
                @xmlpath == 'RunInstancesResponse/instancesSet'            # RunInstances property
              @reservation[:instances_set] << @instance            
            elsif @xmlpath=='DescribeInstancesResponse/reservationSet'    # DescribeInstances property
              @result << @reservation  
            end
          when 'RunInstancesResponse' then @result << @reservation            # RunInstances property
        end
      end
      def reset
        @result = []
      end
    end

    class QEc2ConfirmProductInstanceParser < AwsParser #:nodoc:
      def tagend(name)
        @result = @text if name == 'ownerId'
      end
    end

    class QEc2MonitorInstancesParser < AwsParser #:nodoc:
         def tagstart(name, attributes)
           @instance = {} if name == 'item'
         end
         def tagend(name)
           case name
           when 'instanceId' then @instance[:aws_instance_id] = @text
           when 'state' then @instance[:aws_monitoring_state] = @text
           when 'item'  then @result << @instance
           end
         end
         def reset
           @result = []
         end
       end


    class QEc2TerminateInstancesParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        @instance = {} if name == 'item'
      end
      def tagend(name)
        case name
        when 'instanceId' then @instance[:aws_instance_id] = @text
        when 'code'
          if @xmlpath == 'TerminateInstancesResponse/instancesSet/item/shutdownState'
               @instance[:aws_shutdown_state_code] = @text.to_i
          else @instance[:aws_prev_state_code]     = @text.to_i end
        when 'name'
          if @xmlpath == 'TerminateInstancesResponse/instancesSet/item/shutdownState'
               @instance[:aws_shutdown_state] = @text
          else @instance[:aws_prev_state]     = @text end
        when 'item'       then @result << @instance
        end
      end
      def reset
        @result = []
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: Console
  #-----------------------------------------------------------------

    class QEc2GetConsoleOutputParser < AwsParser #:nodoc:
      def tagend(name)
        case name
        when 'instanceId' then @result[:aws_instance_id] = @text
        when 'timestamp'  then @result[:aws_timestamp]   = @text
                               @result[:timestamp]       = (Time.parse(@text)).utc
        when 'output'     then @result[:aws_output]      = Base64.decode64(@text)
        end
      end
      def reset
        @result = {}
      end
    end

  #-----------------------------------------------------------------
  #      Instances: Wondows related part
  #-----------------------------------------------------------------
    class QEc2DescribeBundleTasksParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        @bundle = {} if name == 'item'
      end
      def tagend(name)
        case name
#        when 'requestId'  then @bundle[:request_id]    = @text
        when 'instanceId' then @bundle[:aws_instance_id]   = @text
        when 'bundleId'   then @bundle[:aws_id]            = @text
        when 'bucket'     then @bundle[:s3_bucket]         = @text
        when 'prefix'     then @bundle[:s3_prefix]         = @text
        when 'startTime'  then @bundle[:aws_start_time]    = @text
        when 'updateTime' then @bundle[:aws_update_time]   = @text
        when 'state'      then @bundle[:aws_state]         = @text
        when 'progress'   then @bundle[:aws_progress]      = @text
        when 'code'       then @bundle[:aws_error_code]    = @text
        when 'message'    then @bundle[:aws_error_message] = @text
        when 'item'       then @result                    << @bundle
        end
      end
      def reset
        @result = []
      end
    end

    class QEc2BundleInstanceParser < AwsParser #:nodoc:
      def tagend(name)
        case name
#        when 'requestId'  then @result[:request_id]    = @text
        when 'instanceId' then @result[:aws_instance_id]   = @text
        when 'bundleId'   then @result[:aws_id]            = @text
        when 'bucket'     then @result[:s3_bucket]         = @text
        when 'prefix'     then @result[:s3_prefix]         = @text
        when 'startTime'  then @result[:aws_start_time]    = @text
        when 'updateTime' then @result[:aws_update_time]   = @text
        when 'state'      then @result[:aws_state]         = @text
        when 'progress'   then @result[:aws_progress]      = @text
        when 'code'       then @result[:aws_error_code]    = @text
        when 'message'    then @result[:aws_error_message] = @text
        end
      end
      def reset
        @result = {}
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: Elastic IPs
  #-----------------------------------------------------------------

    class QEc2AllocateAddressParser < AwsParser #:nodoc:
      def tagend(name)
        @result = @text if name == 'publicIp'
      end
    end

    class QEc2DescribeAddressesParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        @address = {} if name == 'item'
      end
      def tagend(name)
        case name
        when 'instanceId' then @address[:instance_id] = @text.blank? ? nil : @text
        when 'publicIp'   then @address[:public_ip]   = @text
        when 'item'       then @result << @address
        end
      end
      def reset
        @result = []
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: AvailabilityZones
  #-----------------------------------------------------------------

    class QEc2DescribeAvailabilityZonesParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        @zone = {} if name == 'item'
      end
      def tagend(name)
        case name
        when 'regionName' then @zone[:region_name] = @text
        when 'zoneName'   then @zone[:zone_name]   = @text
        when 'zoneState'  then @zone[:zone_state]  = @text
        when 'item'      then @result << @zone
        end
      end
      def reset
        @result = []
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: Regions
  #-----------------------------------------------------------------

    class QEc2DescribeRegionsParser < AwsParser #:nodoc:
      def tagend(name)
        @result << @text if name == 'regionName'
      end
      def reset
        @result = []
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: EBS - Volumes
  #-----------------------------------------------------------------

    class QEc2CreateVolumeParser < AwsParser #:nodoc:
      def tagend(name)
        case name
          when 'volumeId'         then @result[:aws_id]         = @text
          when 'status'           then @result[:aws_status]     = @text
          when 'createTime'       then @result[:aws_created_at] = Time.parse(@text)
          when 'size'             then @result[:aws_size]       = @text.to_i ###
          when 'snapshotId'       then @result[:snapshot_id]    = @text.blank? ? nil : @text ###
          when 'availabilityZone' then @result[:zone]           = @text ###
        end
      end
      def reset
        @result = {}
      end
    end

    class QEc2AttachAndDetachVolumeParser < AwsParser #:nodoc:
      def tagend(name)
        case name
          when 'volumeId'   then @result[:aws_id]                = @text
          when 'instanceId' then @result[:aws_instance_id]       = @text
          when 'device'     then @result[:aws_device]            = @text
          when 'status'     then @result[:aws_attachment_status] = @text
          when 'attachTime' then @result[:aws_attached_at]       = Time.parse(@text)
        end
      end
      def reset
        @result = {}
      end
    end

    class QEc2DescribeVolumesParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        case name
        when 'item'
          case @xmlpath
            when 'DescribeVolumesResponse/volumeSet' then @volume = {}
          end
        end
      end
      def tagend(name)
        case name
          when 'volumeId'
            case @xmlpath
            when 'DescribeVolumesResponse/volumeSet/item' then @volume[:aws_id] = @text
            end
          when 'status'
            case @xmlpath
            when 'DescribeVolumesResponse/volumeSet/item' then @volume[:aws_status] = @text
            when 'DescribeVolumesResponse/volumeSet/item/attachmentSet/item' then @volume[:aws_attachment_status] = @text
            end
          when 'size'             then @volume[:aws_size]        = @text.to_i
          when 'createTime'       then @volume[:aws_created_at]  = Time.parse(@text)
          when 'instanceId'       then @volume[:aws_instance_id] = @text
          when 'device'           then @volume[:aws_device]      = @text
          when 'attachTime'       then @volume[:aws_attached_at] = Time.parse(@text)
          when 'snapshotId'       then @volume[:snapshot_id]     = @text.blank? ? nil : @text
          when 'availabilityZone' then @volume[:zone]            = @text
          when 'item'
            case @xmlpath
            when 'DescribeVolumesResponse/volumeSet' then @result << @volume
            end
        end
      end
      def reset
        @result = []
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: EBS - Snapshots
  #-----------------------------------------------------------------

    class QEc2DescribeSnapshotsParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        @snapshot = {} if name == 'item'
      end
      def tagend(name)
        case name
          when 'volumeId'   then @snapshot[:aws_volume_id]  = @text
          when 'snapshotId' then @snapshot[:aws_id]         = @text
          when 'status'     then @snapshot[:aws_status]     = @text
          when 'startTime'  then @snapshot[:aws_started_at] = Time.parse(@text)
          when 'progress'   then @snapshot[:aws_progress]   = @text
          when 'item'       then @result                   << @snapshot
        end
      end
      def reset
        @result = []
      end
    end

    class QEc2CreateSnapshotParser < AwsParser #:nodoc:
      def tagend(name)
        case name
          when 'volumeId'   then @result[:aws_volume_id]  = @text
          when 'snapshotId' then @result[:aws_id]         = @text
          when 'status'     then @result[:aws_status]     = @text
          when 'startTime'  then @result[:aws_started_at] = Time.parse(@text)
          when 'progress'   then @result[:aws_progress]   = @text
        end
      end
      def reset
        @result = {}
      end
    end

  #-----------------------------------------------------------------
  #      PARSERS: Tags
  #-----------------------------------------------------------------

    class QEc2DescribeTagsParser < AwsParser #:nodoc:
      def tagstart(name, attributes)
        @tag = {} if name == 'item'
      end
      def tagend(name)
        case name
          when 'resourceId'   then @tag[:aws_resource_id]   = @text
          when 'resourceType' then @tag[:aws_resource_type] = @text
          when 'key'          then @tag[:aws_key]           = @text
          when 'value'        then @tag[:aws_value]         = @text
          when 'item'         then @result                  << @tag
        end
      end
      def reset
        @result = []
      end
    end

  end

end


