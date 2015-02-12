if not AppConfig.environment.logfile.blank?
  Rails.logger = ActiveSupport::Logger.new(AppConfig.environment.logfile)
else
  Rails.logger = ActiveSupport::Logger.new(STDOUT)
end