# frozen_string_literal: true

Jasmine.configure do |config|
  config.prevent_phantom_js_auto_install = true
  config.runner_browser = :chromeheadless
  config.chrome_startup_timeout = 20
  config.chrome_cli_options["autoplay-policy"] = "no-user-gesture-required"
end
