Shindo.tests('AWS::Storage | bucket requests', ['aws']) do

  tests('success') do

    @bucket_format = {
      'IsTruncated' => Fog::Boolean,
      'Marker'      => NilClass,
      'MaxKeys'     => Integer,
      'Name'        => String,
      'Prefix'      => NilClass,
      'Contents'    => [{
        'ETag'          => String,
        'Key'           => String,
        'LastModified'  => Time,
        'Owner' => {
          'DisplayName' => String,
          'ID'          => String
        },
        'Size' => Integer,
        'StorageClass' => String
      }]
    }

    @service_format = {
      'Buckets' => [{
        'CreationDate'  => Time,
        'Name'          => String,
      }],
      'Owner'   => {
        'DisplayName' => String,
        'ID'          => String
      }
    }

    tests("#put_bucket('fogbuckettests')").succeeds do
      AWS[:storage].put_bucket('fogbuckettests')
    end

    tests("#get_service").formats(@service_format) do
      AWS[:storage].get_service.body
    end

    file = AWS[:storage].directories.get('fogbuckettests').files.create(:body => 'y', :key => 'x')

    tests("#get_bucket('fogbuckettests)").formats(@bucket_format) do
      AWS[:storage].get_bucket('fogbuckettests').body
    end

    file.destroy

    tests("#get_bucket_location('fogbuckettests)").formats('LocationConstraint' => NilClass) do
      AWS[:storage].get_bucket_location('fogbuckettests').body
    end

    tests("#get_request_payment('fogbuckettests')").formats('Payer' => String) do
      AWS[:storage].get_request_payment('fogbuckettests').body
    end

    tests("#put_request_payment('fogbuckettests', 'Requester')").succeeds do
      AWS[:storage].put_request_payment('fogbuckettests', 'Requester')
    end

    tests("#delete_bucket('fogbuckettests')").succeeds do
      AWS[:storage].delete_bucket('fogbuckettests')
    end

  end

  tests('failure') do

    tests("#delete_bucket('fognonbucket')").raises(Excon::Errors::NotFound) do
      AWS[:storage].delete_bucket('fognonbucket')
    end

    @bucket = AWS[:storage].directories.create(:key => 'fognonempty')
    @file = @bucket.files.create(:key => 'foo', :body => 'bar')

    tests("#delete_bucket('fognonempty')").raises(Excon::Errors::Conflict) do
      AWS[:storage].delete_bucket('fognonempty')
    end

    @file.destroy
    @bucket.destroy

    tests("#get_bucket('fognonbucket')").raises(Excon::Errors::NotFound) do
      AWS[:storage].get_bucket('fognonbucket')
    end

    tests("#get_bucket_location('fognonbucket')").raises(Excon::Errors::NotFound) do
      AWS[:storage].get_bucket_location('fognonbucket')
    end

    tests("#get_request_payment('fognonbucket')").raises(Excon::Errors::NotFound) do
      AWS[:storage].get_request_payment('fognonbucket')
    end

    tests("#put_request_payment('fognonbucket', 'Requester')").raises(Excon::Errors::NotFound) do
      AWS[:storage].put_request_payment('fognonbucket', 'Requester')
    end

  end

end
