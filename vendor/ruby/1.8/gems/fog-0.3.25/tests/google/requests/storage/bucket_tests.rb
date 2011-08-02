Shindo.tests('Google::Storage | bucket requests', ['google']) do

  tests('success') do

    @bucket_format = {
      'IsTruncated' => Fog::Boolean,
      'Marker'      => NilClass,
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
      Google[:storage].put_bucket('fogbuckettests')
    end

    tests("#get_service").formats(@service_format) do
      Google[:storage].get_service.body
    end

    file = Google[:storage].directories.get('fogbuckettests').files.create(:body => 'y', :key => 'x')

    tests("#get_bucket('fogbuckettests)").formats(@bucket_format) do
      Google[:storage].get_bucket('fogbuckettests').body
    end

    file.destroy

    tests("#delete_bucket('fogbuckettests')").succeeds do
      Google[:storage].delete_bucket('fogbuckettests')
    end

  end

  tests('failure') do

    tests("#delete_bucket('fognonbucket')").raises(Excon::Errors::NotFound) do
      Google[:storage].delete_bucket('fognonbucket')
    end

    @bucket = Google[:storage].directories.create(:key => 'fognonempty')
    @file = @bucket.files.create(:key => 'foo', :body => 'bar')

    tests("#delete_bucket('fognonempty')").raises(Excon::Errors::Conflict) do
      Google[:storage].delete_bucket('fognonempty')
    end

    @file.destroy
    @bucket.destroy

    tests("#get_bucket('fognonbucket')").raises(Excon::Errors::NotFound) do
      Google[:storage].get_bucket('fognonbucket')
    end

  end

end
