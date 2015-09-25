module Api
  module OpenidConnect
    module Exception
      class InvalidSectorIdentifierUri < ::ArgumentError
        def initialize
          super "Invalid sector identifier uri"
        end
      end
    end
  end
end
