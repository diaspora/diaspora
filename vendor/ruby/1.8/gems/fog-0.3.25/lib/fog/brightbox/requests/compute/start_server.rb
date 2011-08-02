module Fog
  module Brightbox
    class Compute
      class Real

        def start_server(identifier, options = {})
          return nil if identifier.nil? || identifier == ""
          request(
            :expects  => [202],
            :method   => 'POST',
            :path     => "/1.0/servers/#{identifier}/start",
            :headers  => {"Content-Type" => "application/json"},
            :body     => options.to_json
          )
        end

      end

      class Mock

        def start_server(identifier, options = {})
          Fog::Mock.not_implemented
        end

      end
    end
  end
end