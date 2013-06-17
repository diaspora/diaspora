require Rails.root.join('config', 'environment', 'development')

Diaspora::Application.configure do
  # Enable threaded mode
  config.threadsafe!
end
