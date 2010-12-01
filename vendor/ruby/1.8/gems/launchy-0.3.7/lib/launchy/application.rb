require 'rbconfig'

module Launchy
  class Application
    class << self
      def known_os_families
        @known_os_families ||= [ :windows, :darwin, :nix, :cygwin, :testing ]
      end

      def inherited(sub_class)
        application_classes << sub_class
      end
      def application_classes
        @application_classes ||= []
      end

      def find_application_class_for(*args)
        Launchy.log "#{self.name} : finding application classes for [#{args.join(' ')}]"
        application_classes.find do |klass|
          Launchy.log "#{self.name} : Trying #{klass.name}"
          if klass.handle?(*args) then
            true
          else
            false
          end
        end
      end

      # find an executable in the available paths
      # mkrf did such a good job on this I had to borrow it.
      def find_executable(bin,*paths)
        paths = ENV['PATH'].split(File::PATH_SEPARATOR) if paths.empty?
        paths.each do |path|
          file = File.join(path,bin)
          if File.executable?(file) then
            Launchy.log "#{self.name} : found executable #{file}"
            return file
          end
        end
        Launchy.log "#{self.name} : Unable to find `#{bin}' in #{paths.join(', ')}"
        return nil
      end

      # return the current 'host_os' string from ruby's configuration
      def my_os
        if ENV['LAUNCHY_HOST_OS'] then
          Launchy.log "#{self.name} : Using LAUNCHY_HOST_OS override of '#{ENV['LAUNCHY_HOST_OS']}'"
          return ENV['LAUNCHY_HOST_OS']
        else
          ::Config::CONFIG['host_os']
        end
      end

      # detect what the current os is and return :windows, :darwin or :nix
      def my_os_family(test_os = my_os)
        case test_os
        when /mingw/i
          family = :windows
        when /mswin/i
          family = :windows
        when /windows/i
          family = :windows
        when /darwin/i
          family = :darwin
        when /mac os/i
          family = :darwin
        when /solaris/i
          family = :nix
        when /bsd/i
          family = :nix
        when /linux/i
          family = :nix
        when /aix/i
          family = :nix
        when /cygwin/i
          family = :cygwin
        when /testing/i
          family = :testing
        else
          $stderr.puts "Unknown OS familiy for '#{test_os}'.  Please report this bug to <jeremy at hinegardner dot org>"
          family = :unknown
        end
      end
    end


    # Determine the appropriate desktop environment for *nix machine.  Currently this is
    # linux centric.  The detection is based upon the detection used by xdg-open from
    # http://portland.freedesktop.org/wiki/XdgUtils
    def nix_desktop_environment
      if not defined? @nix_desktop_environment then
        @nix_desktop_environment = :generic
        if ENV["KDE_FULL_SESSION"] || ENV["KDE_SESSION_UID"] then
          @nix_desktop_environment = :kde
        elsif ENV["GNOME_DESKTOP_SESSION_ID"] then
          @nix_desktop_environment = :gnome
        elsif find_executable("xprop") then
          if %x[ xprop -root _DT_SAVE_MODE | grep ' = \"xfce\"$' ].strip.size > 0 then
            @nix_desktop_environment = :xfce
          end
        end
        Launchy.log "#{self.class.name} : nix_desktop_environment => '#{@nix_desktop_environment}'"
      end
      return @nix_desktop_environment
    end

    # find an executable in the available paths
    def find_executable(bin,*paths)
      Application.find_executable(bin,*paths)
    end

    # return the current 'host_os' string from ruby's configuration
    def my_os
      Application.my_os
    end

    # detect what the current os is and return :windows, :darwin, :nix, or :cygwin
    def my_os_family(test_os = my_os)
      Application.my_os_family(test_os)
    end

    # returns the list of command line application names for the current os.  The list
    # returned should only contain appliations or commands that actually exist on the
    # system.  The list members should have their full path to the executable.
    def app_list
      @app_list ||= self.send("#{my_os_family}_app_list")
    end

    # On darwin a good general default is the 'open' executable.
    def darwin_app_list
      Launchy.log "#{self.class.name} : Using 'open' application on darwin."
      [ find_executable('open') ]
    end

    # On windows a good general default is the 'start' Command Shell command
    def windows_app_list
      Launchy.log "#{self.class.name} : Using 'start' command on windows."
            %w[ start ]
    end

    # Cygwin uses the windows start but through an explicit execution of the cmd shell
    def cygwin_app_list
      Launchy.log "#{self.class.name} : Using 'cmd /C start' on windows."
      [ "cmd /C start" ]
    end

    # used only for running tests
    def testing_app_list
      []
    end

    # run the command
    def run(cmd,*args)
      Launchy.log "#{self.class.name} : Spawning on #{my_os_family} : #{cmd} #{args.inspect}"

      if my_os_family == :windows then
        # NOTE: the command is purposely omitted here because
        #       When "cmd /c start filename" is
        #       run, the shell interprets it as two commands:
        #       (1) "start" opens a new terminal, and (2)
        #       "filename" causes the file to be launched.
        system 'cmd', '/c', cmd, *args
      else
        # fork, and the child process should NOT run any exit handlers
        child_pid = fork do
          # NOTE: we pass a dummy argument *before*
          #       the actual command to prevent sh
          #       from silently consuming our actual
          #       command and assigning it to $0!
          dummy = ''
          system 'sh', '-c', '"$@" >/dev/null 2>&1', dummy, cmd, *args
          exit!
        end
        Process.detach(child_pid)
      end
    end
  end
end
