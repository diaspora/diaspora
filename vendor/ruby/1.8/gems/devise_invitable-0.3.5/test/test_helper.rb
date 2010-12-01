ENV["RAILS_ENV"] = "test"
DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym
require 'rails_app/config/environment'

require 'rails/test_help'
require 'bundler'
Bundler.setup(:default, :development)
require 'capybara/rails'

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = 'test.com'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

ActiveRecord::Schema.define(:version => 1) do
  create_table :users do |t|
    t.database_authenticatable :null => true
    t.string :username
    t.confirmable
    t.invitable

    t.timestamps
  end
end

class ActionDispatch::IntegrationTest
  include Capybara
end
