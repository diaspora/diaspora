module Selenium
  module Rake
  
    # Rake tasks to start a Remote Control server.
    # 
    # require 'selenium/rake/tasks' 
    # 
    # Selenium::Rake::RemoteControlStartTask.new do |rc|
    #   rc.port = 4444
    #   rc.timeout_in_seconds = 3 * 60
    #   rc.background = true
    #   rc.wait_until_up_and_running = true
    #   rc.jar_file = "/path/to/where/selenium-rc-standalone-jar-is-installed"
    #   rc.additional_args << "-singleWindow"
    # end
    # 
    # If you do not explicitly specify the path to selenium remote control jar
    # it will be "auto-discovered" in `vendor` directory using the following
    # path : `vendor/selenium-remote-control/selenium-server*-standalone.jar`
    # 
    # To leverage the latest selenium-client capabilities, you may need to download 
    # a recent nightly build of a standalone packaging of Selenium Remote 
    # Control. You will find the nightly build at 
    # http://nexus.openqa.org/content/repositories/snapshots/org/seleniumhq/selenium/server/selenium-server/
    class RemoteControlStartTask
      attr_accessor :host, :port, :timeout_in_seconds, :background, 
                    :wait_until_up_and_running, :additional_args,
                    :log_to
      attr_reader :jar_file

      JAR_FILE_PATTERN = "vendor/selenium-remote-control/selenium-server-*.jar"

      def initialize(name = :'selenium:rc:start')
        @name = name
        @host = "localhost"
        @port = 4444
        @timeout_in_seconds = 5
        project_specific_jar = Dir[JAR_FILE_PATTERN].first
        @jar_file = project_specific_jar
        @additional_args = []
        @background = false
        @wait_until_up_and_running = false
        yield self if block_given?
        define
      end
    
      def jar_file=(new_jar_file)
        @jar_file = File.expand_path(new_jar_file)
      end
      
      def define
        desc "Launch Selenium Remote Control"
        task @name do
          puts "Starting Selenium Remote Control at 0.0.0.0:#{@port}..."
          raise "Could not find jar file '#{@jar_file}'. Expected it under #{JAR_FILE_PATTERN}" unless @jar_file && File.exists?(@jar_file)
          remote_control = Selenium::RemoteControl::RemoteControl.new("0.0.0.0", @port, :timeout => @timeout_in_seconds)
          remote_control.jar_file = @jar_file
          remote_control.additional_args = @additional_args
          remote_control.log_to = @log_to
          remote_control.start :background => @background
          if @background && @wait_until_up_and_running
            puts "Waiting for Remote Control to be up and running..."
            TCPSocket.wait_for_service :host => @host, :port => @port
          end
          puts "Selenium Remote Control at 0.0.0.0:#{@port} ready"
        end
      end

    end
  end
end
