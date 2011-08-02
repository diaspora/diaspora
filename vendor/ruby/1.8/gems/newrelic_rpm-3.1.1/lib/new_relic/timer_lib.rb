# Copyright:  (C) 2008 David Vollbracht & Philippe Hanrigou

# This code was borrowed from the system_timer gem under the terms
# of the Ruby license.  It has been slightly modified.

# Defines the constant TimerLib to the appropriate timeout library
module NewRelic #:nodoc:

  begin
    # Try to use the SystemTimer gem instead of Ruby's timeout library
    # when running on Ruby 1.8.x. See:
    #   http://ph7spot.com/articles/system_timer
    # We don't want to bother trying to load SystemTimer on jruby,
    # ruby 1.9+ and rbx.
    if !defined?(RUBY_ENGINE) || (RUBY_ENGINE == 'ruby' && RUBY_VERSION < '1.9.0')
      require 'system_timer'
      TimerLib = SystemTimer
    else
      require 'timeout'
      TimerLib = Timeout
    end
  rescue LoadError => e
    require 'timeout'
    TimerLib = Timeout
  end

end
