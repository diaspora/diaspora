require 'rspec/core'
require 'rspec/mocks'
require 'rspec/expectations'

module Macros
  def treats_method_missing_as_private(options = {:noop => true, :subject => nil})
    it "has method_missing as private" do
      self.class.describes.private_instance_methods.should include_method(:method_missing)
    end

    it "does not respond_to? method_missing (because it's private)" do
      formatter = options[:subject] || described_class.new({ }, StringIO.new)
      formatter.should_not respond_to(:method_missing)
    end

    if options[:noop]
      it "should respond_to? all messages" do
        formatter = described_class.new({ }, StringIO.new)
        formatter.should respond_to(:just_about_anything)
      end

      it "should respond_to? anything, when given the private flag" do
        formatter = described_class.new({ }, StringIO.new)
        formatter.respond_to?(:method_missing, true).should be_true
      end
    end
  end
end

RSpec::Matchers.define :include_method do |expected|
  match do |actual|
    actual.map { |m| m.to_s }.include?(expected.to_s)
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.color_enabled = true
  config.extend(Macros)
  config.include(RSpec::Mocks::Methods)

  config.filter_run_excluding :ruby => lambda {|version|
    case version.to_s
    when "!jruby"
      RUBY_ENGINE != "jruby"
    when /^> (.*)/
      !(RUBY_VERSION.to_s > $1)
    else
      !(RUBY_VERSION.to_s =~ /^#{version.to_s}/)
    end
  }
end
