require 'rails/railtie/configuration'

module Rails
  class Engine
    class Configuration < ::Rails::Railtie::Configuration
      attr_reader :root
      attr_writer :eager_load_paths, :autoload_once_paths, :autoload_paths

      def initialize(root=nil)
        super()
        @root = root
      end

      def paths
        @paths ||= begin
          paths = Rails::Paths::Root.new(@root)
          paths.app                 "app",                 :eager_load => true, :glob => "*"
          paths.app.controllers     "app/controllers",     :eager_load => true
          paths.app.helpers         "app/helpers",         :eager_load => true
          paths.app.models          "app/models",          :eager_load => true
          paths.app.mailers         "app/mailers",         :eager_load => true
          paths.app.views           "app/views"
          paths.lib                 "lib",                 :load_path => true
          paths.lib.tasks           "lib/tasks",           :glob => "**/*.rake"
          paths.config              "config"
          paths.config.initializers "config/initializers", :glob => "**/*.rb"
          paths.config.locales      "config/locales",      :glob => "*.{rb,yml}"
          paths.config.routes       "config/routes.rb"
          paths.public              "public"
          paths.public.javascripts  "public/javascripts"
          paths.public.stylesheets  "public/stylesheets"
          paths
        end
      end

      def root=(value)
        @root = paths.path = Pathname.new(value).expand_path
      end

      def eager_load_paths
        @eager_load_paths ||= paths.eager_load
      end

      def autoload_once_paths
        @autoload_once_paths ||= paths.autoload_once
      end

      def autoload_paths
        @autoload_paths ||= paths.autoload_paths
      end

      def load_paths
        ActiveSupport::Deprecation.warn "config.load_paths is deprecated. Please use config.autoload_paths instead."
        autoload_paths
      end

      def load_paths=(paths)
        ActiveSupport::Deprecation.warn "config.load_paths= is deprecated. Please use config.autoload_paths instead."
        self.autoload_paths = paths
      end

      # Rails 3, by default, uses bundler, which shims the Kernel#gem method so that it should
      # behave correctly for this deprecation.
      def gem(name, options = {})
        super name, options[:version] || ">= 0"
        require options[:lib] || name
      rescue Gem::LoadError
        msg = "config.gem is deprecated, and you tried to activate the '#{name}' gem (#{options.inspect}) using it.\n"

        if File.exist?("#{Rails.root}/Gemfile")
          msg << "Please add '#{name}' to your Gemfile."
        else
          msg << "Please update your application to use bundler."
        end
        ActiveSupport::Deprecation.warn(msg, caller)
        exit
      end
    end
  end
end
