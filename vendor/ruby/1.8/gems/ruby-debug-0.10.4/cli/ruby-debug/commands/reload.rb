module Debugger
  # Implements debugger "reload" command.
  class ReloadCommand < Command
    self.allow_in_control = true

    register_setting_get(:reload_source_on_change) do 
      Debugger.reload_source_on_change
    end
    register_setting_set(:reload_source_on_change) do |value|
      Debugger.reload_source_on_change = value
    end
    
    def regexp
      /^\s*r(?:eload)?$/
    end
    
    def execute
      Debugger.source_reload
      print "Source code is reloaded. Automatic reloading is #{source_reloading}.\n"
    end
    
    private
    
    def source_reloading
      Debugger.reload_source_on_change ? 'on' : 'off'
    end
    
    class << self
      def help_command
        'reload'
      end

      def help(cmd)
        %{
          r[eload]\tforces source code reloading
        }
      end
    end
  end
end
