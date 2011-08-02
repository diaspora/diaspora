module Fog
  module Google
    class Storage
      class Real

        # Get an expiring object url from Google Storage for putting an object
        #
        # ==== Parameters
        # * bucket_name<~String> - Name of bucket containing object
        # * object_name<~String> - Name of object to get expiring url for
        # * expires<~Time> - An expiry time for this url
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~String> - url for object
        #
        def put_object_url(bucket_name, object_name, expires)
          unless bucket_name
            raise ArgumentError.new('bucket_name is required')
          end
          unless object_name
            raise ArgumentError.new('object_name is required')
          end
          url({
            :headers  => {},
            :host     => "#{bucket_name}.#{@host}",
            :method   => 'PUT',
            :path     => CGI.escape(object_name)
          }, expires)
        end

      end

      class Mock

        def put_object_url(bucket_name, object_name, expires)
          unless bucket_name
            raise ArgumentError.new('bucket_name is required')
          end
          unless object_name
            raise ArgumentError.new('object_name is required')
          end
          url({
            :headers  => {},
            :host     => "#{bucket_name}.#{@host}",
            :method   => 'PUT',
            :path     => CGI.escape(object_name)
          }, expires)
        end

      end
    end
  end
end
