###############################################
# mongrel_simple_ctrl.rb
#
# Control script for the Mongrel server
###############################################
require "optparse"
require "win32/service"
include Win32

# I start the service name with an 'A' so that it appears at the top
SERVICE_NAME = "MongrelSvc"
SERVICE_DISPLAYNAME = "Mongrel HTTP Server"
SCRIPT_ROOT = File.join(File.dirname(__FILE__), '.') 
SCRIPT_NAME = "mongrel_simple_service.rb"
SERVICE_SCRIPT = File.expand_path(SCRIPT_ROOT + '/' + SCRIPT_NAME)

OPTIONS = {}

ARGV.options do |opts|
   opts.on("-d", "--delete", "Delete the service"){ OPTIONS[:delete] = true }
   opts.on("-u", "--uninstall","Delete the service"){ OPTIONS[:uninstall] = true }
   opts.on("-s", "--start",  "Start the service"){ OPTIONS[:start] = true }
   opts.on("-x", "--stop",   "Stop the service"){ OPTIONS[:stop] = true }
   opts.on("-i", "--install","Install the service"){ OPTIONS[:install] = true }

   opts.on("-h", "--help",   "Show this help message."){ puts opts; exit }

   opts.parse!
end

# Install the service
if OPTIONS[:install]  
   require 'rbconfig'
   
   svc = Service.new
   svc.create_service{ |s|
      s.service_name     = SERVICE_NAME
      s.display_name     = SERVICE_DISPLAYNAME
      s.binary_path_name = Config::CONFIG['bindir'] + '/ruby ' + SERVICE_SCRIPT
      s.dependencies     = []
   }
   svc.close
   puts "#{SERVICE_DISPLAYNAME} service installed"
end

# Start the service
if OPTIONS[:start]
   Service.start(SERVICE_NAME)
   started = false
   while started == false
      s = Service.status(SERVICE_NAME)
      started = true if s.current_state == "running"
      break if started == true
      puts "One moment, " + s.current_state
      sleep 1
   end
   puts "#{SERVICE_DISPLAYNAME} service started"
end

# Stop the service
if OPTIONS[:stop]
   Service.stop(SERVICE_NAME)
   stopped = false
   while stopped == false
      s = Service.status(SERVICE_NAME)
      stopped = true if s.current_state == "stopped"
      break if stopped == true
      puts "One moment, " + s.current_state
      sleep 1
   end
   puts "#{SERVICE_DISPLAYNAME} service stopped"
end

# Delete the service.  Stop it first.
if OPTIONS[:delete] || OPTIONS[:uninstall]
   begin
      Service.stop(SERVICE_NAME)
   rescue
   end
   begin
    Service.delete(SERVICE_NAME)
   rescue
   end
   puts "#{SERVICE_DISPLAYNAME} service deleted"
end
# END mongrel_rails_ctrl.rb






