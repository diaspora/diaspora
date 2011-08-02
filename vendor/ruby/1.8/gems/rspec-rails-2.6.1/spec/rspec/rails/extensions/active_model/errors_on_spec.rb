require "spec_helper"

describe "errors_on" do
  let(:klass) do
    Class.new do
      include ActiveModel::Validations
    end
  end

  it "calls valid?" do
    model = klass.new
    model.should_receive(:valid?)
    model.errors_on(:foo)
  end

  it "returns the errors on that attribute" do
    model = klass.new
    model.stub(:errors) do
      { :foo => ['a', 'b'] }
    end
    model.errors_on(:foo).should eq(['a','b'])
  end
end
