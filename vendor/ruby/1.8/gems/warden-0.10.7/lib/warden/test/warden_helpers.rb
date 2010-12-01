# encoding: utf-8

module Warden

  module Test
    module WardenHelpers
      # Adds a block to be executed on the next request when the stack reaches warden.
      # The warden proxy is yielded to the block
      # @api public
      def on_next_request(&blk)
        _on_next_request << blk
      end

      # resets wardens tests
      # any blocks queued to execute will be removed
      # @api public
      def test_reset!
        _on_next_request.clear
      end

      # A containter for the on_next_request items.
      # @api private
      def _on_next_request
        @_on_next_request ||= []
        @_on_next_request
      end
    end
  end
end
