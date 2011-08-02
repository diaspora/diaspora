module Typhoeus
  class Hydra
    module Callbacks
      def self.extended(base)
        class << base
          attr_accessor :global_hooks
        end
        base.global_hooks = Hash.new { |h, k| h[k] = [] }
      end

      def after_request_before_on_complete(&block)
        global_hooks[:after_request_before_on_complete] << block
      end

      def run_global_hooks_for(name, request)
        global_hooks[name].each { |hook| hook.call(request) }
      end

      def clear_global_hooks
        global_hooks.clear
      end
    end
  end
end
