#custom_logger.rb
class FederationLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{Rails.env}-#{timestamp}: #{msg}\n"
  end
end

if Rails.env.match(/integration/)
  puts "using federation logger"
  logfile = File.open(Rails.root.join("log", "#{Rails.env}_federation.log"), 'a')  #create log file
  logfile.sync = true  #automatically flushes data to file
  FEDERATION_LOGGER = FederationLogger.new(logfile)  #constant accessible anywhere
else
  FEDERATION_LOGGER = Rails.logger
end