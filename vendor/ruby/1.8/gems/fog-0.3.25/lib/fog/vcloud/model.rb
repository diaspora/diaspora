module Fog
  class Vcloud < Fog::Service
    class Model < Fog::Model

      attr_accessor :loaded
      alias_method :loaded?, :loaded

      def reload
        instance = super
        @loaded = true
        instance
      end

      def load_unless_loaded!
        unless @loaded
          reload
        end
      end

    end
  end
end
