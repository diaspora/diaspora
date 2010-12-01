require 'childprocess/errors'
require 'childprocess/abstract_process'
require 'childprocess/abstract_io'
require "fcntl"

module ChildProcess
  autoload :Unix,     'childprocess/unix'
  autoload :Windows,  'childprocess/windows'
  autoload :JRuby,    'childprocess/jruby'
  autoload :IronRuby, 'childprocess/ironruby'

  class << self

    def new(*args)
      case platform
      when :jruby
        JRuby::Process.new(args)
      when :ironruby
        IronRuby::Process.new(args)
      when :windows
        Windows::Process.new(args)
      else
        Unix::Process.new(args)
      end
    end
    alias_method :build, :new

    def platform
      if RUBY_PLATFORM == "java"
        :jruby
      elsif defined?(RUBY_ENGINE) && RUBY_ENGINE == "ironruby"
        :ironruby
      elsif RUBY_PLATFORM =~ /mswin|msys|mingw32/
        :windows
      else
        os
      end
    end

    def unix?
      !jruby? && [:macosx, :linux, :unix].include?(os)
    end

    def jruby?
      platform == :jruby
    end

    def windows?
      !jruby? && os == :windows
    end

    def os
      @os ||= (
        require "rbconfig"
        host_os = RbConfig::CONFIG['host_os']

        case host_os
        when /mswin|msys|mingw32/
          :windows
        when /darwin|mac os/
          :macosx
        when /linux/
          :linux
        when /solaris|bsd/
          :unix
        else
          raise Error, "unknown os: #{host_os.inspect}"
        end
      )
    end
    
    #
    # By default, a child process will inherit open files and sockets from the parent process.
    # This helper provides a cross-platform way of making sure that doesn't happen for the given file.
    # 

    def close_on_exec(file)
      if windows?
        Windows.dont_inherit file
      elsif file.respond_to?(:fcntl) && defined?(Fcntl::FD_CLOEXEC)
        file.fcntl Fcntl::F_SETFD, Fcntl::FD_CLOEXEC
      else
        raise Error, "not sure how to set close-on-exec for #{file.inspect} on #{platform}"
      end
    end

  end # class << self
end # ChildProcess