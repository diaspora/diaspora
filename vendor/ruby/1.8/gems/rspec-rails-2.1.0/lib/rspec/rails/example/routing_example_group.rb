require "action_dispatch/testing/assertions/routing"

module RSpec::Rails
  module RoutingExampleGroup
    extend ActiveSupport::Concern
    extend RSpec::Rails::ModuleInclusion

    include RSpec::Rails::RailsExampleGroup

    include ActionDispatch::Assertions::RoutingAssertions
    include RSpec::Rails::Matchers::RoutingMatchers

    module InstanceMethods
      attr_reader :routes

      def method_missing(m, *args, &block)
        routes.url_helpers.respond_to?(m) ? routes.url_helpers.send(m, *args) : super
      end
    end

    included do
      metadata[:type] = :routing

      before do
        @routes = ::Rails.application.routes
      end
    end

    RSpec.configure &include_self_when_dir_matches('spec','routing')
  end
end
