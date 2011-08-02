require 'fog/core/credentials'

module Fog
  class << self

    def providers
      [
        ::AWS,
        ::Bluebox,
        ::Brightbox,
        ::GoGrid,
        ::Google,
        ::Linode,
        ::Local,
        ::NewServers,
        ::Rackspace,
        ::Slicehost,
        ::Terremark
      ].select {|provider| provider.available?}
    end

    def modules
      [
        ::Vcloud
      ].select {|_module_| _module_.initialized?}
    end

  end

  class Bin
    class << self

      def available?
        availability = true
        for service in services
          begin
            service = eval(self[service].class.to_s.split('::')[0...-1].join('::'))
            availability &&= service.requirements.all? {|requirement| Fog.credentials.include?(requirement)}
          rescue
            availability = false
          end
        end

        if availability
          for service in services
            for collection in self[service].collections
              unless self.respond_to?(collection)
                self.class_eval <<-EOS, __FILE__, __LINE__
                  def self.#{collection}
                    self[:#{service}].#{collection}
                  end
                EOS
              end
            end
          end
        end

        availability
      end

      def collections
        services.map {|service| self[service].collections}.flatten.sort_by {|service| service.to_s}
      end

    end
  end

end

require 'fog/aws/bin'
require 'fog/bluebox/bin'
require 'fog/brightbox/bin'
require 'fog/go_grid/bin'
require 'fog/google/bin'
require 'fog/linode/bin'
require 'fog/local/bin'
require 'fog/new_servers/bin'
require 'fog/rackspace/bin'
require 'fog/slicehost/bin'
require 'fog/terremark/bin'
require 'fog/vcloud/bin'
