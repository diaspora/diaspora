require 'fog/core/collection'
require 'fog/aws/models/compute/tag'

module Fog
  module AWS
    class Compute

      class Tags < Fog::Collection

        attribute :filters

        model Fog::AWS::Compute::Tag

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters = filters)
          self.filters = filters
          data = connection.describe_tags(filters).body
          load(data['tagSet'])
        end

        def get(key)
          if key
            self.class.new(:connection => connection).all('key' => key)
          end
        end
      end

    end
  end
end
