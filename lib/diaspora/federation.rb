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
  end
end
