dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

require 'haml'

unless Haml::Util.try_sass
  load Haml::Util.scope('vendor/sass/lib/sass.rb')
end
