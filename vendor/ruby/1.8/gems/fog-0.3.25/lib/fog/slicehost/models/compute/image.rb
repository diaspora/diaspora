require 'fog/core/model'

module Fog
  module Slicehost
    class Compute

      class Image < Fog::Model

        identity :id

        attribute :name

      end

    end
  end
end
