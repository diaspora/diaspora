# frozen_string_literal: true

module Api
  module OpenidConnect
    module SubjectIdentifierCreator
      def self.create(auth)
        if auth.o_auth_application.ppid?
          identifier = auth.o_auth_application.sector_identifier_uri ||
            URI.parse(auth.o_auth_application.redirect_uris[0]).host
          pairwise_pseudonymous_identifier =
            auth.user.pairwise_pseudonymous_identifiers.find_or_create_by(identifier: identifier)
          pairwise_pseudonymous_identifier.guid
        else
          auth.user.diaspora_handle
        end
      end
    end
  end
end
