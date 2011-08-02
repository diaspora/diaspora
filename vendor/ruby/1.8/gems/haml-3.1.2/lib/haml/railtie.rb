if Haml::Util.ap_geq_3? && !Haml::Util.ap_geq?("3.0.0.beta4")
  raise <<ERROR
Haml no longer supports Rails 3 versions before beta 4.
  Please upgrade to Rails 3.0.0.beta4 or later.
ERROR
end

# Rails 3.0.0.beta.2+
if defined?(ActiveSupport) && Haml::Util.has?(:public_method, ActiveSupport, :on_load)
  require 'haml/template/options'
  autoload(:Sass, 'sass/rails3_shim')
  ActiveSupport.on_load(:before_initialize) do
    # resolve autoload if it looks like they're using Sass without options
    Sass if File.exist?(File.join(Rails.root, 'public/stylesheets/sass'))
    ActiveSupport.on_load(:action_view) do
      Haml.init_rails(binding)
    end
  end
end
