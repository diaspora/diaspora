# frozen_string_literal: true

module Api
  module OpenidConnect
    class UserInfoController < ApplicationController
      include Api::OpenidConnect::ProtectedResourceEndpoint

      before_action do
        require_access_token %w(openid)
      end

      def show
        serializer = UserInfoSerializer.new(current_user)
        auth = current_token.authorization
        serializer.serialization_options = {authorization: auth}
        attributes_without_essential =
          serializer.attributes.with_indifferent_access.select {|scope| auth.scopes.include? scope }
        attributes = attributes_without_essential.merge(
          sub: serializer.sub)
        render json: attributes.to_json
      end

      def current_user
        current_token ? current_token.authorization.user : nil
      end
    end
  end
end
