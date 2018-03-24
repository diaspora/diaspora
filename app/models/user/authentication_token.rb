# frozen_string_literal: true

class User
  module AuthenticationToken
    extend ActiveSupport::Concern

    # Generate new authentication token and save the record.
    def reset_authentication_token!
      self.authentication_token = self.class.authentication_token
      save(validate: false)
    end

    # Generate authentication token unless already exists and save the record.
    def ensure_authentication_token!
      reset_authentication_token! if authentication_token.blank?
    end

    module ClassMethods
      # Generate a token checking if one does not already exist in the database.
      def authentication_token
        loop do
          token = Devise.friendly_token(30)
          break token unless User.exists?(authentication_token: token)
        end
      end
    end
  end
end
