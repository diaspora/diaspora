require 'fog/core/model'

module Fog
  module Brightbox
    class Compute

      class User < Fog::Model

        identity :id

        attribute :url
        attribute :resource_type
        attribute :name
        attribute :email_address
        attribute :email_verified
        attribute :ssh_key

        attribute :account_id, :aliases => "default_account", :squash => "id"
        attribute :accounts

        def save
          requires :identity

          options = {
            :email_address => email_address,
            :ssh_key => ssh_key,
            :name => name
          }

          data = connection.update_user(identity, options)
          merge_attributes(data)
          true
        end

      end

    end
  end
end
