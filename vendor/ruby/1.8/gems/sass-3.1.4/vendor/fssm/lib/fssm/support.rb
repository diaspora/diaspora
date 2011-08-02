require 'rbconfig'

module FSSM::Support
  class << self
    def backend
      @@backend ||= case
        when mac? && !jruby? && carbon_core?
          'FSEvents'
        when linux? && rb_inotify?
          'Inotify'
        else
          'Polling'
      end
    end

    def jruby?
      defined?(JRUBY_VERSION)
    end

    def mac?
      Config::CONFIG['target_os'] =~ /darwin/i
    end

    def linux?
      Config::CONFIG['target_os'] =~ /linux/i
    end

    def carbon_core?
      begin
        require 'osx/foundation'
        OSX.require_framework '/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework'
        true
      rescue LoadError
        STDERR.puts("Warning: Unable to load CarbonCore. FSEvents will be unavailable.")
        false
      end
    end

    def rb_inotify?
      found = begin
        require 'rb-inotify'
        if defined?(INotify::VERSION)
          version = INotify::VERSION
          version[0] > 0 || version[1] >= 6
        end
      rescue LoadError
        false
      end
      STDERR.puts("Warning: Unable to load rb-inotify >= 0.5.1. Inotify will be unavailable.") unless found
      found
    end

    def use_block(context, block)
      return if block.nil?
      if block.arity == 1
        block.call(context)
      else
        context.instance_eval(&block)
      end
    end

  end
end
