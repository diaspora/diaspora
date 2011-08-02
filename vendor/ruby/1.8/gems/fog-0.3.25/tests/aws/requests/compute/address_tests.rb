Shindo.tests('AWS::Compute | address requests', ['aws']) do

  @addresses_format = {
    'addressesSet' => [{
      'instanceId'  => NilClass,
      'publicIp'    => String
    }],
    'requestId' => String
  }

  @server = AWS[:compute].servers.create(:image_id => GENTOO_AMI)
  @server.wait_for { ready? }
  @ip_address = @server.ip_address

  tests('success') do

    @public_ip = nil

    tests('#allocate_address').formats({'publicIp' => String, 'requestId' => String}) do
      data = AWS[:compute].allocate_address.body
      @public_ip = data['publicIp']
      data
    end

    tests('#describe_addresses').formats(@addresses_format) do
      AWS[:compute].describe_addresses.body
    end

    tests("#describe_addresses('public-ip' => #{@public_Ip}')").formats(@addresses_format) do
      AWS[:compute].describe_addresses('public-ip' => @public_ip).body
    end

    tests("#associate_addresses('#{@server.identity}', '#{@public_Ip}')").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].associate_address(@server.identity, @public_ip).body
    end

    tests("#dissassociate_address('#{@public_ip}')").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].disassociate_address(@public_ip).body
    end

    tests("#release_address('#{@public_ip}')").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].release_address(@public_ip).body
    end

  end
  tests ('failure') do

    @address = AWS[:compute].addresses.create

    tests("#associate_addresses('i-00000000', '#{@address.identity}')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].associate_address('i-00000000', @address.identity)
    end

    tests("#associate_addresses('#{@server.identity}', '127.0.0.1')").raises(Fog::AWS::Compute::Error) do
      AWS[:compute].associate_address(@server.identity, '127.0.0.1')
    end

    tests("#associate_addresses('i-00000000', '127.0.0.1')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].associate_address('i-00000000', '127.0.0.1')
    end

    tests("#disassociate_addresses('127.0.0.1') raises BadRequest error").raises(Fog::AWS::Compute::Error) do
      AWS[:compute].disassociate_address('127.0.0.1')
    end

    tests("#release_address('127.0.0.1')").raises(Fog::AWS::Compute::Error) do
      AWS[:compute].release_address('127.0.0.1')
    end

    @address.destroy

  end

  @server.destroy

end
