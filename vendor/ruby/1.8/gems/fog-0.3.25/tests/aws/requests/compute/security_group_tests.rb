Shindo.tests('AWS::Compute | security group requests', ['aws']) do

  @security_groups_format = {
    'requestId'           => String,
    'securityGroupInfo' => [{
      'groupDescription'  => String,
      'groupName'         => String,
      'ipPermissions'     => [{
        'fromPort'    => Integer,
        'groups'      => [{ 'groupName' => String, 'userId' => String }],
        'ipProtocol'  => String,
        'ipRanges'    => [],
        'toPort'      => Integer,
      }],
      'ownerId'           => String
    }]
  }

  @owner_id = AWS[:compute].describe_security_groups('group-name' => 'default').body['securityGroupInfo'].first['ownerId']

  tests('success') do

    tests("#create_security_group('fog_security_group', 'tests group')").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].create_security_group('fog_security_group', 'tests group').body
    end

    tests("#authorize_security_group_ingress({'FromPort' => 80, 'GroupName' => 'fog_security_group', 'IpProtocol' => 'tcp', 'toPort' => 80})").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].authorize_security_group_ingress({
        'FromPort' => 80,
        'GroupName' => 'fog_security_group',
        'IpProtocol' => 'tcp',
        'ToPort' => 80,
      }).body
    end

    tests("#authorize_security_group_ingress({'GroupName' => 'fog_security_group', 'SourceSecurityGroupName' => 'fog_security_group', 'SourceSecurityGroupOwnerId' => '#{@owner_id}'})").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].authorize_security_group_ingress({
        'GroupName'                   => 'fog_security_group',
        'SourceSecurityGroupName'     => 'fog_security_group',
        'SourceSecurityGroupOwnerId'  => @owner_id
      }).body
    end

    tests("#describe_security_groups").formats(@security_groups_format) do
      AWS[:compute].describe_security_groups.body
    end

    tests("#describe_security_groups('group-name' => 'fog_security_group')").formats(@security_groups_format) do
      AWS[:compute].describe_security_groups('group-name' => 'fog_security_group').body
    end

    tests("#revoke_security_group_ingress({'FromPort' => 80, 'GroupName' => 'fog_security_group', 'IpProtocol' => 'tcp', 'toPort' => 80})").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].revoke_security_group_ingress({
        'FromPort' => 80,
        'GroupName' => 'fog_security_group',
        'IpProtocol' => 'tcp',
        'ToPort' => 80,
      }).body
    end

    tests("#revoke_security_group_ingress({'GroupName' => 'fog_security_group', 'SourceSecurityGroupName' => 'fog_security_group', 'SourceSecurityGroupOwnerId' => '#{@owner_id}'})").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].revoke_security_group_ingress({
        'GroupName'                   => 'fog_security_group',
        'SourceSecurityGroupName'     => 'fog_security_group',
        'SourceSecurityGroupOwnerId'  => @owner_id
      }).body
    end

    tests("#delete_security_group('fog_security_group')").formats(AWS::Compute::Formats::BASIC) do
      AWS[:compute].delete_security_group('fog_security_group').body
    end

  end
  tests('failure') do

    @security_group = AWS[:compute].security_groups.create(:description => 'tests group', :name => 'fog_security_group')

    tests("duplicate #create_security_group(#{@security_group.name}, #{@security_group.description})").raises(Fog::AWS::Compute::Error) do
      AWS[:compute].create_security_group(@security_group.name, @security_group.description)
    end

    tests("#authorize_security_group_ingress({'FromPort' => 80, 'GroupName' => 'not_a_group_name', 'IpProtocol' => 'tcp', 'toPort' => 80})").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].authorize_security_group_ingress({
        'FromPort' => 80,
        'GroupName' => 'not_a_group_name',
        'IpProtocol' => 'tcp',
        'ToPort' => 80,
      })
    end

    tests("#authorize_security_group_ingress({'GroupName' => 'not_a_group_name', 'SourceSecurityGroupName' => 'not_a_group_name', 'SourceSecurityGroupOwnerId' => '#{@owner_id}'})").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].authorize_security_group_ingress({
        'GroupName'                   => 'not_a_group_name',
        'SourceSecurityGroupName'     => 'not_a_group_name',
        'SourceSecurityGroupOwnerId'  => @owner_id
      })
    end

    tests("#revoke_security_group_ingress({'FromPort' => 80, 'GroupName' => 'not_a_group_name', 'IpProtocol' => 'tcp', 'toPort' => 80})").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].revoke_security_group_ingress({
        'FromPort' => 80,
        'GroupName' => 'not_a_group_name',
        'IpProtocol' => 'tcp',
        'ToPort' => 80,
      })
    end

    tests("#revoke_security_group_ingress({'GroupName' => 'not_a_group_name', 'SourceSecurityGroupName' => 'not_a_group_name', 'SourceSecurityGroupOwnerId' => '#{@owner_id}'})").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].revoke_security_group_ingress({
        'GroupName'                   => 'not_a_group_name',
        'SourceSecurityGroupName'     => 'not_a_group_name',
        'SourceSecurityGroupOwnerId'  => @owner_id
      })
    end

    tests("#delete_security_group('not_a_group_name')").raises(Fog::AWS::Compute::NotFound) do
      AWS[:compute].delete_security_group('not_a_group_name')
    end

    @security_group.destroy

  end

end
