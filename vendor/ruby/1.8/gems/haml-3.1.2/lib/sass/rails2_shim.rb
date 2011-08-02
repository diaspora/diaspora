Haml::Util.try_sass
Haml::Util.haml_warn(<<WARNING)
Haml will no longer automatically load Sass in Haml 3.2.0.
Please add config.gem 'sass' to your environment.rb.
WARNING

require 'sass'
require 'sass/plugin'

