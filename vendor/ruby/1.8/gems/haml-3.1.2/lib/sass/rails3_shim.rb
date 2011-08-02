unless Haml::Util.try_sass
  # Since Bundler sets up our gem environment,
  # Sass will only be loadable from gem
  # if gem "sass" has been set.
  Haml::Util.haml_warn(<<WARNING)
Haml will no longer automatically load Sass in Haml 3.2.0.
Please add gem 'sass' to your Gemfile.
WARNING
end

require 'sass/plugin/configuration'

ActiveSupport.on_load(:before_initialize) do
  require 'sass'
  require 'sass/plugin'
end
