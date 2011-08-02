module Devise
  module Generators
    class DeviseGenerator < Rails::Generators::NamedBase
      namespace "devise"
      source_root File.expand_path("../templates", __FILE__)

      desc "Generates a model with the given NAME (if one does not exist) with devise " <<
           "configuration plus a migration file and devise routes."

      hook_for :orm

      def add_devise_routes
        devise_route  = "devise_for :#{plural_name}"
        devise_route += %Q(, :class_name => "#{class_name}") if class_name.include?("::")
        route devise_route
      end
    end
  end
end
