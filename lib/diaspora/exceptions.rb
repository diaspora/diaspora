# frozen_string_literal: true

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
end
