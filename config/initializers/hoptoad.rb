if AppConfig[:hoptoad_api_key].present?
  HoptoadNotifier.configure do |config|
    config.api_key = AppConfig[:hoptoad_api_key]
  end
end
