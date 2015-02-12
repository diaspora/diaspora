if not AppConfig.environment.log.blank?
  Rails.logger = ActiveSupport::Logger.new(AppConfig.environment.log)
else
  Rails.logger = ActiveSupport::Logger.new(STDOUT)
end