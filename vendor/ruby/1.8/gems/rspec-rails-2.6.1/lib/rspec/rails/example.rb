require 'rspec/rails/example/rails_example_group'
require 'rspec/rails/example/controller_example_group'
require 'rspec/rails/example/request_example_group'
require 'rspec/rails/example/helper_example_group'
require 'rspec/rails/example/view_example_group'
require 'rspec/rails/example/mailer_example_group'
require 'rspec/rails/example/routing_example_group'
require 'rspec/rails/example/model_example_group'

RSpec::configure do |c|
  def c.escaped_path(*parts)
    Regexp.compile(parts.join('[\\\/]'))
  end

  c.include RSpec::Rails::ControllerExampleGroup, :type => :controller, :example_group => {
    :file_path => c.escaped_path(%w[spec controllers])
  }
  c.include RSpec::Rails::HelperExampleGroup, :type => :helper, :example_group => {
    :file_path => c.escaped_path(%w[spec helpers])
  }
  if defined?(RSpec::Rails::MailerExampleGroup)
    c.include RSpec::Rails::MailerExampleGroup, :type => :mailer, :example_group => {
      :file_path => c.escaped_path(%w[spec mailers])
    }
  end
  c.include RSpec::Rails::ModelExampleGroup, :type => :model, :example_group => {
    :file_path => c.escaped_path(%w[spec models])
  }
  c.include RSpec::Rails::RequestExampleGroup, :type => :request, :example_group => {
    :file_path => c.escaped_path(%w[spec (requests|integration)])
  }
  c.include RSpec::Rails::RoutingExampleGroup, :type => :routing, :example_group => {
    :file_path => c.escaped_path(%w[spec routing])
  }
  c.include RSpec::Rails::ViewExampleGroup, :type => :view, :example_group => {
    :file_path => c.escaped_path(%w[spec views])
  }
end
