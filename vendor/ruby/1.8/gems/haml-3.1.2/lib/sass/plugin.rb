dir = File.dirname(File.dirname(__FILE__))
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'haml'

if Haml::Util.try_sass
  load Sass::Util.scope('lib/sass/plugin.rb')
else
  load Haml::Util.scope('vendor/sass/lib/sass/plugin.rb')
end
