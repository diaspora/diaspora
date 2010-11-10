require 'active_support'
template "/usr/local/app/diaspora/config/initializers/secret_token.rb" do
  source "secret_token.rb.erb"
  variables :secret_token => ActiveSupport::SecureRandom.hex(40)
end
