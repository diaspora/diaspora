require 'new_relic/control/frameworks/ruby'
module NewRelic
  class Control
    module Frameworks
      # This is the control used when starting up in the context of
      # The New Relic Infrastructure Agent.  We want to call this
      # out specifically because in this context we are not monitoring
      # the running process, but actually external things.
      class External < NewRelic::Control::Frameworks::Ruby
        def init_config(options={})
          super
        end
      end
    end
  end
end
