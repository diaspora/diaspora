module Launchy::Detect
  #
  # Detect the current desktop environment for *nix machines
  # Currently this is Linux centric. The detection is based upon the detection
  # used by xdg-open from http://portland.freedesktop.org/wiki/XdgUtils
  class NixDesktopEnvironment
    class NotFoundError < Launchy::Error; end

    extend ::Launchy::DescendantTracker

    # Detect the current *nix desktop environment
    #
    # If the current dekstop environment be detected, the return
    # NixDekstopEnvironment::Unknown
    def self.detect
      found = find_child( :is_current_desktop_environment? )
      return found if found
      raise NotFoundError, "Current Desktop environment not found. #{Launchy.bug_report_message}"
    end

    def self.fallback_browsers
      %w[ firefox seamonkey opera mozilla netscape galeon ]
    end

    #---------------------------------------
    # The list of known desktop environments
    #---------------------------------------

    class Kde < NixDesktopEnvironment
      def self.is_current_desktop_environment?
        ENV['KDE_FULL_SESSION']
      end

      def self.browser
        'kfmclient'
      end
    end

    class Gnome < NixDesktopEnvironment
      def self.is_current_desktop_environment?
        ENV['GNOME_DESKTOP_SESSION_ID']
      end

      def self.browser
        'gnome-open'
      end
    end

    class Xfce < NixDesktopEnvironment
      def self.is_current_desktop_environment?
        %x[ xprop -root _DT_SAVE_MODE | grep ' = \"xfce\"$' ].strip.size > 0
      end

      def self.browser
        'exo-open'
      end
    end
  end
end

