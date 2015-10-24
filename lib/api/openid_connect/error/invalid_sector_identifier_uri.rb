module Api
  module OpenidConnect
    module Error
      class InvalidSectorIdentifierUri < ::ArgumentError
        def initialize
          super "Invalid sector identifier uri"
        end
      end
    end
  end
end
