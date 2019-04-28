# frozen_string_literal: true

class ArchiveValidator
  class AuthorPrivateKeyValidator < BaseValidator
    include Diaspora::Logging

    def validate
      return if person.nil?
      return if person.public_key.export == private_key.public_key.export

      messages.push("Private key in the archive doesn't match the known key of #{person.diaspora_handle}")
    rescue DiasporaFederation::Discovery::DiscoveryError
      logger.info "#{self}: Archive author couldn't be fetched (old home pod is down?), will continue with data"\
        " import only"
    end
  end
end
