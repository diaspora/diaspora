module Fog
  module AWS
    class Storage
      class Real

        # Create an S3 bucket
        #
        # ==== Parameters
        # * bucket_name<~String> - name of bucket to create
        # * options<~Hash> - config arguments for bucket.  Defaults to {}.
        #   * 'LocationConstraint'<~Symbol> - sets the location for the bucket
        #   * 'x-amz-acl'<~String> - Permissions, must be in ['private', 'public-read', 'public-read-write', 'authenticated-read']
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * status<~Integer> - 200
        #
        # ==== See Also
        # http://docs.amazonwebservices.com/AmazonS3/latest/API/RESTBucketPUT.html

        def put_bucket(bucket_name, options = {})
          if location_constraint = options.delete('LocationConstraint')
            data =
<<-DATA
  <CreateBucketConfiguration>
    <LocationConstraint>#{location_constraint}</LocationConstraint>
  </CreateBucketConfiguration>
DATA
          else
            data = nil
          end
          request({
            :expects    => 200,
            :body       => data,
            :headers    => options,
            :idempotent => true,
            :host       => "#{bucket_name}.#{@host}",
            :method     => 'PUT'
          })
        end

      end

      class Mock # :nodoc:all

        def put_bucket(bucket_name, options = {})
          if options['x-amz-acl']
            unless ['private', 'public-read', 'public-read-write', 'authenticated-read']
              raise Excon::Errors::BadRequest.new('invalid x-amz-acl')
            else
              @data[:acls][:bucket][bucket_name] = self.class.acls(options['x-amz-acl'])
            end
          end
          response = Excon::Response.new
          response.status = 200
          bucket = {
            :objects        => {},
            'Name'          => bucket_name,
            'CreationDate'  => Time.now,
            'Owner'         => { 'DisplayName' => 'owner', 'ID' => 'some_id'},
            'Payer'         => 'BucketOwner'
          }
          if options['LocationConstraint']
            bucket['LocationConstraint'] = options['LocationConstraint']
          else
            bucket['LocationConstraint'] = nil
          end
          unless @data[:buckets][bucket_name]
            @data[:buckets][bucket_name] = bucket
          end
          response
        end

      end
    end
  end
end
