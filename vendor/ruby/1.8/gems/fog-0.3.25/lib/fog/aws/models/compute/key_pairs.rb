require 'fog/core/collection'
require 'fog/aws/models/compute/key_pair'

module Fog
  module AWS
    class Compute

      class KeyPairs < Fog::Collection

        attribute :filters
        attribute :key_name

        model Fog::AWS::Compute::KeyPair

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters = filters)
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] all with #{filters.class} param is deprecated, use all('key-name' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'key-name' => [*filters]}
          end
          self.filters = filters
          data = connection.describe_key_pairs(filters).body
          load(data['keySet'])
        end

        def get(key_name)
          if key_name
            self.class.new(:connection => connection).all('key-name' => key_name).first
          end
        end

      end

    end
  end
end
