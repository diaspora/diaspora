# Copyright (c) 2010-2012, Diaspora Inc. This file is
# licensed under the Affero General Public License version 3 or later. See
# the COPYRIGHT file.

module Diaspora
  # the post in question is not public, and that is somehow a problem
  class NonPublic < StandardError
  end

  # the account was closed and that should not be the case if we want
  # to continue
  class AccountClosed < StandardError
  end

  # something that should be accessed does not belong to the current user and
  # that prevents further execution
  class NotMine < StandardError
  end
  

  # Received a message without having a contact
  class ContactRequiredUnlessRequest < StandardError
  end

  # Got a relayable (comment, like etc.) without having the parent
  class RelayableObjectWithoutParent < StandardError
  end

  # After building an object the author doesn't match the one in the
  # original XML message
  class AuthorXMLAuthorMismatch < StandardError
  end
end
