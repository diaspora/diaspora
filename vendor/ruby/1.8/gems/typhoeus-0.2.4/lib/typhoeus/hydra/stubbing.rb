module Typhoeus
  class Hydra
    module Stubbing
      module SharedMethods
        def stub(method, url, options = {})
          stubs << HydraMock.new(url, method, options)
          stubs.last
        end

        def clear_stubs
          self.stubs = []
        end

        def find_stub_from_request(request)
          stubs.detect { |stub| stub.matches?(request) }
        end

        def self.extended(base)
          class << base
            attr_accessor :stubs
          end
          base.stubs = []
        end
      end

      def self.included(base)
        base.extend(SharedMethods)
        base.class_eval do
          attr_accessor :stubs
        end
      end

      def assign_to_stub(request)
        m = find_stub_from_request(request)

        # Fallback to global stubs.
        m ||= self.class.find_stub_from_request(request)

        if m
          m.add_request(request)
          @active_stubs << m
          m
        else
          nil
        end
      end
      private :assign_to_stub

      include SharedMethods
    end
  end
end
