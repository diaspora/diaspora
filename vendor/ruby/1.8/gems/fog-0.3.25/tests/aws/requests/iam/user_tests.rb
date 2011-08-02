Shindo.tests('AWS::IAM | user requests', ['aws']) do

  unless Fog.mocking?
    AWS[:iam].create_group('fog_user_tests')
  end

  tests('success') do

    @user_format = {
      'User' => {
        'Arn'       => String,
        'Path'      => String,
        'UserId'    => String,
        'UserName'  => String
      },
      'RequestId' => String
    }

    tests("#create_user('fog_user')").formats(@user_format) do
      pending if Fog.mocking?
      AWS[:iam].create_user('fog_user').body
    end

    @users_format = {
      'Users' => [{
        'Arn'       => String,
        'Path'      => String,
        'UserId'    => String,
        'UserName'  => String
      }],
      'IsTruncated' => Fog::Boolean,
      'RequestId'   => String
    }

    tests("#list_users").formats(@users_format) do
      pending if Fog.mocking?
      AWS[:iam].list_users.body
    end

    tests("#add_user_to_group('fog_user_tests', 'fog_user')").formats(AWS::IAM::Formats::BASIC) do
      pending if Fog.mocking?
      AWS[:iam].add_user_to_group('fog_user_tests', 'fog_user').body
    end

    tests("#remove_user_from_group('fog_user_tests', 'fog_user')").formats(AWS::IAM::Formats::BASIC) do
      pending if Fog.mocking?
      AWS[:iam].remove_user_from_group('fog_user_tests', 'fog_user').body
    end

    tests("#delete_user('fog_user')").formats(AWS::IAM::Formats::BASIC) do
      pending if Fog.mocking?
      AWS[:iam].delete_user('fog_user').body
    end

  end

  tests('failure') do
    test('failing conditions')
  end

  unless Fog.mocking?
    AWS[:iam].delete_group('fog_user_tests')
  end

end