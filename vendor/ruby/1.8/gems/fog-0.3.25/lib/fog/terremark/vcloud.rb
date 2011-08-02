module Fog
  module Terremark
   module Vcloud

     module Bin
     end

     module Defaults
       HOST   = 'services.vcloudexpress.terremark.com'
       PATH   = '/api/v0.8'
       PORT   = 443
       SCHEME = 'https'
     end

     extend Fog::Terremark::Shared

     def self.new(options={})

       unless @required
         shared_requires
         @required = true
       end

       check_shared_options(options)

       if Fog.mocking?
          Fog::Terremark::Vcloud::Mock.new(options)
       else
          Fog::Terremark::Vcloud::Real.new(options)
       end
     end

     class Real

       include Fog::Terremark::Shared::Real
       include Fog::Terremark::Shared::Parser

        def initialize(options={})
          @terremark_password = options[:terremark_vcloud_password]
          @terremark_username = options[:terremark_vcloud_username]
          @host   = options[:host]   || Fog::Terremark::Vcloud::Defaults::HOST
          @path   = options[:path]   || Fog::Terremark::Vcloud::Defaults::PATH
          @port   = options[:port]   || Fog::Terremark::Vcloud::Defaults::PORT
          @scheme = options[:scheme] || Fog::Terremark::Vcloud::Defaults::SCHEME
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}", options[:persistent])
        end

        def default_vdc_id
          if default_organization_id
            @default_vdc_id ||= begin
              vdcs = get_organization(default_organization_id).body['Links'].select {|link|
                link['type'] == 'application/vnd.vmware.vcloud.vdc+xml'
              }
              if vdcs.length == 1
                vdcs.first['href'].split('/').last.to_i
              else
                nil
              end
            end
          else
            nil
          end
        end

        def default_network_id
          if default_vdc_id
            @default_network_id ||= begin
              networks = get_vdc(default_vdc_id).body['AvailableNetworks']
              if networks.length == 1
                networks.first['href'].split('/').last.to_i
              else
                nil
              end
            end
          else
            nil
          end
        end

        def default_public_ip_id
          if default_vdc_id
            @default_public_ip_id ||= begin
              ips = get_public_ips(default_vdc_id).body['PublicIpAddresses']
              if ips.length == 1
                ips.first['href'].split('/').last.to_i
              else
                nil
              end
            end
          else
            nil
          end
        end
     end

     class Mock
       include Fog::Terremark::Shared::Mock
       include Fog::Terremark::Shared::Parser

       def initialize(option = {})
         super
         @base_url = Fog::Terremark::Vcloud::Defaults::SCHEME + "://" +
                     Fog::Terremark::Vcloud::Defaults::HOST +
                     Fog::Terremark::Vcloud::Defaults::PATH
         @data = self.class.data[:terremark_vcloud_username]
       end
     end

   end
  end
end


