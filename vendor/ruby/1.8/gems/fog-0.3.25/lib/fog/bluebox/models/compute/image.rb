require 'fog/core/model'

module Fog
  module Bluebox
    class Compute

      class Image < Fog::Model

        identity :id

        attribute :description
        attribute :public
        attribute :created_at, :aliases => 'created'

      end

    end
  end
end
