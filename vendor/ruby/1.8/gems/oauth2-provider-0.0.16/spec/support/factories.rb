module OAuth2::Provider
  module RSpec
    module Factories
      def build_client(attributes = {})
        OAuth2::Provider.client_class.new({:name => 'client'}.merge(attributes))
      end

      def create_client(attributes = {})
        build_client(attributes).tap do |c|
          c.save!
        end
      end

      def build_authorization(attributes = {})
        OAuth2::Provider.authorization_class.new({
          :client => build_client
        }.merge(attributes))
      end

      def create_authorization(attributes = {})
        build_authorization({:client => create_client}.merge(attributes)).tap do |ag|
          ag.save!
        end
      end

      def build_authorization_code(attributes = {})
        OAuth2::Provider.authorization_code_class.new({
          :redirect_uri => "https://client.example.com/callback",
          :authorization => build_authorization
        }.merge(attributes))
      end

      def create_authorization_code(attributes = {})
        build_authorization_code({:authorization => create_authorization}.merge(attributes)).tap do |ac|
          ac.save!
        end
      end

      def build_access_token(attributes = {})
        OAuth2::Provider.access_token_class.new({
          :authorization => build_authorization
        }.merge(attributes))
      end

      def create_access_token(attributes = {})
        build_access_token({:authorization => create_authorization}.merge(attributes)).tap do |ac|
          ac.save!
        end
      end

      def create_resource_owner(attributes = {})
        ExampleResourceOwner.create!
      end
    end
  end
end
