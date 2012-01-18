# (Former Hoptoad)
if AppConfig[:airbreak_api_key].present?
  Airbrake.configure do |config|
    config.api_key = AppConfig[:airbreak_api_key]
  end
end
