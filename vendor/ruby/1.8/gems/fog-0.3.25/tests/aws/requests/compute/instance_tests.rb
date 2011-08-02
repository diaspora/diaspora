Shindo.tests('AWS::Compute | instance requests', ['aws']) do

  @instance_format = {
    # 'architecture'    => String,
    'amiLaunchIndex'      => Integer,
    'blockDeviceMapping'  => [],
    'clientToken'         => NilClass,
    'dnsName'             => NilClass,
    'imageId'             => String,
    'instanceId'          => String,
    'instanceState'       => {'code' => Integer, 'name' => String},
    'instanceType'        => String,
    # 'ipAddress'           => String,
    'kernelId'            => String,
    # 'keyName'             => String,
    'launchTime'          => Time,
    'monitoring'          => {'state' => Fog::Boolean},
    'placement'           => {'availabilityZone' => String},
    'privateDnsName'      => NilClass,
    # 'privateIpAddress'    => String,
    'productCodes'        => [],
    'ramdiskId'           => String,
    'reason'              => NilClass,
    # 'rootDeviceName'      => String,
    'rootDeviceType'      => String,
  }

  @run_instances_format = {
    'groupSet'        => [String],
    'instancesSet'    => [@instance_format],
    'ownerId'         => String,
    'requestId'       => String,
    'reservationId'   => String
  }

  @describe_instances_format = {
    'reservationSet'  => [{
      'groupSet'      => [String],
      'instancesSet'  => [@instance_format.merge(
        'architecture'      => String,
        'dnsName'           => String,
        'ipAddress'         => String,
        'privateDnsName'    => String,
        'privateIpAddress'  => String,
        'stateReason'       => {},
        'tagSet'            => {}
      )],
      'ownerId'       => String,
      'reservationId' => String
    }],
    'requestId'       => String
  }

  @get_console_output_format = {
    'instanceId'  => String,
    'output'      => NilClass,
    'requestId'   => String,
    'timestamp'   => Time
  }

  @terminate_instances_format = {
    'instancesSet'  => [{
      'currentState' => {'code' => Integer, 'name' => String},
      'instanceId'    => String,
      'previousState' => {'code' => Integer, 'name' => String},
    }],
    'requestId'     => String
  }

  tests('success') do

    @instance_id = nil

    tests("#run_instances('#{GENTOO_AMI}', 1, 1)").formats(@run_instances_format) do
      data = AWS[:compute].run_instances(GENTOO_AMI, 1, 1).body
      @instance_id = data['instancesSet'].first['instanceId']
      data
    end

    AWS[:compute].servers.get(@instance_id).wait_for { ready? }

    # The format changes depending on state of instance, so this would be brittle
    # tests("#describe_instances").formats(@describe_instances_format) do
    #   AWS[:compute].describe_instances.body
    # end

    tests("#describe_instances('instance-id' => '#{@instance_id}')").formats(@describe_instances_format) do
      AWS[:compute].describe_instances('instance-id' => @instance_id).body
    end

    tests("#get_console_output('#{@instance_id}')").formats(@get_console_output_format) do
      AWS[:compute].get_console_output(@instance_id).body
    end

    tests("#reboot_instances('#{@instance_id}')").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].reboot_instances(@instance_id).body
    end

    tests("#terminate_instances('#{@instance_id}')").formats(@terminate_instances_format) do
      AWS[:compute].terminate_instances(@instance_id).body
    end

  end

  tests('failure') do

    tests("#get_console_output('i-00000000')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].get_console_output('i-00000000')
    end

    tests("#reboot_instances('i-00000000')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].reboot_instances('i-00000000')
    end

    tests("#terminate_instances('i-00000000')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].terminate_instances('i-00000000')
    end

  end

end
