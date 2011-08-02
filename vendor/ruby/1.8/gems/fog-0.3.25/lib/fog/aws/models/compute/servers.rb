require 'fog/core/collection'
require 'fog/aws/models/compute/server'

module Fog
  module AWS
    class Compute

      class Servers < Fog::Collection

        attribute :filters

        model Fog::AWS::Compute::Server

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters = self.filters)
          unless filters.is_a?(Hash)
            Formatador.display_line("[yellow][WARN] all with #{filters.class} param is deprecated, use all('instance-id' => []) instead[/] [light_black](#{caller.first})[/]")
            filters = {'instance-id' => [*filters]}
          end
          self.filters = filters
          data = connection.describe_instances(filters).body
          load(
            data['reservationSet'].map do |reservation|
              reservation['instancesSet'].map do |instance|
                instance.merge(:groups => reservation['groupSet'])
              end
            end.flatten
          )
        end

        def bootstrap(new_attributes = {})
          server = connection.servers.new(new_attributes)

          unless new_attributes[:key_name]
            # first or create fog_#{credential} keypair
            name = Fog.respond_to?(:credential) && Fog.credential || :default
            unless server.key_pair = connection.key_pairs.get("fog_#{name}")
              server.key_pair = connection.key_pairs.create(
                :name => "fog_#{name}",
                :public_key => server.public_key
              )
            end
          end

          # make sure port 22 is open in the first security group
          security_group = connection.security_groups.get(server.groups.first)
          authorized = security_group.ip_permissions.detect do |ip_permission|
            ip_permission['ipRanges'].first && ip_permission['ipRanges'].first['cidrIp'] == '0.0.0.0/0' &&
            ip_permission['fromPort'] == 22 &&
            ip_permission['ipProtocol'] == 'tcp' &&
            ip_permission['toPort'] == 22
          end
          unless authorized
            security_group.authorize_port_range(22..22)
          end

          server.save
          server.wait_for { ready? }
          server.setup(:key_data => [server.private_key])
          server
        end

        def get(server_id)
          if server_id
            self.class.new(:connection => connection).all('instance-id' => server_id).first
          end
        rescue Fog::Errors::NotFound
          nil
        end

      end

    end
  end
end
