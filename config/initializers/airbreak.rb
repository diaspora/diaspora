# if old key still there, use it for new API,
# update application.yml to use airbrake_api_key instead
# (Former Hoptoad)
if AppConfig[:airbrake_api_key].present?
  Airbrake.configure do |config|
    config.api_key = AppConfig[:airbrake_api_key]
  end
elsif AppConfig[:hoptoad_api_key].present?
  puts "You're using old hoptoad_api_key, please update application.yml to use airbrake_api_key instead."
  Airbrake.configure do |config|
    config.api_key = AppConfig[:hoptoad_api_key]
  end
end
