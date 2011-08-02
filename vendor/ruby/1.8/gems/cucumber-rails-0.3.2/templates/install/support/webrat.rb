require 'webrat'
require 'webrat/core/matchers'

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false # Set to true if you want error pages to pop up in the browser
end

