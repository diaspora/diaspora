module Fog
  module Rackspace
    class Storage
      class Real

        # Get details for object
        #
        # ==== Parameters
        # * container<~String> - Name of container to look in
        # * object<~String> - Name of object to look for
        #
        def get_object(container, object, &block)
          response = request({
            :block    => block,
            :expects  => 200,
            :method   => 'GET',
            :path     => "#{CGI.escape(container)}/#{CGI.escape(object)}"
          }, false, &block)
          response
        end

      end

      class Mock

        def get_object(container, object, &block)
          Fog::Mock.not_implemented
        end

      end
    end
  end
end
