# frozen_string_literal: true

module Api
  module OpenidConnect
    module Error
      class InvalidRedirectUri < ::ArgumentError
        def initialize
          super "Redirect uri contains fragment"
        end
      end
      class InvalidSectorIdentifierUri < ::ArgumentError
        def initialize
          super "Invalid sector identifier uri"
        end
      end
    end
  end
end
