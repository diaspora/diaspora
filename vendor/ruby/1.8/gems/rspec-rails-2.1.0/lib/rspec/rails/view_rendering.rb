require 'action_view/testing/resolvers'

module RSpec
  module Rails
    module ViewRendering
      extend ActiveSupport::Concern

      module ClassMethods
        def metadata_for_rspec_rails
          metadata[:rspec_rails] ||= {}
        end

        # See RSpec::Rails::ControllerExampleGroup
        def render_views
          metadata_for_rspec_rails[:render_views] = true
        end

        def integrate_views
          RSpec.deprecate("integrate_views","render_views")
          render_views
        end

        def render_views?
          !!metadata_for_rspec_rails[:render_views]
        end
      end

      module InstanceMethods
        def render_views?
          self.class.render_views? || !@controller.class.respond_to?(:view_paths)
        end
      end

      # Delegates find_all to the submitted path set and then returns templates
      # with modified source
      class PathSetDelegatorResolver < ::ActionView::Resolver
        attr_reader :path_set

        def initialize(path_set)
          @path_set = path_set
        end

        def find_all(*args)
          path_set.find_all(*args).collect do |template|
            ::ActionView::Template.new(
              "",
              template.identifier,
              template.handler,
              {
                :virtual_path => template.virtual_path,
                :format => template.formats
              }
            )
          end
        end
      end

      included do
        before do
          unless render_views?
            @_path_set_delegator_resolver = PathSetDelegatorResolver.new(@controller.class.view_paths)
            @controller.class.view_paths = ::ActionView::PathSet.new.push(@_path_set_delegator_resolver)
          end
        end

        after do
          unless render_views?
            @controller.class.view_paths = @_path_set_delegator_resolver.path_set
          end
        end
      end

    end
  end
end
