module Fog
  module Brightbox
    class Compute
      class Real

        def get_user(identifier, options = {})
          return nil if identifier.nil? || identifier == ""
          request(
            :expects  => [200],
            :method   => 'GET',
            :path     => "/1.0/users/#{identifier}",
            :headers  => {"Content-Type" => "application/json"},
            :body     => options.to_json
          )
        end

      end

      class Mock

        def get_user(identifier, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end