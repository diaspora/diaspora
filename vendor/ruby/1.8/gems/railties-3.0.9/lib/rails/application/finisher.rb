module Rails
  class Application
    module Finisher
      include Initializable

      initializer :add_generator_templates do
        config.generators.templates.unshift(*paths.lib.templates.to_a)
      end

      initializer :ensure_autoload_once_paths_as_subset do
        extra = ActiveSupport::Dependencies.autoload_once_paths -
                ActiveSupport::Dependencies.autoload_paths

        unless extra.empty?
          abort <<-end_error
            autoload_once_paths must be a subset of the autoload_paths.
            Extra items in autoload_once_paths: #{extra * ','}
          end_error
        end
      end

      initializer :add_to_prepare_blocks do
        config.to_prepare_blocks.each do |block|
          ActionDispatch::Callbacks.to_prepare(&block)
        end
      end

      initializer :add_builtin_route do |app|
        if Rails.env.development?
          app.routes_reloader.paths << File.expand_path('../../info_routes.rb', __FILE__)
        end
      end

      initializer :build_middleware_stack do
        build_middleware_stack
      end

      initializer :eager_load! do
        if config.cache_classes && !$rails_rake_task
          ActiveSupport.run_load_hooks(:before_eager_load, self)
          eager_load!
        end
      end

      initializer :finisher_hook do
        ActiveSupport.run_load_hooks(:after_initialize, self)
      end

      # Force routes to be loaded just at the end and add it to to_prepare callbacks
      initializer :set_routes_reloader do |app|
        reloader = lambda { app.routes_reloader.execute_if_updated }
        reloader.call
        ActionDispatch::Callbacks.to_prepare(&reloader)
      end

      # Disable dependency loading during request cycle
      initializer :disable_dependency_loading do
        if config.cache_classes && !config.dependency_loading
          ActiveSupport::Dependencies.unhook!
        end
      end
    end
  end
end
