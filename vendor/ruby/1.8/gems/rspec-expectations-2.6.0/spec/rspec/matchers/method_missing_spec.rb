require 'spec_helper'

shared_examples_for "a well-behaved method_missing hook" do
  it "raises a NoMethodError (and not SystemStackError) for an undefined method" do
    expect { subject.some_undefined_method }.to raise_error(NoMethodError)
  end
end

describe "RSpec::Matchers method_missing hook" do
  subject { self }
  it_behaves_like "a well-behaved method_missing hook"

  context 'when invoked in a Test::Unit::TestCase' do
    subject { Test::Unit::TestCase.allocate }
    it_behaves_like "a well-behaved method_missing hook"
  end

  context 'when invoked in a MiniTest::Unit::TestCase', :if => defined?(MiniTest) do
    subject { MiniTest::Unit::TestCase.allocate }
    it_behaves_like "a well-behaved method_missing hook"
  end
end

