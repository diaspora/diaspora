module RSpec::Rails
  # Extends ActionDispatch::Integration::Runner to work with RSpec.
  #
  # == Matchers
  #
  # In addition to the stock matchers from rspec-expectations, request
  # specs add these matchers, which delegate to rails' assertions:
  #
  #   response.should render_template(*args)
  #   => delegates to assert_template(*args)
  #
  #   response.should redirect_to(destination)
  #   => delegates to assert_redirected_to(destination)
  module RequestExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include ActionDispatch::Integration::Runner
    include ActionDispatch::Assertions

    module InstanceMethods
      def app
        ::Rails.application
      end
    end

    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate
    include ActionController::TemplateAssertions

    included do
      metadata[:type] = :request

      before do
        @routes = ::Rails.application.routes
      end
    end
  end
end
