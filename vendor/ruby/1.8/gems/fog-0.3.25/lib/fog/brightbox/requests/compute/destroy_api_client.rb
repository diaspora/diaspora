module Fog
  module Brightbox
    class Compute
      class Real

        def destroy_api_client(identifier, options = {})
          return nil if identifier.nil? || identifier == ""
          request(
            :expects  => [200],
            :method   => 'DELETE',
            :path     => "/1.0/api_clients/#{identifier}",
            :headers  => {"Content-Type" => "application/json"},
            :body     => options.to_json
          )
        end

      end

      class Mock

        def destroy_api_client(identifier, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end