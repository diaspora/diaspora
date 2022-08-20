# frozen_string_literal: true

module Diaspora
  module Federation
    # Raised, if author is ignored by the relayable parent author
    class AuthorIgnored < RuntimeError
    end

    # Raised, if the author of the existing object doesn't match the received author
    class InvalidAuthor < RuntimeError
    end

    # Raised, if the recipient account is closed already
    class RecipientClosed < RuntimeError
    end

    # Raised if pod is blocked by admin
    class PodBlocked < RuntimeError
    end
  end
end

require "diaspora/federation/dispatcher"
require "diaspora/federation/entities"
require "diaspora/federation/mappings"
require "diaspora/federation/receive"
