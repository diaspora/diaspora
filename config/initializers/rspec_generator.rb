Diaspora::Application.configure do
  config.generators do |g|
    g.integration_tool :rspec
    g.test_framework   :rspec
  end
end
