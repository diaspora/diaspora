$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'rr'

require 'factory_girl'

Spec::Runner.configure do |config|
  config.mock_with RR::Adapters::Rspec
end

share_as :DefinesConstants do
  before do
    @defined_constants = []
  end

  after do
    @defined_constants.reverse.each do |path|
      namespace, class_name = *constant_path(path)
      namespace.send(:remove_const, class_name)
    end
  end

  def define_constant(path, base = Object, &block)
    namespace, class_name = *constant_path(path)
    klass = Class.new(base)
    namespace.const_set(class_name, klass)
    klass.class_eval(&block) if block_given?
    @defined_constants << path
    klass
  end

  def constant_path(constant_name)
    names = constant_name.split('::')
    class_name = names.pop
    namespace = names.inject(Object) { |result, name| result.const_get(name) }
    [namespace, class_name]
  end
end
