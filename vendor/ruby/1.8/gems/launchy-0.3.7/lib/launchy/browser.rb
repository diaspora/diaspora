require 'launchy/application'
require 'uri'

module Launchy
  class Browser < Application


    class << self
      def desktop_environment_browser_launchers
        @desktop_environment_browser_launchers ||= {
          :kde     => "kfmclient",
          :gnome   => "gnome-open",
          :xfce    => "exo-open",
          :generic => "htmlview"
        }
      end
      def fallback_browsers
        @fallback_browsers ||=  %w[ firefox seamonkey opera mozilla netscape galeon ]
      end
      def run(*args)
        Browser.new.visit(args[0])
      end

      # return true if this class can handle the given parameter(s)
      def handle?(*args)
        begin
          Launchy.log "#{self.name} : testing if [#{args[0]}] (#{args[0].class}) is a url."
          uri = URI.parse(args[0])
          result =  [URI::HTTP, URI::HTTPS, URI::FTP].include?(uri.class)
        rescue Exception => e
          # hmm... why does rcov not see that this is executed ?
          Launchy.log "#{self.name} : not a url, #{e}"
          return false
        end
      end
    end

    def initialize
      @browser = nil
      @nix_app_list = []
      raise "Unable to find browser to launch for os family '#{my_os_family}'." unless browser
    end

    def desktop_environment_browser_launchers
      self.class.desktop_environment_browser_launchers
    end

    def fallback_browsers
      self.class.fallback_browsers
    end

    # Find a list of potential browser applications to run on *nix machines.
    # The order is:
    #     1) What is in ENV['LAUNCHY_BROWSER'] or ENV['BROWSER']
    #     2) xdg-open
    #     3) desktop environment launcher program
    #     4) a list of fallback browsers
    def nix_app_list
      if @nix_app_list.empty?
        browser_cmds = ['xdg-open']
        browser_cmds << desktop_environment_browser_launchers[nix_desktop_environment]
        browser_cmds << fallback_browsers
        browser_cmds.flatten!
        browser_cmds.delete_if { |b| b.nil? || (b.strip.size == 0) }
        Launchy.log "#{self.class.name} : Initial *Nix Browser List: #{browser_cmds.join(', ')}"
        @nix_app_list = browser_cmds.collect { |bin| find_executable(bin) }.find_all { |x| not x.nil? }
        Launchy.log "#{self.class.name} : Filtered *Nix Browser List: #{@nix_app_list.join(', ')}"
      end
      @nix_app_list
    end

    # return the full command line path to the browser or nil
    def browser
      if not @browser then
        if ENV['LAUNCHY_BROWSER'] and File.exists?(ENV['LAUNCHY_BROWSER']) then
          Launchy.log "#{self.class.name} : Using LAUNCHY_BROWSER environment variable : #{ENV['LAUNCHY_BROWSER']}"
          @browser = ENV['LAUNCHY_BROWSER']
        elsif ENV['BROWSER'] and File.exists?(ENV['BROWSER']) then
          Launchy.log "#{self.class.name} : Using BROWSER environment variable : #{ENV['BROWSER']}"
          @browser = ENV['BROWSER']
        elsif app_list.size > 0 then
          @browser = app_list.first
          Launchy.log "#{self.class.name} : Using application list : #{@browser}"
        else
          msg = "Unable to launch. No Browser application found."
          Launchy.log "#{self.class.name} : #{msg}"
          $stderr.puts msg
        end
      end
      return @browser
    end

    # launch the browser at the appointed url
    def visit(url)
      run(browser,url)
    end
  end
end
