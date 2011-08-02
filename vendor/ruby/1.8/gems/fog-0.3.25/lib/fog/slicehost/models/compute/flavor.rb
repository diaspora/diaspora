require 'fog/core/model'

module Fog
  module Slicehost
    class Compute

      class Flavor < Fog::Model

        identity :id

        attribute :name
        attribute :price
        attribute :ram

        def bits
          # 64
          raise StandardError.new("Figure me out!?!")
        end

        def cores
          # # 2 quad-cores >= 2Ghz = 8 cores
          # 8 * case ram
          # when 256
          #   1/64.0
          # when 512
          #   1/32.0
          # when 1024
          #   1/16.0
          # when 2048
          #   1/8.0
          # when 4096
          #   1/4.0
          # when 8192
          #   1/2.0
          # when 15872
          #   1
          # end
          raise StandardError.new("Figure me out!?!")
        end

      end

    end
  end
end
