module Api
  module OpenidConnect
    module Exception
      class InvalidRedirectUri < ::ArgumentError
        def initialize
          super "Redirect uri contains fragment"
        end
      end
    end
  end
end
