require 'shellwords'

module Launchy::Detect
  class Runner
    class NotFoundError < Launchy::Error; end

    extend ::Launchy::DescendantTracker

    # Detect the current command runner
    #
    # This will return an instance of the Runner to be used to do the
    # application launching.
    #
    # If a runner cannot be detected then raise Runner::NotFoundError
    #
    # The runner rules are, in order:
    #
    # 1) If you are on windows, you use the Windows Runner no matter what
    # 2) If you are using the jruby engine, use the Jruby Runner. Unless rule
    #    (1) took effect
    # 3) Use Forkable (barring rules (1) and (2))
    def self.detect
      host_os_family = Launchy::Detect::HostOsFamily.detect
      ruby_engine    = Launchy::Detect::RubyEngine.detect

      return Windows.new if host_os_family.windows?
      if ruby_engine.jruby? then
        require 'spoon'
        return Jruby.new
      end
      return Forkable.new 
    end

    #
    # cut it down to just the shell commands that will be passed to exec or
    # posix_spawn. The cmd argument is split according to shell rules and the
    # args are escaped according to shell rules.
    #
    def shell_commands( cmd, args )
      cmdline = [ cmd.shellsplit ]
      cmdline << args.flatten.collect{ |a| a.to_s.shellescape }
      return commandline_normalize( cmdline )
    end

    def commandline_normalize( cmdline )
      c = cmdline.flatten!
      c = c.find_all { |a| (not a.nil?) and ( a.size > 0 ) }
      Launchy.log "ARGV => #{c.inspect}"
      return c
    end

    def dry_run( cmd, *args )
      shell_commands(cmd, args).join(" ")
    end

    def run( cmd, *args )
      if Launchy.dry_run? then
        $stdout.puts dry_run( cmd, *args )
      else
        wet_run( cmd, *args )
      end
    end


    #---------------------------------------
    # The list of known runners
    #---------------------------------------

    class Windows < Runner

      def all_args( cmd, *args )
        [ 'cmd', '/c', *shell_commands( cmd, *args ) ]
      end

      def dry_run( cmd, *args )
        all_args( cmd, *args ).join(" ")
      end

      def shell_commands( cmd, *args )
        cmdline = [ cmd ]
        cmdline << args.flatten.collect { |a| a.to_s.gsub("&", "^&") }
        return commandline_normalize( cmdline )
      end

      def wet_run( cmd, *args )
        system( *all_args( cmd, *args ) )
      end
    end

    class Jruby < Runner
      def wet_run( cmd, *args )
        Spoon.spawnp( *shell_commands( cmd, *args ) )
      end
    end

    class Forkable < Runner
      def wet_run( cmd, *args )
        child_pid = fork do
          exec( *shell_commands( cmd, *args ))
          exit!
        end
        Process.detach( child_pid )
      end
    end
  end
end
