Shindo.tests('AWS::Compute | volume requests', ['aws']) do

  @volume_format = {
    'availabilityZone'  => String,
    'createTime'        => Time,
    'requestId'         => String,
    'size'              => Integer,
    'snapshotId'        => NilClass,
    'status'            => String,
    'volumeId'          => String
  }

  @volume_attachment_format = {
    'attachTime'  => Time,
    'device'      => String,
    'instanceId'  => String,
    'requestId'   => String,
    'status'      => String,
    'volumeId'    => String
  }

  @volumes_format = {
    'volumeSet' => [{
      'availabilityZone'  => String,
      'attachmentSet'     => [],
      'createTime'        => Time,
      'size'              => Integer,
      'snapshotId'        => NilClass,
      'status'            => String,
      'tagSet'            => {},
      'volumeId'          => String
    }],
    'requestId' => String
  }

  @server = AWS[:compute].servers.create(:image_id => GENTOO_AMI)
  @server.wait_for { ready? }

  tests('success') do

    @volume_id = nil

    tests('#create_volume').formats(@volume_format) do
      data = AWS[:compute].create_volume(@server.availability_zone, 1).body
      @volume_id = data['volumeId']
      data
    end

    AWS[:compute].volumes.get(@volume_id).wait_for { ready? }

    tests('#describe_volumes').formats(@volumes_format) do
      AWS[:compute].describe_volumes.body
    end

    tests("#describe_volumes('volume-id' => #{@volume_id})").formats(@volumes_format) do
      AWS[:compute].describe_volumes('volume-id' => @volume_id).body
    end

    tests("#attach_volume(#{@server.identity}, #{@volume_id}, '/dev/sdh')").formats(@volume_attachment_format) do
      AWS[:compute].attach_volume(@server.identity, @volume_id, '/dev/sdh').body
    end

    AWS[:compute].volumes.get(@volume_id).wait_for { state == 'in-use' }

    tests("#detach_volume('#{@volume_id}')").formats(@volume_attachment_format) do
      AWS[:compute].detach_volume(@volume_id).body
    end

    AWS[:compute].volumes.get(@volume_id).wait_for { ready? }

    tests("#delete_volume('#{@volume_id}')").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].delete_volume(@volume_id).body
    end

  end
  tests ('failure') do

    @volume = AWS[:compute].volumes.create(:availability_zone => @server.availability_zone, :size => 1)

    tests("#attach_volume('i-00000000', '#{@volume.identity}', '/dev/sdh')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].attach_volume('i-00000000', @volume.identity, '/dev/sdh')
    end

    tests("#attach_volume('#{@server.identity}', 'vol-00000000', '/dev/sdh')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].attach_volume(@server.identity, 'vol-00000000', '/dev/sdh')
    end

    tests("#detach_volume('vol-00000000')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].detach_volume('vol-00000000')
    end

    tests("#delete_volume('vol-00000000')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].delete_volume('vol-00000000')
    end

    @volume.destroy

  end

  @server.destroy

end
