require 'fog/core/model'

module Fog
  module Terremark
    module Shared

      class Server < Fog::Model

        identity :id

        attribute :name
        attribute :status
        attribute :OperatingSystem
        attribute :VirtualHardware

        def destroy
          requires :id
          data = connection.power_off(id).body
          task = connection.tasks.new(data)
          task.wait_for { ready? }
          connection.delete_vapp(id)
          true
        end

        # { '0' => 'Being created', '2' => 'Powered Off', '4' => 'Powered On'}
        def ready?
          status == '2'
        end

        def on?
          status == '4'
        end

        def off?
          status == '2'
        end

        def power_on(options = {})
          requires :id
          begin
            connection.power_on(id)
          rescue Excon::Errors::InternalServerError => e
            #Frankly we shouldn't get here ...
            raise e unless e.to_s =~ /because it is already powered on/
          end
          true
        end

        def power_off
          requires :id
          begin
            connection.power_off(id)
          rescue Excon::Errors::InternalServerError => e
            #Frankly we shouldn't get here ...
            raise e unless e.to_s =~ /because it is already powered off/
          end
          true
        end

        def shutdown
          requires :id
          begin
            connection.power_shutdown(id)
          rescue Excon::Errors::InternalServerError => e
            #Frankly we shouldn't get here ...
            raise e unless e.to_s =~ /because it is already powered off/
          end
          true
        end

        def power_reset
          requires :id
          connection.power_reset(id)
          true
        end

        def graceful_restart
          requires :id
          shutdown
          wait_for { off? }
          power_on
        end

        def save
          requires :name
          data = connection.instantiate_vapp(name)
          merge_attributes(data.body)
          task = connection.deploy_vapp(id)
          task.wait_for { ready? }
          task = connection.power_on(id)
          task.wait_for { ready? }
          true
        end

        private

        def href=(new_href)
          self.id = new_href.split('/').last.to_i
        end

        def type=(new_type); @type = new_type; end
        def size=(new_size); @size = new_size; end
        def IpAddress=(new_ipaddress); @IpAddress = new_ipaddress; end
        def Links=(new_links); @Links = new_links; end

      end

    end
  end
end
