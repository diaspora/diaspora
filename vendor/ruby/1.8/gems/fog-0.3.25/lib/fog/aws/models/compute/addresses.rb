require 'fog/core/collection'
require 'fog/aws/models/compute/address'

module Fog
  module AWS
    class Compute

      class Addresses < Fog::Collection

        attribute :filters
        attribute :server

        model Fog::AWS::Compute::Address

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters = filters)
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] all with #{filters.class} param is deprecated, use all('public-ip' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'public-ip' => [*filters]}
          end
          self.filters = filters
          data = connection.describe_addresses(filters).body
          load(
            data['addressesSet'].map do |address|
              address.reject {|key, value| value.nil? || value.empty? }
            end
          )
          if server
            self.replace(self.select {|address| address.server_id == server.id})
          end
          self
        end

        def get(public_ip)
          if public_ip
            self.class.new(:connection => connection).all('public-ip' => public_ip).first
          end
        end

        def new(attributes = {})
          if server
            super({ :server => server }.merge!(attributes))
          else
            super(attributes)
          end
        end

      end

    end
  end
end
