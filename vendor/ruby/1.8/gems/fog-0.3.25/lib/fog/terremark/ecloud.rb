module Fog
  module Terremark
    module Ecloud

      module Bin
      end

      module Defaults
        HOST   = 'services.enterprisecloud.terremark.com'
        PATH   = '/api/v0.8a-ext2.0'
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
          Fog::Terremark::Ecloud::Mock.new(options)
        else
          Fog::Terremark::Ecloud::Real.new(options)
        end

      end

      class Real

        include Fog::Terremark::Shared::Real
        include Fog::Terremark::Shared::Parser

        def initialize(options={})
          @terremark_password = options[:terremark_ecloud_password]
          @terremark_username = options[:terremark_ecloud_username]
          @host   = options[:host]   || Fog::Terremark::Ecloud::Defaults::HOST
          @path   = options[:path]   || Fog::Terremark::Ecloud::Defaults::PATH
          @port   = options[:port]   || Fog::Terremark::Ecloud::Defaults::PORT
          @scheme = options[:scheme] || Fog::Terremark::Ecloud::Defaults::SCHEME
          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}", options[:persistent])
        end

      end

      class Mock
        include Fog::Terremark::Shared::Mock
        include Fog::Terremark::Shared::Parser

        def initialize(option = {})
          super
          @base_url = Fog::Terremark::Ecloud::Defaults::SCHEME + "://" +
          Fog::Terremark::Ecloud::Defaults::HOST +
          Fog::Terremark::Ecloud::Defaults::PATH
          @data = self.class.data[:terremark_ecloud_username]
        end
      end

    end
  end
end

