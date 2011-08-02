module Fog
  module Google
    class Storage
      class Real

        # Create an Google Storage bucket
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

      class Mock

        def put_bucket(bucket_name, options = {})
          if options['x-goog-acl']
            unless ['private', 'public-read', 'public-read-write', 'authenticated-read']
              raise Excon::Errors::BadRequest.new('invalid x-goog-acl')
            else
              @data[:acls][:bucket][bucket_name] = self.class.acls(options['x-goog-acl'])
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
            bucket['LocationConstraint'] = ''
          end
          if @data[:buckets][bucket_name].nil?
            @data[:buckets][bucket_name] = bucket
          else
            response.status = 409
            raise(Excon::Errors.status_error({:expects => 200}, response))
          end
          response
        end

      end
    end
  end
end
