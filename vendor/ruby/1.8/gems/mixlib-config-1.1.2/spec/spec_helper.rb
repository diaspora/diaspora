$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'mixlib/config'

class ConfigIt
  extend Mixlib::Config
end