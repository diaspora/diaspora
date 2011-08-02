Shindo.tests('AWS::Compute | tag requests', ['aws']) do

  @tags_format = {
    'tagSet'    => [{
      'key'          => String,
      'resourceId'   => String,
      'resourceType' => String,
      'value'        => String
    }],
    'requestId' => String
  }

  @volume = AWS[:compute].volumes.create(:availability_zone => 'us-east-1a', :size => 1)
  @volume.wait_for { ready? }

  tests('success') do

    tests("#create_tags('#{@volume.identity}', 'foo' => 'bar')").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].create_tags(@volume.identity, 'foo' => 'bar').body
    end

    tests('#describe_tags').formats(@tags_format) do
      pending if Fog.mocking?
      AWS[:compute].describe_tags.body
    end

    tests("#delete_tags('#{@volume.identity}', 'foo' => 'bar')").formats(AWS::Compute::Formats::BASIC) do
      pending if Fog.mocking?
      AWS[:compute].delete_tags(@volume.identity, 'foo' => 'bar').body
    end

  end

  tests('failure') do

    tests("#create_tags('vol-00000000', 'baz' => 'qux')").raises(Fog::Service::NotFound) do
      AWS[:compute].create_tags('vol-00000000', 'baz' => 'qux')
    end

    tests("#delete_tags('vol-00000000', 'baz' => 'qux')").raises(Fog::Service::NotFound) do
      pending if Fog.mocking?
      AWS[:compute].delete_tags('vol-00000000', 'baz' => 'qux')
    end

  end

  @volume.destroy

end
