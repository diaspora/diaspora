require 'spec_helper'

RSpec::Matchers.define :have_public_instance_method do |method|
  match do |klass|
    klass.public_instance_methods.any? {|m| [method, method.to_sym].include?(m)}
  end
end

(RSpec::Matchers.constants.sort).each do |c|
  if (Class === (klass = RSpec::Matchers.const_get(c)))
    describe klass do
      if klass.public_instance_methods.any? {|m| ['failure_message_for_should',:failure_message_for_should].include?(m)}
        describe "called with should" do
          subject { klass }
          it { should have_public_instance_method('failure_message_for_should')}
          it { should have_public_instance_method('failure_message')}
        end
      end
      if klass.public_instance_methods.any? {|m| ['failure_message_for_should_not',:failure_message_for_should_not].include?(m)}
        describe "called with should not" do
          subject { klass }
          it { should have_public_instance_method('failure_message_for_should_not')}
          it { should have_public_instance_method('negative_failure_message')}
        end
      end
    end
  end
end
