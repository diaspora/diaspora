require 'nokogiri'
require 'fog/core/parser'

module Fog
  module Google

    extend Fog::Provider

    service_path 'fog/google'
    service 'storage'

    class Mock

      def self.etag
        hex(32)
      end

      def self.hex(length)
        max = ('f' * length).to_i(16)
        rand(max).to_s(16)
      end

    end
  end
end
