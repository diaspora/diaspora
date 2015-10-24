module Api
  module OpenidConnect
    module Error
      class InvalidRedirectUri < ::ArgumentError
        def initialize
          super "Redirect uri contains fragment"
        end
      end
    end
  end
end
