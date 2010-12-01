$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'pathname'
require 'fssm'

require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  config.before :all do
    @watch_root = Pathname.new(__FILE__).dirname.join('root').expand_path
  end
end
