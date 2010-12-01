require File.join(File.dirname(__FILE__), '../../lib/generators/cucumber/feature/named_arg')
require File.join(File.dirname(__FILE__), '../../lib/generators/cucumber/feature/feature_base')

# This generator generates a baic feature.
class FeatureGenerator < Rails::Generator::NamedBase
  
  include Cucumber::Generators::FeatureBase
  
  def manifest
    record do |m|
      create_directory(m, true)
      create_feature_file(m)
      create_steps_file(m)
      create_support_file(m)
    end
  end

  def self.gem_root
    File.expand_path('../../../', __FILE__)
  end
  
  def self.source_root
    File.join(gem_root, 'templates', 'feature')
  end
  
  def source_root
    self.class.source_root
  end

  def named_args
    args.map { |arg| NamedArg.new(arg) }
  end

  private

  def banner
    "Usage: #{$0} feature ModelName [field:type, field:type]"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on('--capybara=BACKEND', 'Generate a feature that uses a particular Capybara backend') do |backend|
      options[:capybara] = backend
    end
  end
end
