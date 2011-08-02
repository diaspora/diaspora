require 'fog/core/model'

module Fog
  module Brightbox
    class Compute

      class Account < Fog::Model

        identity :id
        attribute :resource_type
        attribute :url
        attribute :name
        attribute :status
        attribute :address_1
        attribute :address_2
        attribute :city
        attribute :county
        attribute :postcode
        attribute :country_code
        attribute :country_name
        attribute :vat_registration_number
        attribute :telephone_number
        attribute :telephone_verified
        attribute :ram_limit
        attribute :ram_used
        attribute :limits_cloudips
        attribute :library_ftp_host
        attribute :library_ftp_user
        # This is always returned as null/nil unless performing a reset_ftp_password request
        attribute :library_ftp_password
        attribute :created_at, :type => :time



        attribute :owner_id, :aliases => "owner", :squash => "id"
        attribute :clients
        attribute :images
        attribute :servers
        attribute :users
        attribute :zones

        def reset_ftp_password
          requires :identity
          connection.reset_ftp_password_account(identity)["library_ftp_password"]
        end

      end

    end
  end
end