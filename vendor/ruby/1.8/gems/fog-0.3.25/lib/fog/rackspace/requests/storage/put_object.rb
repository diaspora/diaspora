module Fog
  module Rackspace
    class Storage
      class Real

        # Create a new object
        #
        # ==== Parameters
        # * container<~String> - Name for container, should be < 256 bytes and must not contain '/'
        #
        def put_object(container, object, data, options = {})
          data = parse_data(data)
          headers = data[:headers].merge!(options)
          response = request(
            :body     => data[:body],
            :expects  => 201,
            :headers  => headers,
            :method   => 'PUT',
            :path     => "#{CGI.escape(container)}/#{CGI.escape(object)}"
          )
          response
        end

      end

      class Mock

        def put_object(container, object, data, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
