# frozen_string_literal: true

# a logging mixin providing the logger
module Diaspora
  module Logging
    private

    def logger
      @logger ||= ::Logging::Logger[self]
    end
  end
end
