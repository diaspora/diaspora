module Fog
  module Terremark
    module Shared

      # Commond methods shared by Real and Mock
      module Common

        def default_organization_id
          @default_organization_id ||= begin
            org_list = get_organizations.body['OrgList']
            if org_list.length == 1
              org_list.first['href'].split('/').last.to_i
            else
              nil
            end
          end
        end

      end

      module Parser

        def parse(data)
          case data['type']
          when 'application/vnd.vmware.vcloud.vApp+xml'
            servers.new(data.merge!(:connection => self))
          else
            data
          end
        end

      end

      module Real
        include Common

        private

        def auth_token
          response = @connection.request({
            :expects   => 200,
            :headers   => {
              'Authorization' => "Basic #{Base64.encode64("#{@terremark_username}:#{@terremark_password}").chomp!}",
              'Content-Type'  => "application/vnd.vmware.vcloud.orgList+xml"
            },
            :host      => @host,
            :method    => 'POST',
            :parser    => Fog::Parsers::Terremark::Shared::GetOrganizations.new,
            :path      => "#{@path}/login"
          })
          response.headers['Set-Cookie']
        end

        def reload
          @connection.reset
        end

        def request(params)
          unless @cookie
            @cookie = auth_token
          end
          begin
            do_request(params)
          rescue Excon::Errors::Unauthorized => e
            @cookie = auth_token
            do_request(params)
          end
        end

        def do_request(params)
          headers = {}
          if @cookie
            headers.merge!('Cookie' => @cookie)
          end
          @connection.request({
            :body     => params[:body],
            :expects  => params[:expects],
            :headers  => headers.merge!(params[:headers] || {}),
            :host     => @host,
            :method   => params[:method],
            :parser   => params[:parser],
            :path     => "#{@path}/#{params[:path]}"
          })
        end

      end

      module Mock
        include Common

        def self.mock_data
        {
          :organizations =>
          [
            {
              :info => {
                :name => "Boom Inc.",
                :id => 1
              },
              :vdcs => [
                { :id => 21,
                  :name => "Boomstick",
                  :storage => { :used => 105, :allocated => 200 },
                  :cpu => { :allocated => 10000 },
                  :memory => { :allocated => 20480 },
                  :networks => [
                    { :id => 31,
                      :name => "1.2.3.0/24",
                      :subnet => "1.2.3.0/24",
                      :gateway => "1.2.3.1",
                      :netmask => "255.255.255.0",
                      :fencemode => "isolated"
                    },
                    { :id => 32,
                      :name => "4.5.6.0/24",
                      :subnet => "4.5.6.0/24",
                      :gateway => "4.5.6.1",
                      :netmask => "255.255.255.0",
                      :fencemode => "isolated"
                    },
                  ],
                  :vms => [
                    { :id => 41,
                      :name => "Broom 1"
                    },
                    { :id => 42,
                      :name => "Broom 2"
                    },
                    { :id => 43,
                      :name => "Email!"
                    }
                  ],
                  :public_ips => [
                    { :id => 51,
                      :name => "99.1.2.3"
                    },
                    { :id => 52,
                      :name => "99.1.2.4"
                    },
                    { :id => 53,
                      :name => "99.1.9.7"
                    }
                  ]
                },
                { :id => 22,
                  :storage => { :used => 40, :allocated => 150 },
                  :cpu => { :allocated => 1000 },
                  :memory => { :allocated => 2048 },
                  :name => "Rock-n-Roll",
                  :networks => [
                    { :id => 33,
                      :name => "7.8.9.0/24",
                      :subnet => "7.8.9.0/24",
                      :gateway => "7.8.9.1",
                      :netmask => "255.255.255.0",
                      :fencemode => "isolated"
                    }
                  ],
                  :vms => [
                    { :id => 44,
                      :name => "Master Blaster"
                    }
                  ],
                  :public_ips => [
                    { :id => 54,
                      :name => "99.99.99.99"
                    }
                  ]
                }
              ]
            }
          ]
        }
        end

        def self.error_headers
          {"X-Powered-By"=>"ASP.NET",
           "Date"=> Time.now.to_s,
           "Content-Type"=>"text/html",
           "Content-Length"=>"0",
           "Server"=>"Microsoft-IIS/7.0",
           "Cache-Control"=>"private"}
        end

        def self.unathorized_status
          401
        end

        def self.headers(body, content_type)
          {"X-Powered-By"=>"ASP.NET",
           "Date"=> Time.now.to_s,
           "Content-Type"=> content_type,
           "Content-Length"=> body.to_s.length,
           "Server"=>"Microsoft-IIS/7.0",
           "Set-Cookie"=>"vcloud-token=ecb37bfc-56f0-421d-97e5-bf2gdf789457; path=/",
           "Cache-Control"=>"private"}
        end

        def self.status
          200
        end

        def initialize(options={})
          self.class.instance_eval '
            def self.data
              @data ||= Hash.new do |hash, key|
                hash[key] = Fog::Terremark::Shared::Mock.mock_data
              end
            end'
          self.class.instance_eval '
            def self.reset_data(keys=data.keys)
              for key in [*keys]
                data.delete(key)
              end
            end'
        end
      end

      def check_shared_options(options)
        %w{ecloud vcloud}.each do |cloud|
          cloud_option_keys = options.keys.select { |key| key.to_s =~ /^terremark_#{cloud}_.*/ }
          unless cloud_option_keys.length == 0 || cloud_option_keys.length == 2
            raise ArgumentError.new("terremark_#{cloud}_username and terremark_#{cloud}_password required to access teremark")
          end
        end
      end

      def shared_requires
        require 'fog/terremark/models/shared/address'
        require 'fog/terremark/models/shared/addresses'
        require 'fog/terremark/models/shared/network'
        require 'fog/terremark/models/shared/networks'
        require 'fog/terremark/models/shared/server'
        require 'fog/terremark/models/shared/servers'
        require 'fog/terremark/models/shared/task'
        require 'fog/terremark/models/shared/tasks'
        require 'fog/terremark/models/shared/vdc'
        require 'fog/terremark/models/shared/vdcs'
        require 'fog/terremark/parsers/shared/get_catalog'
        require 'fog/terremark/parsers/shared/get_catalog_item'
        require 'fog/terremark/parsers/shared/get_internet_services'
        require 'fog/terremark/parsers/shared/get_network_ips'
        require 'fog/terremark/parsers/shared/get_node_services'
        require 'fog/terremark/parsers/shared/get_organization'
        require 'fog/terremark/parsers/shared/get_organizations'
        require 'fog/terremark/parsers/shared/get_public_ips'
        require 'fog/terremark/parsers/shared/get_tasks_list'
        require 'fog/terremark/parsers/shared/get_vapp_template'
        require 'fog/terremark/parsers/shared/get_vdc'
        require 'fog/terremark/parsers/shared/instantiate_vapp_template'
        require 'fog/terremark/parsers/shared/internet_service'
        require 'fog/terremark/parsers/shared/network'
        require 'fog/terremark/parsers/shared/node_service'
        require 'fog/terremark/parsers/shared/public_ip'
        require 'fog/terremark/parsers/shared/task'
        require 'fog/terremark/parsers/shared/vapp'
        require 'fog/terremark/requests/shared/add_internet_service'
        require 'fog/terremark/requests/shared/add_node_service'
        require 'fog/terremark/requests/shared/create_internet_service'
        require 'fog/terremark/requests/shared/delete_internet_service'
        require 'fog/terremark/requests/shared/delete_public_ip'
        require 'fog/terremark/requests/shared/delete_node_service'
        require 'fog/terremark/requests/shared/delete_vapp'
        require 'fog/terremark/requests/shared/deploy_vapp'
        require 'fog/terremark/requests/shared/get_catalog'
        require 'fog/terremark/requests/shared/get_catalog_item'
        require 'fog/terremark/requests/shared/get_internet_services'
        require 'fog/terremark/requests/shared/get_network'
        require 'fog/terremark/requests/shared/get_network_ips'
        require 'fog/terremark/requests/shared/get_node_services'
        require 'fog/terremark/requests/shared/get_organization'
        require 'fog/terremark/requests/shared/get_organizations'
        require 'fog/terremark/requests/shared/get_public_ip'
        require 'fog/terremark/requests/shared/get_public_ips'
        require 'fog/terremark/requests/shared/get_task'
        require 'fog/terremark/requests/shared/get_tasks_list'
        require 'fog/terremark/requests/shared/get_vapp'
        require 'fog/terremark/requests/shared/get_vapp_template'
        require 'fog/terremark/requests/shared/get_vdc'
        require 'fog/terremark/requests/shared/instantiate_vapp_template'
        require 'fog/terremark/requests/shared/power_off'
        require 'fog/terremark/requests/shared/power_on'
        require 'fog/terremark/requests/shared/power_reset'
        require 'fog/terremark/requests/shared/power_shutdown'
      end

    end
  end
end
