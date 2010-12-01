module Mocha # :nodoc:
  
  # Configuration settings
  class Configuration
    
    DEFAULTS = { :stubbing_method_unnecessarily => :allow, :stubbing_method_on_non_mock_object => :allow, :stubbing_non_existent_method => :allow, :stubbing_non_public_method => :allow }
    
    class << self
    
      # :call-seq: allow(action, &block)
      #
      # Allow the specified <tt>action</tt> (as a symbol).
      # The <tt>actions</tt> currently available are <tt>:stubbing_method_unnecessarily, :stubbing_method_on_non_mock_object, :stubbing_non_existent_method, :stubbing_non_public_method</tt>.
      # If given a block, the configuration for the action will only be changed for the duration of the block, and will then be restored to the previous value.
      def allow(action, &block)
        change_config action, :allow, &block
      end
    
      def allow?(action) # :nodoc:
        configuration[action] == :allow
      end
    
      # :call-seq: warn_when(action, &block)
      #
      # Warn if the specified <tt>action</tt> (as a symbol) is attempted.
      # The <tt>actions</tt> currently available are <tt>:stubbing_method_unnecessarily, :stubbing_method_on_non_mock_object, :stubbing_non_existent_method, :stubbing_non_public_method</tt>.
      # If given a block, the configuration for the action will only be changed for the duration of the block, and will then be restored to the previous value.
      def warn_when(action, &block)
        change_config action, :warn, &block
      end
    
      def warn_when?(action) # :nodoc:
        configuration[action] == :warn
      end
    
      # :call-seq: prevent(action, &block)
      #
      # Raise a StubbingError if the specified <tt>action</tt> (as a symbol) is attempted.
      # The <tt>actions</tt> currently available are <tt>:stubbing_method_unnecessarily, :stubbing_method_on_non_mock_object, :stubbing_non_existent_method, :stubbing_non_public_method</tt>.
      # If given a block, the configuration for the action will only be changed for the duration of the block, and will then be restored to the previous value.
      def prevent(action, &block)
        change_config action, :prevent, &block
      end
    
      def prevent?(action) # :nodoc:
        configuration[action] == :prevent
      end
    
      def reset_configuration # :nodoc:
        @configuration = nil
      end
    
      private
    
      def configuration # :nodoc:
        @configuration ||= DEFAULTS.dup
      end

      def change_config(action, new_value, &block) # :nodoc:
        if block_given?
          temporarily_change_config action, new_value, &block
        else
          configuration[action] = new_value
        end
      end

      def temporarily_change_config(action, new_value, &block) # :nodoc:
        original_value = configuration[action]
        configuration[action] = new_value
        yield
      ensure
        configuration[action] = original_value
      end
    
    end
    
  end
  
end
