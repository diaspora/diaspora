require 'nokogiri'
require 'fog/core/parser'

require 'builder'
require 'fog/vcloud/model'
require 'fog/vcloud/collection'
require 'fog/vcloud/generators'
require 'fog/vcloud/mock_data_classes'
# ecloud/vcloud requires at the bottom so that the following will be defined

module URI
  class Generic
    def host_url
      @host_url ||= "#{self.scheme}://#{self.host}#{self.port ? ":#{self.port}" : ''}"
    end
  end
end

module Fog
  class Vcloud < Fog::Service

    requires :username, :password, :versions_uri

    model_path 'fog/vcloud/models'
    model :vdc
    collection :vdcs

    request_path 'fog/vcloud/requests'
    request :login
    request :get_versions
    request :get_vdc
    request :get_organization
    request :get_network

    class UnsupportedVersion < Exception ; end

    module Shared
      attr_reader :versions_uri

      def default_organization_uri
        @default_organization_uri ||= begin
          unless @login_results
            do_login
          end
          case @login_results.body[:Org]
          when Array
            @login_results.body[:Org].first[:href]
          when Hash
            @login_results.body[:Org][:href]
          else
            nil
          end
        end
      end

      # login handles the auth, but we just need the Set-Cookie
      # header from that call.
      def do_login
        @login_results = login
        @cookie = @login_results.headers['Set-Cookie']
      end

      def supported_versions
        @supported_versions ||= get_versions(@versions_uri).body[:VersionInfo]
      end

      def xmlns
        { "xmlns" => "http://www.vmware.com/vcloud/v0.8",
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" }
      end

      # private

      def ensure_unparsed(uri)
        if uri.is_a?(String)
          uri
        else
          uri.to_s
        end
      end

    end

    class Real
      include Shared
      extend Fog::Vcloud::Generators

      def supporting_versions
        ["0.8"]
      end

      def initialize(options = {})
        @connections = {}
        @versions_uri = URI.parse(options[:versions_uri])
        @module = options[:module]
        @version = options[:version]
        @username = options[:username]
        @password = options[:password]
        @persistent = options[:persistent]
      end

      def default_organization_uri
        @default_organization_uri ||= begin
          unless @login_results
            do_login
          end
          case @login_results.body[:Org]
          when Array
            @login_results.body[:Org].first[:href]
          when Hash
            @login_results.body[:Org][:href]
          else
            nil
          end
        end
      end

      def reload
        @connections.each_value { |k,v| v.reset if v }
      end

      # If the cookie isn't set, do a get_organizations call to set it
      # and try the request.
      # If we get an Unauthorized error, we assume the token expired, re-auth and try again
      def request(params)
        unless @cookie
          do_login
        end
        begin
          do_request(params)
        rescue Excon::Errors::Unauthorized => e
          do_login
          do_request(params)
        end
      end

      private

      def ensure_parsed(uri)
        if uri.is_a?(String)
          URI.parse(uri)
        else
          uri
        end
      end

      def supported_version_numbers
        case supported_versions
        when Array
          supported_versions.map { |version| version[:Version] }
        when Hash
          [ supported_versions[:Version] ]
        end
      end

      def get_login_uri
        check_versions
        URI.parse case supported_versions
        when Array
          supported_versions.detect {|version| version[:Version] == @version }[:LoginUrl]
        when Hash
          supported_versions[:LoginUrl]
        end
      end

      # If we don't support any versions the service does, then raise an error.
      # If the @version that super selected isn't in our supported list, then select one that is.
      def check_versions
        if @version
          unless supported_version_numbers.include?(@version.to_s)
            raise UnsupportedVersion.new("#{@version} is not supported by the server.")
          end
          unless supporting_versions.include?(@version.to_s)
            raise UnsupportedVersion.new("#{@version} is not supported by #{self.class}")
          end
        else
          unless @version = (supported_version_numbers & supporting_versions).sort.first
            raise UnsupportedVersion.new("\nService @ #{@versions_uri} supports: #{supported_version_numbers.join(', ')}\n" +
                                         "#{self.class} supports: #{supporting_versions.join(', ')}")
          end
        end
      end

      # Don't need to  set the cookie for these or retry them if the cookie timed out
      def unauthenticated_request(params)
        do_request(params)
      end

      # Use this to set the Authorization header for login
      def authorization_header
        "Basic #{Base64.encode64("#{@username}:#{@password}").chomp!}"
      end

      def login_uri
        @login_uri ||= get_login_uri
      end

      # login handles the auth, but we just need the Set-Cookie
      # header from that call.
      def do_login
        @login_results = login
        @cookie = @login_results.headers['Set-Cookie']
      end

      # Actually do the request
      def do_request(params)
        # Convert the uri to a URI if it's a string.
        if params[:uri].is_a?(String)
          params[:uri] = URI.parse(params[:uri])
        end

        # Hash connections on the host_url ... There's nothing to say we won't get URI's that go to
        # different hosts.
        @connections[params[:uri].host_url] ||= Fog::Connection.new(params[:uri].host_url, @persistent)

        # Set headers to an empty hash if none are set.
        headers = params[:headers] || {}

        # Add our auth cookie to the headers
        if @cookie
          headers.merge!('Cookie' => @cookie)
        end

        # Make the request
        response = @connections[params[:uri].host_url].request({
          :body     => params[:body] || '',
          :expects  => params[:expects] || 200,
          :headers  => headers,
          :method   => params[:method] || 'GET',
          :path     => params[:uri].path
        })

        # Parse the response body into a hash
        #puts response.body
        unless response.body.empty?
          if params[:parse]
            document = Fog::ToHashDocument.new
            parser = Nokogiri::XML::SAX::PushParser.new(document)
            parser << response.body
            parser.finish

            response.body = document.body
          end
        end

        response
      end
    end

    class Mock
      include Shared
      include MockDataClasses

      def self.base_url
        "https://fakey.com/api/v0.8"
      end

      def self.data_reset
        @mock_data = nil
      end

      def self.data( base_url = self.base_url )
        MockDataClasses::Base.base_url = base_url

        @mock_data ||= MockData.new.tap do |mock_data|
          mock_data.versions << MockVersion.new(:version => "v0.8", :supported => true)

          mock_data.organizations << MockOrganization.new(:name => "Boom Inc.").tap do |mock_organization|
            mock_organization.vdcs << MockVdc.new(:name => "Boomstick").tap do |mock_vdc|
              mock_vdc.catalog.items << MockCatalogItem.new(:name => "Item 0").tap do |mock_catalog_item|
                mock_catalog_item.disks << MockVirtualMachineDisk.new(:size => 25 * 1024)
              end
              mock_vdc.catalog.items << MockCatalogItem.new(:name => "Item 1").tap do |mock_catalog_item|
                mock_catalog_item.disks << MockVirtualMachineDisk.new(:size => 25 * 1024)
              end
              mock_vdc.catalog.items << MockCatalogItem.new(:name => "Item 2").tap do |mock_catalog_item|
                mock_catalog_item.disks << MockVirtualMachineDisk.new(:size => 25 * 1024)
              end

              mock_vdc.networks << MockNetwork.new({ :subnet => "1.2.3.0/24" }, mock_vdc)
              mock_vdc.networks << MockNetwork.new({ :subnet => "4.5.6.0/24" }, mock_vdc)

              mock_vdc.virtual_machines << MockVirtualMachine.new({ :name => "Broom 1", :ip => "1.2.3.3" }, mock_vdc)
              mock_vdc.virtual_machines << MockVirtualMachine.new({ :name => "Broom 2", :ip => "1.2.3.4" }, mock_vdc)
              mock_vdc.virtual_machines << MockVirtualMachine.new({ :name => "Email!", :ip => "1.2.3.10" }, mock_vdc)
            end

            mock_organization.vdcs << MockVdc.new(:name => "Rock-n-Roll", :storage_allocated => 150, :storage_used => 40, :cpu_allocated => 1000, :memory_allocated => 2048).tap do |mock_vdc|
              mock_vdc.networks << MockNetwork.new({ :subnet => "7.8.9.0/24" }, mock_vdc)

              mock_vdc.virtual_machines << MockVirtualMachine.new({ :name => "Master Blaster", :ip => "7.8.9.10" }, mock_vdc)
            end
          end
        end
      end

      def initialize(options = {})
        @versions_uri = URI.parse('https://vcloud.fakey.com/api/versions')
      end

      def mock_it(status, mock_data, mock_headers = {})
        response = Excon::Response.new

        #Parse the response body into a hash
        if mock_data.empty?
          response.body = mock_data
        else
          document = Fog::ToHashDocument.new
          parser = Nokogiri::XML::SAX::PushParser.new(document)
          parser << mock_data
          parser.finish
          response.body = document.body
        end

        response.status = status
        response.headers = mock_headers
        response
      end

      def mock_error(expected, status, body='', headers={})
        raise Excon::Errors::Unauthorized.new("Expected(#{expected}) <=> Actual(#{status})")
      end

      def mock_data
        Fog::Vcloud::Mock.data
      end

    end
  end
end

require 'fog/vcloud/terremark/ecloud'
require 'fog/vcloud/terremark/vcloud'
